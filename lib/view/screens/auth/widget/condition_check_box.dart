import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConditionCheckBox extends StatelessWidget {
  final AuthController authController;
  final bool fromSignUp;
  final bool fromDialog;
  const ConditionCheckBox({Key? key, required this.authController,  this.fromSignUp = false, this.fromDialog = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: fromSignUp ? MainAxisAlignment.start : MainAxisAlignment.center, children: [

      fromSignUp ? Checkbox(
        activeColor: Theme.of(context).primaryColor,
        value: authController.acceptTerms,
        onChanged: (bool? isChecked) => authController.toggleTerms(),
      ) : const SizedBox(),

      fromSignUp ? const SizedBox() : Text( '* ', style: robotoRegular),
      Text('by_login_i_agree_with_all_the'.tr, style: robotoRegular.copyWith( fontSize: fromDialog ? Dimensions.fontSizeExtraSmall : null, color: Theme.of(context).hintColor)),

      Expanded(
        child: InkWell(
          onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Text('terms_conditions'.tr, style: robotoMedium.copyWith( fontSize: fromDialog ? Dimensions.fontSizeExtraSmall : null, color: Theme.of(context).primaryColor )),
          ),
        ),
      ),
    ]);
  }
}
