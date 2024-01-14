import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/home/widget/filter_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/all_populer_restaurant_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AllRestaurantFilterWidget extends StatelessWidget {
  const AllRestaurantFilterWidget({Key? key, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(
      builder: (restaurantController) {
        return Center(
          child: ResponsiveHelper.isDesktop(context) ? Container(
              height: 70,
              width: Dimensions.webMaxWidth,
              color: Theme.of(context).colorScheme.background,

              child: Row(
                children: [

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('all_restaurants'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      '${restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : 0} ${'restaurants_near_you'.tr}',
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),

                  const Expanded(child: SizedBox()),

                  filter(context, restaurantController),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                ],
              )

          ) : Container(
            color: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('all_restaurants'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                Flexible(
                  child: Text(
                    '${restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : 0} ${'restaurants_near_you'.tr}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              filter(context, restaurantController),
            ]),
          ),
        );
      }
    );
  }

  Widget filter(BuildContext context, RestaurantController restaurantController) {
    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          ResponsiveHelper.isDesktop(context) ? const SizedBox() : const FilterView(),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          AllPopularRestaurantsFilterButton(
            buttonText: 'top_rated'.tr,
            onTap: () => restaurantController.setTopRated(),
            isSelected: restaurantController.topRated == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          AllPopularRestaurantsFilterButton(
            buttonText: 'discounted'.tr,
            onTap: () => restaurantController.setDiscount(),
            isSelected: restaurantController.discount == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          AllPopularRestaurantsFilterButton(
            buttonText: 'veg'.tr,
            onTap: () => restaurantController.setVeg(),
            isSelected: restaurantController.veg == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          AllPopularRestaurantsFilterButton(
            buttonText: 'non_veg'.tr,
            onTap: () => restaurantController.setNonVeg(),
            isSelected: restaurantController.nonVeg == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          ResponsiveHelper.isDesktop(context) ? const FilterView() : const SizedBox(),

        ],
      ),
    );
  }
}
