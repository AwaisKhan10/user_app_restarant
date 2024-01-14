import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_failed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSuccessfulDialog extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderSuccessfulDialog({Key? key, required this.orderID, this.contactNumber}) : super(key: key);

  @override
  State<OrderSuccessfulDialog> createState() => _OrderSuccessfulDialogState();
}

class _OrderSuccessfulDialogState extends State<OrderSuccessfulDialog> {

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().trackOrder(widget.orderID.toString(), null, false, contactNumber: widget.contactNumber);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        await Get.offAllNamed(RouteHelper.getInitialRoute());
        return false;
      },
      child: GetBuilder<OrderController>(builder: (orderController){
          double total = 0;
          bool success = true;
          double? maximumCodOrderAmount;
          if(orderController.trackModel != null) {
            ZoneData zoneData = Get.find<LocationController>().getUserAddress()!.zoneData!.firstWhere((data) => data.id == Get.find<LocationController>().getUserAddress()!.zoneId);
            maximumCodOrderAmount = zoneData.maxCodOrderAmount;
            total = ((orderController.trackModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
            success = orderController.trackModel!.paymentStatus == 'paid' || orderController.trackModel!.paymentMethod == 'cash_on_delivery' || orderController.trackModel!.paymentMethod == 'partial_payment';

            if (!success && !Get.isDialogOpen! && orderController.trackModel!.orderStatus != 'canceled' && Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
              Future.delayed(const Duration(seconds: 1), () {
                Get.dialog(PaymentFailedDialog(orderID: widget.orderID, orderAmount: total, maxCodOrderAmount: maximumCodOrderAmount), barrierDismissible: false);
              });
            }
          }

          return orderController.trackModel != null ? Center(
            child: Container(
              width: 500,  height: 390,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                ResponsiveHelper.isDesktop(context) ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.clear),
                  ),
                ) : const SizedBox(),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                Image.asset(success ? Images.checked : Images.warning, width: 55, height: 55 ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(
                  success ? 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text(
                  '${'order_id'.tr}: ${widget.orderID}',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                  child: Text(
                    success ? 'your_order_is_placed_successfully'.tr : 'your_order_is_failed_to_place_because'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                // const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                //
                // Padding(
                //   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                //   child: CustomButton( width: 400, height: 55, buttonText: 'back_to_home'.tr, isBold: false, onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute())),
                // ),

            ])),
          ) : const Center(child: CircularProgressIndicator());
        })
    );
  }
}