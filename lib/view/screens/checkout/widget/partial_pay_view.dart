import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class PartialPayView extends StatelessWidget {
  final double totalPrice;
  const PartialPayView({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        return Get.find<SplashController>().configModel!.partialPaymentStatus! && !orderController.subscriptionOrder
        && Get.find<SplashController>().configModel!.customerWalletStatus == 1
        && Get.find<UserController>().userInfoModel != null && (orderController.distance != -1)
        && Get.find<UserController>().userInfoModel!.walletBalance! > 0 ? AnimatedContainer(
          duration: const Duration(seconds: 2),
          decoration: BoxDecoration(
            color: Get.find<ThemeController>().darkTheme ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).primaryColor.withOpacity(0.05),
            border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            image: const DecorationImage(
              alignment: Alignment.bottomRight,
              image: AssetImage(Images.partialWalletTransparent),
            ),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.asset(Images.partialWallet, height: 30, width: 30),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance!),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  orderController.isPartialPay ? 'has_paid_by_your_wallet'.tr : 'your_have_balance_in_your_wallet'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ]),

            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Row(children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(
                  'applied'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                )
              ]) : Text(
                'do_you_want_to_use_now'.tr,
                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
              ),

              InkWell(
                onTap: (){
                  if(Get.find<UserController>().userInfoModel!.walletBalance! < totalPrice){
                    orderController.changePartialPayment();
                  } else{
                    if(orderController.paymentMethodIndex != 1) {
                      orderController.setPaymentMethod(1);
                    }else{
                      orderController.setPaymentMethod(-1);
                    }
                  }

                },
                child: Container(
                  decoration: BoxDecoration(
                    color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                    border: Border.all(color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Colors.red : Theme.of(context).primaryColor, width: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? 'remove'.tr : 'use'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Colors.red : Colors.white),
                  ),
                ),
              ),

            ]),

            orderController.paymentMethodIndex == 1 ? Text(
              '${'remaining_wallet_balance'.tr}: ${PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance! - totalPrice)}',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ) : const SizedBox(),

          ]),
        ) : const SizedBox();
      }
    );
  }
}
