import 'dart:convert';

import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/discount_tag.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/screens/checkout/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


class ItemCard extends StatelessWidget {
  final Product product;
  final bool? isBestItem;
  final bool? isPopularNearbyItem;
  final bool isCampaignItem;
  const ItemCard({Key? key, required this.product, this.isBestItem, this.isPopularNearbyItem = false, this.isCampaignItem = false}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double price = product.price!;
    double discount = product.discount!;
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, product.discountType)!;

    CartModel cartModel = CartModel(
      null, price, discountPrice, (price - discountPrice),
      1, [], [], isCampaignItem, product, [], product.quantityLimit
    );


    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
          ProductBottomSheet(product: product, isCampaign: isCampaignItem),
          backgroundColor: Colors.transparent, isScrollControlled: true,
        ) : Get.dialog(
          Dialog(child: ProductBottomSheet(product: product, isCampaign: isCampaignItem)),
        );
      },
      child: Container(
        width: isPopularNearbyItem! ? double.infinity : 190,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, left: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                    child: CustomImage(
                      placeholder: Images.placeholder,
                      image: !isCampaignItem ? '${Get.find<SplashController>().configModel?.baseUrls?.productImageUrl}''/${product.image}'
                          : '${Get.find<SplashController>().configModel?.baseUrls?.campaignImageUrl}''/${product.image}',
                      fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                    ),
                  ),
                ),

                !isCampaignItem ? Positioned(
                  top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                  child: GetBuilder<WishListController>(builder: (wishController) {
                    bool isWished = wishController.wishProductIdList.contains(product.id);
                    return InkWell(
                      onTap: () {
                        if(Get.find<AuthController>().isLoggedIn()) {
                          isWished ? wishController.removeFromWishList(product.id, false)
                              : wishController.addToWishList(product, null, false);
                        }else {
                          showCustomSnackBar('you_are_not_logged_in'.tr);
                        }
                      },
                      child: Icon(isWished ? Icons.favorite : Icons.favorite_border,
                          color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 20),
                    );
                  }
                  ),
                ) : const SizedBox(),

                DiscountTag(
                  discount: product.restaurantDiscount! > 0
                      ? product.restaurantDiscount
                      : product.discount,
                  discountType: product.restaurantDiscount! > 0 ? 'percent'
                      : product.discountType,
                  fromTop: Dimensions.paddingSizeSmall, fontSize: Dimensions.fontSizeExtraSmall,
                ),

                Positioned(
                  bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                  child: GetBuilder<ProductController>(builder: (productController) {
                    return GetBuilder<CartController>(builder: (cartController) {
                      int cartQty = cartController.cartQuantity(product.id!);
                      int cartIndex = cartController.isExistInCart(product.id, null);

                      return cartQty != 0 ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        ),
                        child: Row(children: [
                          InkWell(
                            onTap: cartController.isLoading ? null : () {
                              if (cartController.cartList[cartIndex].quantity! > 1) {
                                cartController.setQuantity(false, cartModel, cartIndex: cartIndex);
                              }else {
                                cartController.removeFromCart(cartIndex);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(
                                Icons.remove, size: 16, color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: /*!cartController.isLoading ? */Text(
                              cartQty.toString(),
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                            )/* : const Center(child: SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white)))*/,
                          ),

                          InkWell(
                            onTap: cartController.isLoading ? null : () {
                              cartController.setQuantity(true, cartModel, cartIndex: cartIndex);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(
                                Icons.add, size: 16, color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ]),
                      ) : InkWell(
                        onTap: () {
                          if(isCampaignItem) {
                            ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                              ProductBottomSheet(product: product, isCampaign: true),
                              backgroundColor: Colors.transparent, isScrollControlled: true,
                            ) : Get.dialog(
                              Dialog(child: ProductBottomSheet(product: product, isCampaign: true)),
                            );
                          } else {
                            if(product.variations == null || (product.variations != null && product.variations!.isEmpty)) {

                              productController.setExistInCart(product);

                              OnlineCart onlineCart = OnlineCart(null, product.id, null, product.price!.toString(), [], 1, [], [], [], 'Food');

                              if (Get.find<CartController>().existAnotherRestaurantProduct(cartModel.product!.restaurantId)) {
                                Get.dialog(ConfirmationDialog(
                                  icon: Images.warning,
                                  title: 'are_you_sure_to_reset'.tr,
                                  description: 'if_you_continue'.tr,
                                  onYesPressed: () {
                                    Get.find<CartController>().clearCartOnline().then((success) async {
                                      if (success) {
                                        await Get.find<CartController>().addToCartOnline(onlineCart);
                                        Get.back();
                                        _showCartSnackBar();
                                      }
                                    });
                                  },
                                ), barrierDismissible: false);
                              } else {
                                Get.find<CartController>().addToCartOnline(onlineCart);
                                _showCartSnackBar();
                              }

                            } else {
                              ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                                ProductBottomSheet(product: product, isCampaign: false),
                                backgroundColor: Colors.transparent, isScrollControlled: true,
                              ) : Get.dialog(
                                Dialog(child: ProductBottomSheet(product: product, isCampaign: false)),
                              );
                            }
                          }

                        },
                        child: Container(
                          height: 24, width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                          ),
                          child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 20),
                        ),
                      );
                    });
                  }),
                ),

              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Column(
              crossAxisAlignment: isBestItem == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.restaurantName!, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  overflow: TextOverflow.ellipsis, maxLines: 1,
                ),

                Row(mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Flexible(child: Text(product.name!, style: robotoMedium, overflow: TextOverflow.ellipsis, maxLines: 1)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    (Get.find<SplashController>().configModel!.toggleVegNonVeg!)? Image.asset(
                      product.veg == 0 ? Images.nonVegImage : Images.vegImage,
                      height: 10, width: 10, fit: BoxFit.contain,
                    ) : const SizedBox(),
                  ],
                ),

                Row(
                  mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Text(product.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text('(${product.ratingCount})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                  ],
                ),

                Wrap(
                  alignment: isBestItem == true ? WrapAlignment.center : WrapAlignment.start,
                  // mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    discountPrice < price ? Text(PriceConverter.convertPrice(price),
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough)): const SizedBox(),
                    discountPrice < price ? const SizedBox(width: Dimensions.paddingSizeExtraSmall) : const SizedBox(),

                    Text(PriceConverter.convertPrice(discountPrice), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  ],
                ),

              ],
            ),
            ),
          ),
        ]),
      ),
      /*child: Stack(
        children: [
          Container(
            height: 240, width: 190,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

               Container(
                 height: 133, width: 190,
                 decoration: const BoxDecoration(
                   borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                 ),

                 child: ClipRRect(
                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                   child: CustomImage(
                     placeholder: Images.placeholder,
                     image: !isCampaignItem ? '${Get.find<SplashController>().configModel?.baseUrls?.productImageUrl}''/${product.image}'
                         : '${Get.find<SplashController>().configModel?.baseUrls?.campaignImageUrl}''/${product.image}',
                     fit: BoxFit.cover, height: 133, width: 190,
                   ),
                ),
               ),


                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: isBestItem == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.restaurantName!, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                        overflow: TextOverflow.ellipsis, maxLines: 1,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Wrap(crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(product.name!, style: robotoMedium, overflow: TextOverflow.ellipsis, maxLines: 1),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          (Get.find<SplashController>().configModel!.toggleVegNonVeg!)? Image.asset(
                           product.veg == 0 ? Images.nonVegImage : Images.vegImage,
                           height: 10, width: 10, fit: BoxFit.contain,
                           ) : const SizedBox(),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Row(
                        mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Text(product.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text('(${product.ratingCount})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Row(
                        mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          discountPrice < price ? Text(PriceConverter.convertPrice(price),
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough)): const SizedBox(),
                          discountPrice < price ? const SizedBox(width: Dimensions.paddingSizeExtraSmall) : const SizedBox(),

                          Text(PriceConverter.convertPrice(discountPrice), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),

          DiscountTag(
            discount: product.restaurantDiscount! > 0
                ? product.restaurantDiscount
                : product.discount,
            discountType: product.restaurantDiscount! > 0 ? 'percent'
                : product.discountType,
            fromTop: Dimensions.paddingSizeSmall, fontSize: Dimensions.fontSizeExtraSmall,
          ),


          Positioned(
            top: Dimensions.paddingSizeSmall, right: isPopularNearbyItem == true ? 35 : Dimensions.paddingSizeSmall,
            child: GetBuilder<WishListController>(builder: (wishController) {
              bool isWished = wishController.wishRestIdList.contains(product.id);
              return InkWell(
                onTap: () {
                  if(Get.find<AuthController>().isLoggedIn()) {
                    isWished ? wishController.removeFromWishList(product.id, true)
                        : wishController.addToWishList(product, null, true);
                  }else {
                    showCustomSnackBar('you_are_not_logged_in'.tr);
                  }
                },
                child: Icon(isWished ? Icons.favorite : Icons.favorite_border,
                    color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 20),
              );
            }
            ),
          ),

           //
           // /// free delivery field missing
           // Positioned(
           //    top: 100, left: isPopularNearbyItem == true ? 10 : 10,
           //    child:
           //    Container(
           //      height: 22,
           //      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
           //      decoration: BoxDecoration(
           //        color: Theme.of(context).cardColor.withOpacity(0.8),
           //        borderRadius: const BorderRadius.all(Radius.circular(50)),
           //      ),
           //      child: Row(
           //        mainAxisAlignment: MainAxisAlignment.center,
           //        children: [
           //          Image.asset(Images.deliveryIcon, height: 15, width: 15, color: Theme.of(context).primaryColor),
           //          const SizedBox(width: Dimensions.paddingSizeSmall),
           //          Text('free'.tr, style: robotoRegular.copyWith(fontSize: 9)),
           //        ],
           //      ),
           //    )),


          Positioned(
            top: 100, right: isPopularNearbyItem == true ? 35 : Dimensions.paddingSizeSmall,
            child: GetBuilder<ProductController>(
              builder: (productController) {
                return GetBuilder<CartController>(
                  builder: (cartController) {
                    int cartQty = cartController.cartQuantity(product.id!);
                    int cartIndex = cartController.isExistInCart(product.id, null);

                    return cartQty != 0 ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      ),
                      child: Row(children: [
                        InkWell(
                          onTap: () {
                            if (cartController.cartList[cartIndex].quantity! > 1) {
                              cartController.setQuantity(false, cartModel, cartIndex: cartIndex);
                            }else {
                              cartController.removeFromCart(cartIndex);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Icon(
                              Icons.remove, size: 16, color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: Text(
                            cartQty.toString(),
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            cartController.setQuantity(true, cartModel, cartIndex: cartIndex);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Icon(
                              Icons.add, size: 16, color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ]),
                    ) : InkWell(
                      onTap: () {
                        if(isCampaignItem) {
                          Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(
                            fromCart: false, cartList: [cartModel],
                          ));
                        } else {
                          if(product.variations == null || (product.variations != null && product.variations!.isEmpty)) {

                            productController.setExistInCart(product);

                            if (Get.find<CartController>().existAnotherRestaurantProduct(cartModel.product!.restaurantId)) {
                              Get.dialog(ConfirmationDialog(
                                icon: Images.warning,
                                title: 'are_you_sure_to_reset'.tr,
                                description: 'if_you_continue'.tr,
                                onYesPressed: () {
                                  Get.back();
                                  Get.find<CartController>().removeAllAndAddToCart(cartModel);
                                  _showCartSnackBar();
                                },
                              ), barrierDismissible: false);
                            } else {
                              Get.find<CartController>().addToCart(cartModel, productController.cartIndex);
                              _showCartSnackBar();
                            }

                          } else {
                            ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                              ProductBottomSheet(product: product, isCampaign: false),
                              backgroundColor: Colors.transparent, isScrollControlled: true,
                            ) : Get.dialog(
                              Dialog(child: ProductBottomSheet(product: product, isCampaign: false)),
                            );
                          }
                        }

                      },
                      child: Container(
                        height: 24, width: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                        ),
                        child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 20),
                      ),
                    );
                  }
                );
              }
            ),
          ),
        ],
      ),*/
    );
  }

  void _showCartSnackBar() {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
      dismissDirection: DismissDirection.horizontal,
      margin: ResponsiveHelper.isDesktop(Get.context) ?  EdgeInsets.only(
        right: Get.context!.width * 0.7,
        left: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall,
      ) : const EdgeInsets.all(Dimensions.paddingSizeSmall),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      action: SnackBarAction(label: 'view_cart'.tr, textColor: Colors.white, onPressed: () {
        Get.toNamed(RouteHelper.getCartRoute());
      }),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      content: Text(
        'item_added_to_cart'.tr,
        style: robotoMedium.copyWith(color: Colors.white),
      ),
    ));
  }
}


class ItemCardShimmer extends StatelessWidget {
  final bool? isPopularNearbyItem;
  const ItemCardShimmer({Key? key, this.isPopularNearbyItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 240,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: (isPopularNearbyItem! && ResponsiveHelper.isMobile(context)) ? 1 : 5,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              child: Shimmer(
                duration: const Duration(seconds: 2),
                enabled: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 240, width: 190,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 133, width: 190,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                              child: Container(color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300], ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 10, width: 100, color:Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300], ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Container(height: 10, width: 150, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300], ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Container(height: 10, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300], ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Container(height: 10, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300], ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
      ),
    );
  }
}
