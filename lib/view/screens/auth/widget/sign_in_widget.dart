import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/helper/custom_validator.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/screens/auth/sign_up_screen.dart';
import 'package:efood_multivendor/view/screens/auth/widget/condition_check_box.dart';
import 'package:efood_multivendor/view/screens/auth/widget/guest_button.dart';
import 'package:efood_multivendor/view/screens/auth/widget/social_login_widget.dart';
import 'package:efood_multivendor/view/screens/forget/forget_pass_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignInWidget extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const SignInWidget({Key? key, required this.exitFromApp, required this.backFromThis}) : super(key: key);

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();

    _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    _phoneController.text =  Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomTextField(
          titleText: ResponsiveHelper.isDesktop(context) ? 'phone'.tr : 'enter_phone_number'.tr,
          hintText: 'enter_phone_number'.tr,
          controller: _phoneController,
          focusNode: _phoneFocus,
          nextFocus: _passwordFocus,
          inputType: TextInputType.phone,
          isPhone: true,
          showTitle: ResponsiveHelper.isDesktop(context),
          onCountryChanged: (CountryCode countryCode) {
            _countryDialCode = countryCode.dialCode;
          },
          countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
              : Get.find<LocalizationController>().locale.countryCode,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        CustomTextField(
          titleText: ResponsiveHelper.isDesktop(context) ? 'password'.tr : 'enter_your_password'.tr,
          hintText: 'enter_your_password'.tr,
          controller: _passwordController,
          focusNode: _passwordFocus,
          inputAction: TextInputAction.done,
          inputType: TextInputType.visiblePassword,
          prefixIcon: Icons.lock,
          isPassword: true,
          showTitle: ResponsiveHelper.isDesktop(context),
          onSubmit: (text) => (GetPlatform.isWeb) ? _login(authController, _countryDialCode!) : null,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),


        Row(children: [
          Expanded(
            child: ListTile(
              onTap: () => authController.toggleRememberMe(),
              leading: Checkbox(
                activeColor: Theme.of(context).primaryColor,
                value: authController.isActiveRememberMe,
                onChanged: (bool? isChecked) => authController.toggleRememberMe(),
              ),
              title: Text('remember_me'.tr),
              contentPadding: EdgeInsets.zero,
              dense: true,
              horizontalTitleGap: 0,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Get.toNamed(RouteHelper.getForgotPassRoute(false, null)),
              Get.dialog(const Center(child: ForgetPassScreen( fromSocialLogin: false, socialLogInBody: null, fromDialog: true)));
            },
            child: Text('${'forgot_password'.tr}?', style: robotoRegular.copyWith( fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        ResponsiveHelper.isDesktop(context) ? const SizedBox() : ConditionCheckBox(authController: authController),
        ResponsiveHelper.isDesktop(context) ? const SizedBox() : const SizedBox(height: Dimensions.paddingSizeSmall),

        CustomButton(
          height: ResponsiveHelper.isDesktop(context) ? 45 : null,
          width:  ResponsiveHelper.isDesktop(context) ? 180 : null,
          buttonText: ResponsiveHelper.isDesktop(context) ? 'login'.tr : 'sign_in'.tr,
          radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
          isBold: ResponsiveHelper.isDesktop(context) ? false : true,
          isLoading: authController.isLoading,
          onPressed: authController.acceptTerms ? () => _login(authController, _countryDialCode!) : null,
          // fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraSmall : null,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        !ResponsiveHelper.isDesktop(context) ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('do_not_have_account'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

          InkWell(
            onTap: authController.isLoading ? null : () {
              if(ResponsiveHelper.isDesktop(context)){
                Get.back();
                Get.dialog(const SignUpScreen());
              }else{
                Get.toNamed(RouteHelper.getSignUpRoute());
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Text('sign_up'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
            ),
          ),
        ]) : const SizedBox(),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        const SocialLoginWidget(),

        ResponsiveHelper.isDesktop(context) ? const SizedBox() : const GuestButton(),

      ]);
    });
  }

  void _login(AuthController authController, String countryDialCode) async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String numberWithCountryCode = countryDialCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (password.length < 8) {
      showCustomSnackBar('password_should_be'.tr);
    }else {
      authController.login(numberWithCountryCode, password, alreadyInApp: widget.backFromThis).then((status) async {
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(phone, password, countryDialCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          String token = status.message!.substring(1, status.message!.length);
          if(Get.find<SplashController>().configModel!.customerVerification! && int.parse(status.message![0]) == 0) {
            List<int> encoded = utf8.encode(password);
            String data = base64Encode(encoded);
            Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, token, RouteHelper.signUp, data));
          }else {
            if(widget.backFromThis) {
              if(ResponsiveHelper.isDesktop(context)){
                Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
              } else {
                Get.back();
              }
            }else {
              Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
            }
          }
        }else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}
