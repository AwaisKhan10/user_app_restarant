import 'dart:async';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/web_header_skeleton.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_failed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final int status;
  final double? totalAmount;
  final String? contactPersonNumber;
  const OrderSuccessfulScreen({Key? key, required this.orderID, required this.status, required this.totalAmount, this.contactPersonNumber}) : super(key: key);

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  String? orderId;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID!;
    if(widget.orderID != null) {
      if(widget.orderID!.contains('?')){
        var parts = widget.orderID!.split('?');
        String id = parts[0].trim();                 // prefix: "date"
        orderId = id;
      }
    }
    Get.find<OrderController>().trackOrder(orderId.toString(), null, false, contactNumber: widget.contactPersonNumber);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
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
              Get.dialog(PaymentFailedDialog(orderID: orderId, orderAmount: total, maxCodOrderAmount: maximumCodOrderAmount, contactPersonNumber: widget.contactPersonNumber), barrierDismissible: false);
            });
          }
        }

        return orderController.trackModel != null ? Center(child: SingleChildScrollView(
          controller: scrollController,
          child: FooterView(
            child: SizedBox(width: Dimensions.webMaxWidth, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Image.asset(success ? Images.checked : Images.warning, width: 100, height: 100),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(
                success ? 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Get.find<AuthController>().isGuestLoggedIn() ? Text(
                '${'order_id'.tr}: $orderId',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              ) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                child: Text(
                  success ? 'your_order_is_placed_successfully'.tr : 'your_order_is_failed_to_place_because'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center,
                ),
              ),

              Get.find<AuthController>().isLoggedIn() && ResponsiveHelper.isDesktop(context) && (success && Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 && total.floor() > 0 )  ? Column(children: [

                Image.asset(Get.find<ThemeController>().darkTheme ? Images.giftBox1 : Images.giftBox, width: 150, height: 150),

                Text('congratulations'.tr , style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).disabledColor),
                    textAlign: TextAlign.center,
                  ),
                ),

              ]) : const SizedBox.shrink() ,
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButton(
                  width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                  buttonText: 'back_to_home'.tr,
                  onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                ),
              ),

            ])),
          ),
        )) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
