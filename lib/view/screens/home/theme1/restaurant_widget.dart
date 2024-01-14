import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/discount_tag.dart';
import 'package:efood_multivendor/view/base/not_available_widget.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:efood_multivendor/view/screens/restaurant/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantWidget extends StatelessWidget {
  final Restaurant? restaurant;
  final int index;
  final bool inStore;
  const RestaurantWidget({Key? key, required this.restaurant, required this.index, this.inStore = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseUrls baseUrls = Get.find<SplashController>().configModel!.baseUrls!;
    bool desktop = ResponsiveHelper.isDesktop(context);
    return InkWell(
      onTap: () {

        if(restaurant != null && restaurant!.restaurantStatus == 1){
          Get.toNamed(
            RouteHelper.getRestaurantRoute(restaurant!.id),
            arguments: RestaurantScreen(restaurant: restaurant),
          );
        }else if(restaurant!.restaurantStatus == 0){
          showCustomSnackBar('restaurant_is_not_available'.tr);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
              child: CustomImage(
                image: '${baseUrls.restaurantCoverPhotoUrl}/${restaurant!.coverPhoto}',
                height: context.width * 0.3, width: Dimensions.webMaxWidth, fit: BoxFit.cover,
              )
            ),
            DiscountTag(
              discount: Get.find<RestaurantController>().getDiscount(restaurant!),
              discountType: Get.find<RestaurantController>().getDiscountType(restaurant!),
              freeDelivery: restaurant!.freeDelivery,
            ),
            Get.find<RestaurantController>().isOpenNow(restaurant!) ? const SizedBox() : const NotAvailableWidget(isRestaurant: true),
          ]),

          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Row(children: [

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                  Text(
                    restaurant!.name!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: desktop ? 2 : 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  (restaurant!.address != null) ? Text(
                    restaurant!.address ?? '',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ) : const SizedBox(),
                  SizedBox(height: restaurant!.address != null ? 2 : 0),

                  RatingBar(
                    rating: restaurant!.avgRating, size: desktop ? 15 : 12,
                    ratingCount: restaurant!.ratingCount,
                  ),

                ]),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              GetBuilder<WishListController>(builder: (wishController) {
                bool isWished = wishController.wishRestIdList.contains(restaurant!.id);
                return InkWell(
                  onTap: () {
                    if(Get.find<AuthController>().isLoggedIn()) {
                      isWished ? wishController.removeFromWishList(restaurant!.id, true)
                          : wishController.addToWishList(null, restaurant, true);
                    }else {
                      showCustomSnackBar('you_are_not_logged_in'.tr);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSizeSmall : 0),
                    child: Icon(
                      isWished ? Icons.favorite : Icons.favorite_border,  size: desktop ? 30 : 25,
                      color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    ),
                  ),
                );
              }),

            ]),
          )),

        ]),
      ),
    );
  }
}

class RestaurantShimmer extends StatelessWidget {
  final bool isEnable;
  const RestaurantShimmer({Key? key, required this.isEnable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(
          color: Colors.grey[Get.isDarkMode ? 800 : 300]!, spreadRadius: 1, blurRadius: 5,
        )],
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: isEnable,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            height: context.width * 0.3, width: Dimensions.webMaxWidth,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
              color: Colors.grey[300],
            ),
          ),

          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Row(children: [

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                  Container(height: 15, width: 150, color: Colors.grey[300]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Container(height: 10, width: 50, color: Colors.grey[300]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  const RatingBar(rating: 0, size: 12, ratingCount: 0),

                ]),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Icon(Icons.favorite_border,  size: 25, color: Theme.of(context).disabledColor),

            ]),
          )),

        ]),
      ),
    );
  }
}

