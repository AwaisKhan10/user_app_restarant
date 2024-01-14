import 'dart:convert';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/helper/cart_helper.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/base/quantity_button.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class CartProductWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  const CartProductWidget({Key? key, required this.cart, required this.cartIndex, required this.isAvailable, required this.addOns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String addOnText = CartHelper.setupAddonsText(cart: cart) ?? '';
    String variationText = CartHelper.setupVariationText(cart: cart);

    double? discount = cart.product!.restaurantDiscount == 0 ? cart.product!.discount : cart.product!.restaurantDiscount;
    String? discountType = cart.product!.restaurantDiscount == 0 ? cart.product!.discountType : 'percent';

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () {
          ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (con) => ProductBottomSheet(product: cart.product, cartIndex: cartIndex, cart: cart),
          ) : showDialog(context: context, builder: (con) => Dialog(
            child: ProductBottomSheet(product: cart.product, cartIndex: cartIndex, cart: cart),
          ));
        },
        child: GetBuilder<CartController>(
          builder: (cartController) {
            return Slidable(
              key: UniqueKey(),
              enabled: !cartController.isLoading,
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.2,
                children: [
                  SlidableAction(
                    onPressed: (context) => cartController.removeFromCart(cartIndex),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(Get.find<LocalizationController>().isLtr ? Dimensions.radiusDefault : 0), left: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : Dimensions.radiusDefault)),
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: ResponsiveHelper.isDesktop(context) ? [] : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
                ),
                child: Column(
                  children: [

                    Row(children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.productImageUrl}/${cart.product!.image}',
                              height: 65, width: 70, fit: BoxFit.cover,
                            ),
                          ),
                          isAvailable ? const SizedBox() : Positioned(
                            top: 0, left: 0, bottom: 0, right: 0,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.black.withOpacity(0.6)),
                              child: Text('not_available_now_break'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                                color: Colors.white, fontSize: 8,
                              )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Row(children: [
                            Flexible(
                              child: Text(
                                cart.product!.name!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Container(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                              ),
                              child: Text( cart.product!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 2),

                          RatingBar(rating: cart.product!.avgRating, size: 12, ratingCount: cart.product!.ratingCount),
                          const SizedBox(height: 5),

                          Row(
                            children: [
                              Text(
                                PriceConverter.convertPrice(cart.product!.price, discount: discount, discountType: discountType),
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                              ),
                              SizedBox(width: discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                              discount > 0 ? Text(
                                PriceConverter.convertPrice(cart.product!.price), textDirection: TextDirection.ltr,
                                style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
                              ) : const SizedBox(),
                            ],
                          ),
                        ]),
                      ),

                      GetBuilder<CartController>(
                        builder: (cartController) {
                          return Row(children: [
                            QuantityButton(
                              onTap: cartController.isLoading ? () {} : () {
                                if (cart.quantity! > 1) {
                                  cartController.setQuantity(false, cart);
                                }else {
                                  cartController.removeFromCart(cartIndex);
                                }
                              },
                              isIncrement: false,
                              showRemoveIcon: cart.quantity! == 1,
                            ),

                             AnimatedFlipCounter(
                              duration: const Duration(milliseconds: 500),
                              value: cart.quantity!.toDouble(),
                              textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                            ),
                            // Text(cart.quantity.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                            QuantityButton(
                              onTap: cartController.isLoading ? (){} : () => cartController.setQuantity(true, cart),
                              isIncrement: true,
                              color: cartController.isLoading ? Theme.of(context).disabledColor : null,
                            ),
                          ]);
                        }
                      ),

                      // !ResponsiveHelper.isMobile(context) ? Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      //   child: IconButton(
                      //     onPressed: () {
                      //       Get.find<CartController>().removeFromCart(cartIndex);
                      //     },
                      //     icon: const Icon(Icons.delete, color: Colors.red),
                      //   ),
                      // ) : const SizedBox(),

                    ]),

                    addOnText.isNotEmpty ? Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        const SizedBox(width: 80),
                        Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        Flexible(child: Text(
                          addOnText,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        )),
                      ]),
                    ) : const SizedBox(),

                    variationText.isNotEmpty ? Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        const SizedBox(width: 80),
                        Text('${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        Flexible(child: Text(
                          variationText,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        )),
                      ]),
                    ) : const SizedBox(),

                    ResponsiveHelper.isDesktop(context) ? const Padding(
                      padding: EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                      child: Divider(),
                    ) : const SizedBox()

                  ],
                )
              ),
            );
          }
        ),
      ),
    );
  }
}













// import 'package:efood_multivendor/controller/cart_controller.dart';
// import 'package:efood_multivendor/controller/splash_controller.dart';
// import 'package:efood_multivendor/data/model/response/cart_model.dart';
// import 'package:efood_multivendor/data/model/response/product_model.dart';
// import 'package:efood_multivendor/helper/price_converter.dart';
// import 'package:efood_multivendor/helper/responsive_helper.dart';
// import 'package:efood_multivendor/util/dimensions.dart';
// import 'package:efood_multivendor/util/styles.dart';
// import 'package:efood_multivendor/view/base/custom_image.dart';
// import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
// import 'package:efood_multivendor/view/base/quantity_button.dart';
// import 'package:efood_multivendor/view/base/rating_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class CartProductWidget extends StatelessWidget {
//   final CartModel cart;
//   final int cartIndex;
//   final List<AddOns> addOns;
//   final bool isAvailable;
//   const CartProductWidget({Key? key, required this.cart, required this.cartIndex, required this.isAvailable, required this.addOns}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     String addOnText = '';
//     int index0 = 0;
//     List<int?> ids = [];
//     List<int?> qtys = [];
//     for (var addOn in cart.addOnIds!) {
//       ids.add(addOn.id);
//       qtys.add(addOn.quantity);
//     }
//     for (var addOn in cart.product!.addOns!) {
//       if (ids.contains(addOn.id)) {
//         addOnText = '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
//         index0 = index0 + 1;
//       }
//     }
//
//     String variationText = '';
//
//     if(cart.variations!.isNotEmpty) {
//       for(int index=0; index<cart.variations!.length; index++) {
//         if(cart.variations![index].isNotEmpty && cart.variations![index].contains(true)) {
//           variationText += '${variationText.isNotEmpty ? ', ' : ''}${cart.product!.variations![index].name} (';
//
//           for(int i=0; i<cart.variations![index].length; i++) {
//             if(cart.variations![index][i]!) {
//               variationText += '${variationText.endsWith('(') ? '' : ', '}${cart.product!.variations![index].variationValues![i].level}';
//             }
//           }
//           variationText += ')';
//         }
//       }
//     }
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
//       child: InkWell(
//         onTap: () {
//           ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (con) => ProductBottomSheet(product: cart.product, cartIndex: cartIndex, cart: cart),
//           ) : showDialog(context: context, builder: (con) => Dialog(
//             child: ProductBottomSheet(product: cart.product, cartIndex: cartIndex, cart: cart),
//           ));
//         },
//         child: Container(
//           decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
//           child: Stack(children: [
//             const Positioned(
//               top: 0, bottom: 0, right: 0, left: 0,
//               child: Icon(Icons.delete, color: Colors.white, size: 50),
//             ),
//             Dismissible(
//               key: UniqueKey(),
//               onDismissed: (DismissDirection direction) => Get.find<CartController>().removeFromCart(cartIndex),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).cardColor,
//                   borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                   boxShadow: [BoxShadow(
//                     color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
//                     blurRadius: 5, spreadRadius: 1,
//                   )],
//                 ),
//                 child: Column(
//                   children: [
//
//                     Row(children: [
//                       (cart.product!.image != null && cart.product!.image!.isNotEmpty) ? Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                             child: CustomImage(
//                               image: '${Get.find<SplashController>().configModel!.baseUrls!.productImageUrl}/${cart.product!.image}',
//                               height: 65, width: 70, fit: BoxFit.cover,
//                             ),
//                           ),
//                           isAvailable ? const SizedBox() : Positioned(
//                             top: 0, left: 0, bottom: 0, right: 0,
//                             child: Container(
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.black.withOpacity(0.6)),
//                               child: Text('not_available_now_break'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
//                                 color: Colors.white, fontSize: 8,
//                               )),
//                             ),
//                           ),
//                         ],
//                       ) : const SizedBox.shrink(),
//                       const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                       Expanded(
//                         child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
//                           Text(
//                             cart.product!.name!,
//                             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
//                             maxLines: 2, overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 2),
//                           RatingBar(rating: cart.product!.avgRating, size: 12, ratingCount: cart.product!.ratingCount),
//                           const SizedBox(height: 5),
//                           Row(children: [
//                             Text(
//                               PriceConverter.convertPrice(cart.discountedPrice), textDirection: TextDirection.ltr,
//                               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
//                             ),
//                             const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                             cart.discountedPrice!+cart.discountAmount! > cart.discountedPrice! ? Text(
//                               PriceConverter.convertPrice(cart.discountedPrice!+cart.discountAmount!), textDirection: TextDirection.ltr,
//                               style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
//                             ) : const SizedBox(),
//                           ]),
//                         ]),
//                       ),
//
//                       Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                         Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Container(
//                           padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                             color: Theme.of(context).primaryColor,
//                           ),
//                           child: Text(
//                             cart.product!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
//                             style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white),
//                           ),
//                         ) : const SizedBox(),
//                         SizedBox(height: Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Dimensions.paddingSizeExtraSmall : 0),
//                         Row(children: [
//                           QuantityButton(
//                             onTap: () {
//                               if (cart.quantity! > 1) {
//                                 Get.find<CartController>().setQuantity(false, cart);
//                               }else {
//                                 Get.find<CartController>().removeFromCart(cartIndex);
//                               }
//                             },
//                             isIncrement: false,
//                           ),
//                           Text(cart.quantity.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
//                           QuantityButton(
//                             onTap: () => Get.find<CartController>().setQuantity(true, cart),
//                             isIncrement: true,
//                           ),
//                         ]),
//                       ]),
//
//                       !ResponsiveHelper.isMobile(context) ? Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//                         child: IconButton(
//                           onPressed: () {
//                             Get.find<CartController>().removeFromCart(cartIndex);
//                           },
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                         ),
//                       ) : const SizedBox(),
//
//                     ]),
//
//                     addOnText.isNotEmpty ? Padding(
//                       padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
//                       child: Row(children: [
//                         const SizedBox(width: 80),
//                         Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
//                         Flexible(child: Text(
//                           addOnText, textDirection: TextDirection.ltr,
//                           style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
//                         )),
//                       ]),
//                     ) : const SizedBox(),
//
//                     (variationText != '' && cart.product!.variations != null && cart.product!.variations!.isNotEmpty) ? Padding(
//                       padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
//                       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         const SizedBox(width: 80),
//                         Text('${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr),
//                         Flexible(child: Text(variationText, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
//                         ),
//                       ]),
//                     ) : const SizedBox(),
//
//                   ],
//                 ),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }
