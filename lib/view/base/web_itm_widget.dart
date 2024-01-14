import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/coupon_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/discount_tag.dart';
import 'package:efood_multivendor/view/base/not_available_widget.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebItemWidget extends StatelessWidget {
  final Product? product;
  final Restaurant? store;

  const WebItemWidget({Key? key, required this.product, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isAvailable = DateConverter.isAvailable(
      product?.availableTimeStarts,
      product?.availableTimeEnds,
    );

    return Stack(children: [
      InkWell(
        onTap: () {
          ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
            ProductBottomSheet(product: product, isCampaign: false),
            backgroundColor: Colors.transparent, isScrollControlled: true,
          ) : Get.dialog(
            Dialog(child: ProductBottomSheet(product: product, isCampaign: false)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
          ),
          child: Column(children: [

            Stack(children: [
              CustomImage(
                image: '${Get.find<SplashController>().configModel!.baseUrls!.productImageUrl}'
                    '/${product?.image}',
                height: 160, width: 275, fit: BoxFit.cover,
              ),
              DiscountTag(
                discount: product?.discount,
                discountType: product?.discountType,
              ),
              isAvailable ? const SizedBox() : const NotAvailableWidget(),
            ]),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                  Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                    Text(
                      product!.name!,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    (Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                        ? Image.asset(
                      product!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                      height: 10, width: 10, fit: BoxFit.contain,
                    ) : const SizedBox(),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    product!.restaurantName!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),

                  RatingBar(
                    rating: product!.avgRating, size: 15,
                    ratingCount: product!.ratingCount,
                  ),

                  Row(children: [
                    Text(
                      PriceConverter.convertPrice(
                        product!.price, discount: product!.discount, discountType: product!.discountType,
                      ),
                      textDirection: TextDirection.ltr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                    SizedBox(width: product!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                    product!.discount! > 0 ? Expanded(child: Text(
                      PriceConverter.convertPrice(product!.price),
                      textDirection: TextDirection.ltr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    )) : const Expanded(child: SizedBox()),
                    const Icon(Icons.add, size: 25),
                  ]),
                ]),
              ),
            ),

          ]),
        ),
      ),
    ]);
  }
}