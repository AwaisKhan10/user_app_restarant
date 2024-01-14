import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/discount_tag.dart';
import 'package:efood_multivendor/view/base/hover/on_hover.dart';
import 'package:efood_multivendor/view/base/not_available_widget.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:efood_multivendor/view/screens/restaurant/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
class WebRestaurantWidget extends StatelessWidget {
  final Restaurant? restaurant;
  const WebRestaurantWidget({Key? key, this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnHover(
      isItem: true,
      child: InkWell(
        onTap: (){
          if(restaurant != null && restaurant!.restaurantStatus == 1){
            Get.toNamed(RouteHelper.getRestaurantRoute(restaurant!.id), arguments: RestaurantScreen(restaurant: restaurant));
          }else if(restaurant!.restaurantStatus == 0){
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

              Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                  child: CustomImage(
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantCoverPhotoUrl}'
                        '/${restaurant!.coverPhoto}',
                    height: 120, width: 300, fit: BoxFit.cover,
                  ),
                ),
                DiscountTag(
                  discount: restaurant!.discount != null
                      ? restaurant!.discount!.discount : 0,
                  discountType: 'percent', freeDelivery: restaurant!.freeDelivery,
                ),
                Get.find<RestaurantController>().isOpenNow(restaurant!) ? const SizedBox() : const NotAvailableWidget(isRestaurant: true),
                Positioned(
                  top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall,
                  child: GetBuilder<WishListController>(builder: (wishController) {
                    bool isWished = wishController.wishRestIdList.contains(restaurant!.id);
                    return InkWell(
                      onTap: () {
                        if(Get.find<AuthController>().isLoggedIn()) {
                          isWished ? wishController.removeFromWishList(restaurant!.id, true)
                              : wishController.addToWishList(null, restaurant!, true);
                        }else {
                          showCustomSnackBar('you_are_not_logged_in'.tr);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Icon(
                          isWished ? Icons.favorite : Icons.favorite_border,  size: 20,
                          color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                        ),
                      ),
                    );
                  }),
                ),
              ]),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      restaurant!.name!,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      restaurant!.address!,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    RatingBar(
                      rating: restaurant!.avgRating,
                      ratingCount: restaurant!.ratingCount,
                      size: 15,
                    ),
                  ]),
                ),
              ),

            ]),
          ),
        ),
      ),
    );
  }
}

class WebRestaurantShimmer extends StatelessWidget {
  const WebRestaurantShimmer({Key? key, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            height: 120, width: 300,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(height: 15, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                const SizedBox(height: 5),

                Container(height: 10, width: 130, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                const SizedBox(height: 5),

                const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
              ]),
            ),
          ),

        ]),
      ),
    );
  }
}
