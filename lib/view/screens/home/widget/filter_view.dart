import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';

class FilterView extends StatelessWidget {
  const FilterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurant) {
      return restaurant.restaurantModel != null ? PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(value: 'all', textStyle: robotoMedium.copyWith(
              color: restaurant.restaurantType == 'all'
                  ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
            ), child: Text('all'.tr)),
            PopupMenuItem(value: 'take_away', textStyle: robotoMedium.copyWith(
              color: restaurant.restaurantType == 'take_away'
                  ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
            ), child: Text('take_away'.tr)),
            PopupMenuItem(value: 'delivery', textStyle: robotoMedium.copyWith(
              color: restaurant.restaurantType == 'delivery'
                  ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
            ), child: Text('delivery'.tr)),
            PopupMenuItem(value: 'latest', textStyle: robotoMedium.copyWith(
              color: restaurant.restaurantType == 'latest'
                  ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
            ), child: Text('latest'.tr)),
            PopupMenuItem(value: 'popular', textStyle: robotoMedium.copyWith(
              color: restaurant.restaurantType == 'popular'
                  ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
            ), child: Text('popular'.tr)),
          ];
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
          ),
          child: Icon(Icons.tune, color: Theme.of(context).primaryColor, size: 20),
        ),
        onSelected: (dynamic value) => restaurant.setRestaurantType(value),
      ) : const SizedBox();
    });
  }
}