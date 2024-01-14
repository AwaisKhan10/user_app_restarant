import 'dart:io';

import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/model/response/response_model.dart';
import 'package:efood_multivendor/data/model/response/userinfo_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/my_text_field.dart';
import 'package:efood_multivendor/view/base/not_logged_in_screen.dart';
import 'package:efood_multivendor/view/base/web_header.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/profile/widget/profile_bg_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn() && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
    Get.find<UserController>().initData();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(leading: IconButton(onPressed: () =>Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color)), elevation: 0, backgroundColor: Theme.of(context).cardColor, actions: const [SizedBox()],),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: Column(
        children: [

          GetBuilder<UserController>(builder: (userController) {
            if(userController.userInfoModel != null && _phoneController.text.isEmpty) {
              _firstNameController.text = userController.userInfoModel!.fName ?? '';
              _lastNameController.text = userController.userInfoModel!.lName ?? '';
              _phoneController.text = userController.userInfoModel!.phone ?? '';
              _emailController.text = userController.userInfoModel!.email ?? '';
              print('=========>> ${userController.userInfoModel!.image}');
            }

            return Expanded(
              child: isLoggedIn ? userController.userInfoModel != null ? ResponsiveHelper.isDesktop(context) ? webView(userController, isLoggedIn) : Column(children: [

                Center(child: Stack(children: [
                  ClipOval(child: userController.pickedFile != null ? GetPlatform.isWeb ? Image.network(
                    userController.pickedFile!.path, width: 100, height: 100, fit: BoxFit.cover,
                  ) : Image.file(
                    File(userController.pickedFile!.path), width: 100, height: 100, fit: BoxFit.cover,
                  ) : CustomImage(
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${userController.userInfoModel!.image}',
                    height: 100, width: 100, fit: BoxFit.cover,
                  )),
                  Positioned(
                    bottom: 0, right: 0, top: 0, left: 0,
                    child: InkWell(
                      onTap: () => userController.pickImage(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3), shape: BoxShape.circle,
                          border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ])),

                Expanded(child: Scrollbar(child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text(
                      'first_name'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    MyTextField(
                      hintText: 'first_name'.tr,
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      nextFocus: _lastNameFocus,
                      inputType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text(
                      'last_name'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    MyTextField(
                      hintText: 'last_name'.tr,
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      nextFocus: _emailFocus,
                      inputType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text(
                      'email'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    MyTextField(
                      hintText: 'email'.tr,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Row(children: [
                      Text(
                        'phone'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text('(${'non_changeable'.tr})', style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error,
                      )),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    MyTextField(
                      hintText: 'phone'.tr,
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      inputType: TextInputType.phone,
                      isEnabled: false,
                    ),

                  ]))),
                ))),

                SafeArea(
                  child: CustomButton(
                    isLoading: userController.isLoading,
                    onPressed: () => _updateProfile(userController),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    buttonText: 'update'.tr,
                  ),
                ),

              ]) : const Center(child: CircularProgressIndicator()) : NotLoggedInScreen(callBack: (value){
                initCall();
                setState(() {});
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget webView(UserController userController, bool isLoggedIn) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Center(
        child: FooterView(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              SizedBox(
                height: 243,
                child: Stack(
                  children: [
                    Container(
                      height: 162,
                      width: Dimensions.webMaxWidth,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.10),
                          image: const DecorationImage(image: AssetImage(Images.profileBackground), fit: BoxFit.fitWidth)
                      ),
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                              child: Text('edit_profile'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)))),
                    ),

                    Positioned(
                      top: 95, left: 0, right: 0,
                      child: Stack(children: [
                        Center(
                          child: ClipOval(child: userController.pickedFile != null ? GetPlatform.isWeb ? Image.network(
                            userController.pickedFile!.path, width: 100, height: 100, fit: BoxFit.cover,
                          ) : Image.file(
                            File(userController.pickedFile!.path), width: 100, height: 100, fit: BoxFit.cover,
                          ) : CustomImage(
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${userController.userInfoModel!.image}',
                            height: 100, width: 100, fit: BoxFit.cover,
                          )),
                        ),
                        Positioned(
                          bottom: 0, right: 0, top: 0, left: 0,
                          child: InkWell(
                            onTap: () => userController.pickImage(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3), shape: BoxShape.circle,
                                border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: Colors.white),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'first_name'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  CustomTextField(
                    hintText: 'first_name'.tr,
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    nextFocus: _lastNameFocus,
                    inputType: TextInputType.name,
                    capitalization: TextCapitalization.words,
                  ),
                ])),
                const SizedBox(width: Dimensions.paddingSizeLarge),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'last_name'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  CustomTextField(
                    hintText: 'last_name'.tr,
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    nextFocus: _emailFocus,
                    inputType: TextInputType.name,
                    capitalization: TextCapitalization.words,
                  ),
                ])),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Text(
                'email'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                hintText: 'email'.tr,
                controller: _emailController,
                focusNode: _emailFocus,
                inputAction: TextInputAction.done,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Row(children: [
                Text(
                  'phone'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text('(${'non_changeable'.tr})', style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextField(
                hintText: 'phone'.tr,
                controller: _phoneController,
                focusNode: _phoneFocus,
                inputType: TextInputType.phone,
                isEnabled: false,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Row(children: [
                const Expanded(child: SizedBox()),

                CustomButton(
                  width: 200,
                  buttonText: 'update_profile'.tr,
                  onPressed: () => _updateProfile(userController),
                )
              ])
            ]),
          ),
        ),
      ),
    );
  }

  void _updateProfile(UserController userController) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    if (userController.userInfoModel!.fName == firstName &&
        userController.userInfoModel!.lName == lastName && userController.userInfoModel!.phone == phoneNumber &&
        userController.userInfoModel!.email == _emailController.text && userController.pickedFile == null) {
      showCustomSnackBar('change_something_to_update'.tr);
    }else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }else if (lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    }else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    }else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (phoneNumber.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      UserInfoModel updatedUser = UserInfoModel(fName: firstName, lName: lastName, email: email, phone: phoneNumber);
      ResponseModel responseModel = await userController.updateUserInfo(updatedUser, Get.find<AuthController>().getUserToken());
      if(responseModel.isSuccess) {
        showCustomSnackBar('profile_updated_successfully'.tr, isError: false);
      }else {
        showCustomSnackBar(responseModel.message);
      }
    }
  }
}
