import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/arrow_icon_button.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/restaurants_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderAgainView extends StatelessWidget {
  const OrderAgainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      return (restController.orderAgainRestaurantList != null && restController.orderAgainRestaurantList!.isNotEmpty) ? Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
        child: SizedBox(
          height: 230,
          width: Dimensions.webMaxWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: ResponsiveHelper.isMobile(context) ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        child: Text('order_again'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ),

                      Text('${'recently_you_ordered_from'.tr} ${restController.orderAgainRestaurantList!.length} ${'restaurants'.tr}',
                          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ),
                ),

                ArrowIconButton(
                  onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute('order_again')),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: restController.orderAgainRestaurantList!.length,
                padding: EdgeInsets.only(right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                    child: RestaurantsCard(
                      isNewOnStackFood: false,
                      restaurant: restController.orderAgainRestaurantList![index],
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ) : const SizedBox();
    });
  }
}