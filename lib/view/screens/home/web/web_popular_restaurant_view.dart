import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/discount_tag.dart';
import 'package:efood_multivendor/view/base/hover/on_hover.dart';
import 'package:efood_multivendor/view/base/not_available_widget.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:efood_multivendor/view/base/title_widget.dart';
import 'package:efood_multivendor/view/screens/restaurant/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class WebPopularRestaurantView extends StatelessWidget {
  final bool isPopular;
  final bool isRecentlyViewed;
  const WebPopularRestaurantView({Key? key, required this.isPopular, this.isRecentlyViewed = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? restaurantList = isPopular ? restController.popularRestaurantList : isRecentlyViewed ? restController.recentlyViewedRestaurantList : restController.latestRestaurantList;

      return restaurantList != null ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
            child: TitleWidget(title: isPopular ? 'popular_restaurants'.tr : isRecentlyViewed ? 'your_restaurants'.tr :  '${'new_on'.tr} ${AppConstants.appName}'),
          ),

          restaurantList.isNotEmpty ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, childAspectRatio: (1/0.7),
              crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            itemCount: restaurantList.length > 7 ? 8 : restaurantList.length,
            itemBuilder: (context, index){
              return Stack(children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(
                      RouteHelper.getRestaurantRoute(restaurantList[index].id),
                      arguments: RestaurantScreen(restaurant: restaurantList[index]),
                    );
                  },
                  child: OnHover(
                    isItem: true,
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
                                    '/${restaurantList[index].coverPhoto}',
                                height: 120, width: 300, fit: BoxFit.cover,
                              ),
                            ),
                            DiscountTag(
                              discount: restaurantList[index].discount != null
                                  ? restaurantList[index].discount!.discount : 0,
                              discountType: 'percent', freeDelivery: restaurantList[index].freeDelivery,
                            ),
                            restController.isOpenNow(restaurantList[index]) ? const SizedBox() : const NotAvailableWidget(isRestaurant: true),
                            Positioned(
                              top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall,
                              child: GetBuilder<WishListController>(builder: (wishController) {
                                bool isWished = wishController.wishRestIdList.contains(restaurantList[index].id);
                                return InkWell(
                                  onTap: () {
                                    if(Get.find<AuthController>().isLoggedIn()) {
                                      isWished ? wishController.removeFromWishList(restaurantList[index].id, true)
                                          : wishController.addToWishList(null, restaurantList[index], true);
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
                                  restaurantList[index].name!,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text(
                                  restaurantList[index].address!,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                RatingBar(
                                  rating: restaurantList[index].avgRating,
                                  ratingCount: restaurantList[index].ratingCount,
                                  size: 15,
                                ),
                              ]),
                            ),
                          ),

                        ]),
                      ),
                    ),
                  ),
                ),

                Visibility(
                  visible: index == 7,
                  child: Positioned(
                    top: 0, bottom: 0, left: 0, right: 0,
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute(isPopular ? 'popular' : isRecentlyViewed ? 'recently_viewed' : 'latest')),
                      child: OnHover(
                        isItem: true,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.5)),
                            gradient: LinearGradient(colors: [
                              Theme.of(context).primaryColor.withOpacity(0.7),
                              Theme.of(context).primaryColor.withOpacity(1),
                            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+${restaurantList.length-7}\n${'more'.tr}', textAlign: TextAlign.center,
                            style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                )

              ]);
            },
          ) : PopularRestaurantShimmer(restController: restController),
        ],
      ) : const SizedBox();
    });
  }
}

class PopularRestaurantShimmer extends StatelessWidget {
  final RestaurantController restController;
  const PopularRestaurantShimmer({Key? key, required this.restController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: (1/0.7),
        crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      itemCount: 6,
      itemBuilder: (context, index){
        return Container(
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
      },
    );
  }
}

