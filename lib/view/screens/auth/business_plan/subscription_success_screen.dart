import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class SubscriptionSuccessScreen extends StatelessWidget {
  final bool success;
  const SubscriptionSuccessScreen({Key? key, required this.success}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FooterView(
        child: SizedBox(width: Dimensions.webMaxWidth, child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

            const SizedBox(height: 200),

            Image.asset( success ? Images.checked : Images.warning, width: 100, height: 100),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              success ? 'your_payment_is_successfully_placed'.tr : 'your_payment_is_not_done'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomButton(buttonText: 'back_to_home'.tr, onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute())),
            ),
          ]),
        )),
      ),
    );
  }
}
