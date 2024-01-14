import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/model/response/userinfo_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/base/web_header_skeleton.dart';
import 'package:efood_multivendor/view/screens/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPassScreen extends StatefulWidget {
  final String? resetToken;
  final String? number;
  final bool fromPasswordChange;
  final bool fromDialog;
  const NewPassScreen({Key? key, required this.resetToken, required this.number, required this.fromPasswordChange, this.fromDialog = false}) : super(key: key);

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
      appBar:  widget.fromDialog ? null : CustomAppBar(title: widget.fromPasswordChange ? 'reset_password'.tr : 'reset_password'.tr),
      body:  SafeArea(child: Center(child: Scrollbar(controller: _scrollController, child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(child: Container(
          height: widget.fromDialog ? 516 : null,
          width: widget.fromDialog ? 475 : context.width > 700 ? 700 : context.width,
          //padding: widget.fromDialog ? const EdgeInsets.all(Dimensions.paddingSizeOverLarge) : context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: context.width > 700 ? BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: widget.fromDialog ? null : [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
          ) : null,
          child: Column(
            children: [
              ResponsiveHelper.isDesktop(context) ? Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.clear),
                ),
              ) : const SizedBox(),

              Padding(
                padding: widget.fromDialog ? const EdgeInsets.all(Dimensions.paddingSizeOverLarge) : context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(children: [
                  Image.asset(Images.resetLock, height: 100),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Text('enter_new_password'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor), textAlign: TextAlign.center),
                  const SizedBox(height: 50),

                  Column(children: [

                    CustomTextField(
                      hintText: 'new_password'.tr,
                      controller: _newPasswordController,
                      focusNode: _newPasswordFocus,
                      nextFocus: _confirmPasswordFocus,
                      inputType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      divider: false,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    CustomTextField(
                      hintText: 'confirm_password'.tr,
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      onSubmit: (text) => GetPlatform.isWeb ? _resetPassword() : null,
                    ),

                  ]),
                  const SizedBox(height: 30),

                  GetBuilder<UserController>(builder: (userController) {
                    return GetBuilder<AuthController>(builder: (authBuilder) {
                      return CustomButton(
                        radius: Dimensions.radiusDefault,
                        buttonText: 'submit'.tr,
                        isLoading: (authBuilder.isLoading && userController.isLoading),
                        onPressed: () => _resetPassword(),
                      );
                    });
                  }),

                ]),
              )
            ],
          ),
        )),
      )))),
    );
  }

  void _resetPassword() {
    String password = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }else if(password != confirmPassword) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    }else {
      if(widget.fromPasswordChange) {
        UserInfoModel user = Get.find<UserController>().userInfoModel!;
        user.password = password;
        Get.find<UserController>().changePassword(user).then((response) {
          if(response.isSuccess) {
            showCustomSnackBar('password_updated_successfully'.tr, isError: false);
          }else {
            showCustomSnackBar(response.message);
          }
        });
      }else {
        Get.find<AuthController>().resetPassword(widget.resetToken, '+${widget.number!.trim()}', password, confirmPassword).then((value) {
          if (value.isSuccess) {
            Get.find<AuthController>().login('+${widget.number!.trim()}', password).then((value) async {
              // Get.offAllNamed(RouteHelper.getAccessLocationRoute('reset-password'));
              Get.offAllNamed(RouteHelper.getSignInRoute('reset-password'));
              if(!ResponsiveHelper.isDesktop(context)) {
                Get.offAllNamed(RouteHelper.getSignInRoute(Get.currentRoute));
              }else{
                Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false))?.then((value) {
                  Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: true));
                });
              }
            });
          } else {
            showCustomSnackBar(value.message);
          }
        });
      }
    }
  }
}
