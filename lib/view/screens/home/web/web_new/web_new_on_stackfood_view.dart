import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/arrow_icon_button.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/restaurants_card.dart';
import 'package:efood_multivendor/view/screens/restaurant/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebNewOnStackFoodView extends StatelessWidget {
  final bool isLatest;
  const WebNewOnStackFoodView({Key? key, required this.isLatest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      return (restController.latestRestaurantList != null && restController.latestRestaurantList!.isEmpty) ? const SizedBox() : Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
        child: Container(
          width: Dimensions.webMaxWidth,
          color: Theme.of(context).primaryColor.withOpacity(0.1),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge, left: Dimensions.paddingSizeExtraLarge, bottom: Dimensions.paddingSizeExtraLarge, right: 17),
                child: Row(children: [
                  Expanded(
                    child: Column(children: [
                      Text('new_on_stackFood'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    ],
                    ),
                  ),

                  ArrowIconButton(
                    onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute(isLatest ? 'latest' : '')),
                  ),
                ],
                ),
              ),


              restController.latestRestaurantList != null ? GridView.builder(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                itemCount: restController.latestRestaurantList!.length > 6 ? 6 : restController.latestRestaurantList!.length,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: Dimensions.paddingSizeDefault, crossAxisSpacing: Dimensions.paddingSizeDefault,
                  mainAxisExtent: 130,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return RestaurantsCard(
                    isNewOnStackFood: true,
                    restaurant: restController.latestRestaurantList![index],
                  );
                },
              ) : const RestaurantsCardShimmer(isNewOnStackFood: true),
            ],
          ),

        ),
      );
    }
    );
  }
}
