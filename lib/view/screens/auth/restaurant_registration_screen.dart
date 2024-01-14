// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cuisine_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/restaurant_body.dart';
import 'package:efood_multivendor/data/model/body/translation.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/web_page_title_widget.dart';
import 'package:efood_multivendor/view/screens/auth/widget/additional_data_section.dart';
import 'package:efood_multivendor/view/screens/auth/widget/custom_time_picker.dart';
import 'package:efood_multivendor/view/screens/auth/widget/pass_view.dart';
import 'package:efood_multivendor/view/screens/auth/widget/registration_stepper_widget.dart';
import 'package:efood_multivendor/view/screens/auth/widget/select_location_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantRegistrationScreen extends StatefulWidget {
  const RestaurantRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantRegistrationScreen> createState() =>
      _RestaurantRegistrationScreenState();
}

class _RestaurantRegistrationScreenState
    extends State<RestaurantRegistrationScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _nameController = [];
  final List<TextEditingController> _addressController = [];
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final List<FocusNode> _nameFocus = [];
  final List<FocusNode> _addressFocus = [];
  final FocusNode _vatFocus = FocusNode();
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final bool _canBack = false;
  final List<Language>? _languageList =
      Get.find<SplashController>().configModel!.language;
  TabController? _tabController;
  final List<Tab> _tabs = [];
  bool firstTime = true;
  String? _countryDialCode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _languageList!.length, initialIndex: 0, vsync: this);
    _countryDialCode = CountryCode.fromCountryCode(
            Get.find<SplashController>().configModel!.country!)
        .dialCode;
    for (var language in _languageList!) {
      if (kDebugMode) {
        print(language);
      }
      _nameController.add(TextEditingController());
      _addressController.add(TextEditingController());
      _nameFocus.add(FocusNode());
      _addressFocus.add(FocusNode());
    }
    Get.find<AuthController>()
        .setRestaurantAdditionalJoinUsPageData(isUpdate: false);
    Get.find<AuthController>().storeStatusChange(0.4, isUpdate: false);
    Get.find<AuthController>().getZoneList();
    Get.find<CuisineController>().getCuisineList();
    if (Get.find<AuthController>().showPassView) {
      Get.find<AuthController>().showHidePass();
    }
    _languageList?.forEach((language) {
      _tabs.add(Tab(text: language.value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return WillPopScope(
        onWillPop: () async {
          if (_canBack) {
            return true;
          } else {
            authController
                .showBackPressedDialogue('your_registration_not_setup_yet'.tr);
            return false;
          }
        },

        // WebScreenTitleWidget( title: 'join_as_a_restaurant'.tr ),

        child: Scaffold(
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          appBar: CustomAppBar(
              title: 'restaurant_registration'.tr,
              onBackPressed: () {
                if (authController.storeStatus != 0.4 && firstTime) {
                  authController.storeStatusChange(0.4);
                  firstTime = false;
                } else {
                  authController.showBackPressedDialogue(
                      'your_registration_not_setup_yet'.tr);
                }
              }),
          body: SafeArea(
            child: Center(
              child: GetBuilder<AuthController>(builder: (authController) {
                if (authController.restaurantAddress != null) {
                  _addressController[0].text =
                      authController.restaurantAddress.toString();
                }

                return Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      WebScreenTitleWidget(title: 'join_as_a_restaurant'.tr),
                      ResponsiveHelper.isDesktop(context)
                          ? const Center(
                              child: SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: Dimensions.paddingSizeSmall),
                                child: RegistrationStepperWidget(status: ''),
                              ),
                            ))
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                  vertical: Dimensions.paddingSizeSmall),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authController.storeStatus == 0.4
                                          ? 'provide_store_information_to_proceed_next'
                                              .tr
                                          : 'provide_owner_information_to_confirm'
                                              .tr,
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).hintColor),
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    LinearProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).disabledColor,
                                      minHeight: 2,
                                      value: authController.storeStatus,
                                    ),
                                  ]),
                            ),
                      Expanded(
                          child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: ResponsiveHelper.isDesktop(context)
                            ? EdgeInsets.zero
                            : const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeSmall,
                                horizontal: Dimensions.paddingSizeDefault),
                        child: FooterView(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: ResponsiveHelper.isDesktop(context)
                                ? webView(authController)
                                : Column(children: [
                                    Visibility(
                                      visible:
                                          authController.storeStatus == 0.4,
                                      child: Column(children: [
                                        Row(children: [
                                          Expanded(
                                            flex: 4,
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Stack(children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusSmall),
                                                      child: authController
                                                                  .pickedLogo !=
                                                              null
                                                          ? GetPlatform.isWeb
                                                              ? Image.network(
                                                                  authController
                                                                      .pickedLogo!
                                                                      .path,
                                                                  width: 150,
                                                                  height: 120,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.file(
                                                                  File(authController
                                                                      .pickedLogo!
                                                                      .path),
                                                                  width: 150,
                                                                  height: 120,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                          : SizedBox(
                                                              width: 150,
                                                              height: 120,
                                                              child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .camera_alt,
                                                                        size:
                                                                            38,
                                                                        color: Theme.of(context)
                                                                            .disabledColor),
                                                                    const SizedBox(
                                                                        height:
                                                                            Dimensions.paddingSizeSmall),
                                                                    Text(
                                                                      'upload_store_logo'
                                                                          .tr,
                                                                      style: robotoMedium.copyWith(
                                                                          color:
                                                                              Theme.of(context).disabledColor),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ]),
                                                            ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    top: 0,
                                                    left: 0,
                                                    child: InkWell(
                                                      onTap: () =>
                                                          authController
                                                              .pickImage(
                                                                  true, false),
                                                      child: DottedBorder(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        strokeWidth: 1,
                                                        strokeCap:
                                                            StrokeCap.butt,
                                                        dashPattern: const [
                                                          5,
                                                          5
                                                        ],
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        borderType:
                                                            BorderType.RRect,
                                                        radius: const Radius
                                                            .circular(Dimensions
                                                                .radiusDefault),
                                                        child: Center(
                                                          child: Visibility(
                                                            visible: authController
                                                                    .pickedLogo !=
                                                                null,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(25),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: Colors
                                                                        .white),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: const Icon(
                                                                  Icons
                                                                      .camera_alt,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ])),
                                          ),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          Expanded(
                                            flex: 6,
                                            child: Stack(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall),
                                                  child: authController
                                                              .pickedCover !=
                                                          null
                                                      ? GetPlatform.isWeb
                                                          ? Image.network(
                                                              authController
                                                                  .pickedCover!
                                                                  .path,
                                                              width:
                                                                  context.width,
                                                              height: 120,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.file(
                                                              File(authController
                                                                  .pickedCover!
                                                                  .path),
                                                              width:
                                                                  context.width,
                                                              height: 120,
                                                              fit: BoxFit.cover,
                                                            )
                                                      : SizedBox(
                                                          width: context.width,
                                                          height: 120,
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .camera_alt,
                                                                    size: 38,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor),
                                                                const SizedBox(
                                                                    height: Dimensions
                                                                        .paddingSizeSmall),
                                                                Text(
                                                                  'upload_store_cover'
                                                                      .tr,
                                                                  style: robotoMedium
                                                                      .copyWith(
                                                                          color:
                                                                              Theme.of(context).disabledColor),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ]),
                                                        ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                top: 0,
                                                left: 0,
                                                child: InkWell(
                                                  onTap: () => authController
                                                      .pickImage(false, false),
                                                  child: DottedBorder(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    strokeWidth: 1,
                                                    strokeCap: StrokeCap.butt,
                                                    dashPattern: const [5, 5],
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    borderType:
                                                        BorderType.RRect,
                                                    radius:
                                                        const Radius.circular(
                                                            Dimensions
                                                                .radiusDefault),
                                                    child: Center(
                                                      child: Visibility(
                                                        visible: authController
                                                                .pickedCover !=
                                                            null,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(25),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 3,
                                                                color: Colors
                                                                    .white),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                              Icons.camera_alt,
                                                              color:
                                                                  Colors.white,
                                                              size: 50),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ]),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraLarge),

                                        ListView.builder(
                                            itemCount: _languageList!.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: Dimensions
                                                        .paddingSizeExtraLarge),
                                                child: CustomTextField(
                                                  hintText:
                                                      'restaurant_name'.tr,
                                                  controller:
                                                      _nameController[index],
                                                  focusNode: _nameFocus[index],
                                                  nextFocus: index !=
                                                          _languageList!
                                                                  .length -
                                                              1
                                                      ? _nameFocus[index + 1]
                                                      : _addressFocus[0],
                                                  inputType: TextInputType.name,
                                                  capitalization:
                                                      TextCapitalization.words,
                                                ),
                                              );
                                            }),
                                        // CustomTextField(
                                        //   titleText: 'store_name'.tr,
                                        //   controller: _nameController,
                                        //   focusNode: _nameFocus,
                                        //   nextFocus: _addressFocus,
                                        //   inputType: TextInputType.name,
                                        //   capitalization: TextCapitalization.words,
                                        // ),
                                        // const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                                        authController.zoneList != null
                                            ? const SelectLocationView(
                                                fromView: true)
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeLarge),

                                        ListView.builder(
                                            itemCount: _languageList!.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: Dimensions
                                                        .paddingSizeExtraLarge),
                                                child: CustomTextField(
                                                  hintText:
                                                      'restaurant_address'.tr,
                                                  controller:
                                                      _addressController[index],
                                                  focusNode:
                                                      _addressFocus[index],
                                                  nextFocus: index !=
                                                          _languageList!
                                                                  .length -
                                                              1
                                                      ? _addressFocus[index + 1]
                                                      : _vatFocus,
                                                  inputType: TextInputType.text,
                                                  capitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  maxLines: 3,
                                                ),
                                              );
                                            }),
                                        // CustomTextField(
                                        //   titleText: 'store_address'.tr,
                                        //   controller: _addressController,
                                        //   focusNode: _addressFocus,
                                        //   nextFocus: _vatFocus,
                                        //   inputType: TextInputType.text,
                                        //   capitalization: TextCapitalization.sentences,
                                        //   maxLines: 3,
                                        //   inputAction: TextInputAction.done,
                                        // ),
                                        // const SizedBox(height: Dimensions.paddingSizeLarge),

                                        CustomTextField(
                                          titleText: 'vat_tax'.tr,
                                          controller: _vatController,
                                          focusNode: _vatFocus,
                                          inputAction: TextInputAction.done,
                                          inputType: TextInputType.number,
                                          isAmount: true,
                                        ),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraLarge),

                                        InkWell(
                                          onTap: () {
                                            Get.dialog(
                                                const CustomTimePicker());
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusDefault),
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 0.5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeLarge),
                                            child: Row(children: [
                                              Expanded(
                                                  child: Text(
                                                '${authController.storeMinTime} : ${authController.storeMaxTime} ${authController.storeTimeUnit}',
                                                style: robotoMedium,
                                              )),
                                              Icon(
                                                Icons.access_time_filled,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              )
                                            ]),
                                          ),
                                        )
                                      ]),
                                    ),
                                    Visibility(
                                      visible:
                                          authController.storeStatus != 0.4,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Expanded(
                                                  child: CustomTextField(
                                                titleText: 'first_name'.tr,
                                                controller: _fNameController,
                                                focusNode: _fNameFocus,
                                                nextFocus: _lNameFocus,
                                                inputType: TextInputType.name,
                                                capitalization:
                                                    TextCapitalization.words,
                                              )),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall),
                                              Expanded(
                                                  child: CustomTextField(
                                                titleText: 'last_name'.tr,
                                                controller: _lNameController,
                                                focusNode: _lNameFocus,
                                                nextFocus: _phoneFocus,
                                                inputType: TextInputType.name,
                                                capitalization:
                                                    TextCapitalization.words,
                                              )),
                                            ]),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraLarge),
                                            CustomTextField(
                                              titleText:
                                                  ResponsiveHelper.isDesktop(
                                                          context)
                                                      ? 'phone'.tr
                                                      : 'enter_phone_number'.tr,
                                              controller: _phoneController,
                                              focusNode: _phoneFocus,
                                              nextFocus: _emailFocus,
                                              inputType: TextInputType.phone,
                                              isPhone: true,
                                              showTitle:
                                                  ResponsiveHelper.isDesktop(
                                                      context),
                                              onCountryChanged:
                                                  (CountryCode countryCode) {
                                                _countryDialCode =
                                                    countryCode.dialCode;
                                              },
                                              countryDialCode: _countryDialCode != null
                                                  ? CountryCode.fromCountryCode(
                                                          Get.find<
                                                                  SplashController>()
                                                              .configModel!
                                                              .country!)
                                                      .code
                                                  : Get.find<
                                                          LocalizationController>()
                                                      .locale
                                                      .countryCode,
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraLarge),
                                            CustomTextField(
                                              titleText: 'email'.tr,
                                              controller: _emailController,
                                              focusNode: _emailFocus,
                                              nextFocus: _passwordFocus,
                                              inputType:
                                                  TextInputType.emailAddress,
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraLarge),
                                            CustomTextField(
                                              titleText: 'password'.tr,
                                              controller: _passwordController,
                                              focusNode: _passwordFocus,
                                              nextFocus: _confirmPasswordFocus,
                                              inputType:
                                                  TextInputType.visiblePassword,
                                              isPassword: true,
                                              onChanged: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  if (!authController
                                                      .showPassView) {
                                                    authController
                                                        .showHidePass();
                                                  }
                                                  authController
                                                      .validPassCheck(value);
                                                } else {
                                                  if (authController
                                                      .showPassView) {
                                                    authController
                                                        .showHidePass();
                                                  }
                                                }
                                              },
                                            ),
                                            authController.showPassView
                                                ? const PassView()
                                                : const SizedBox(),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraLarge),
                                            CustomTextField(
                                              titleText: 'confirm_password'.tr,
                                              controller:
                                                  _confirmPasswordController,
                                              focusNode: _confirmPasswordFocus,
                                              inputType:
                                                  TextInputType.visiblePassword,
                                              inputAction: TextInputAction.done,
                                              isPassword: true,
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraLarge),
                                            AdditionalDataSection(
                                                authController: authController,
                                                scrollController:
                                                    _scrollController),
                                          ]),
                                    ),
                                  ]),
                          ),
                        ),
                      )),
                      ResponsiveHelper.isDesktop(context)
                          ? const SizedBox()
                          : buttonView(),
                    ]));
              }),
            ),
          ),
        ),
      );
    });
  }

  Widget webView(AuthController authController) {
    return Center(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
            ],
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // Row(children: [
            //   Container(
            //     height: 40,
            //     width: 500,
            //     color: Colors.transparent,
            //     child: TabBar(
            //       controller: _tabController,
            //       indicatorColor: Theme.of(context).primaryColor,
            //       indicatorWeight: 3,
            //       labelColor: Theme.of(context).primaryColor,
            //       unselectedLabelColor: Theme.of(context).disabledColor,
            //       unselectedLabelStyle: robotoRegular.copyWith(
            //           color: Theme.of(context).disabledColor,
            //           fontSize: Dimensions.fontSizeSmall),
            //       labelStyle: robotoBold.copyWith(
            //           fontSize: Dimensions.fontSizeSmall,
            //           color: Theme.of(context).primaryColor),
            //       labelPadding: const EdgeInsets.symmetric(
            //           horizontal: Dimensions.radiusDefault, vertical: 0),
            //       isScrollable: true,
            //       indicatorSize: TabBarIndicatorSize.tab,
            //       tabs: _tabs,
            //       onTap: (int? value) {
            //         setState(() {});
            //       },
            //     ),
            //   ),
            // ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            ///
            /// Store Name
            ///

            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CustomTextField(
                        titleText: 'store_name'.tr,
                        controller: _nameController[_tabController!.index],
                        focusNode: _nameFocus[_tabController!.index],
                        nextFocus:
                            _tabController!.index != _languageList!.length - 1
                                ? _addressFocus[_tabController!.index]
                                : _addressFocus[0],
                        inputType: TextInputType.name,
                        capitalization: TextCapitalization.words,
                        showTitle: true,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      ///
                      /// Restaurant Address'
                      ///

                      CustomTextField(
                        titleText: 'restaurant_address'.tr,
                        controller: _addressController[_tabController!.index],
                        focusNode: _addressFocus[_tabController!.index],
                        nextFocus:
                            _tabController!.index != _languageList!.length - 1
                                ? _addressFocus[_tabController!.index + 1]
                                : _vatFocus,
                        inputType: TextInputType.text,
                        capitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        showTitle: ResponsiveHelper.isDesktop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      authController.zoneList != null
                          ? const SelectLocationView(fromView: true)
                          : const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                )
              ],
            ),
            // const SizedBox(height: Dimensions.paddingSizeSmall),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [
              BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)
            ],
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.person),
              Text('general_information'.tr,
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall))
            ]),
            const Divider(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(children: [
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Expanded(
                      child: CustomTextField(
                    titleText: 'vat_tax'.tr,
                    controller: _vatController,
                    focusNode: _vatFocus,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.number,
                    isAmount: true,
                    showTitle: true,
                  )),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('delivery_time'.tr,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall)),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        InkWell(
                          onTap: () {
                            Get.dialog(const CustomTimePicker());
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge),
                            child: Row(children: [
                              Expanded(
                                  child: Text(
                                '${authController.storeMinTime} : ${authController.storeMaxTime} ${authController.storeTimeUnit}',
                                style: robotoMedium,
                              )),
                              Icon(
                                Icons.access_time_filled,
                                color: Theme.of(context).primaryColor,
                              )
                            ]),
                          ),
                        ),
                      ])),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                authController.zoneList != null
                    ? const SelectLocationView(
                        fromView: true,
                        zoneCuisinesView: true,
                      )
                    : const Center(child: CircularProgressIndicator()),
              ])),
              Expanded(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Expanded(
                      flex: 4,
                      child: Align(
                          alignment: Alignment.center,
                          child: Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                child: authController.pickedLogo != null
                                    ? GetPlatform.isWeb
                                        ? Image.network(
                                            authController.pickedLogo!.path,
                                            width: 150,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(authController
                                                .pickedLogo!.path),
                                            width: 150,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                    : SizedBox(
                                        width: 150,
                                        height: 120,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt,
                                                  size: 38,
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall),
                                              Text(
                                                'upload_store_logo'.tr,
                                                style: robotoMedium.copyWith(
                                                    color: Theme.of(context)
                                                        .disabledColor),
                                                textAlign: TextAlign.center,
                                              ),
                                            ]),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              top: 0,
                              left: 0,
                              child: InkWell(
                                onTap: () =>
                                    authController.pickImage(true, false),
                                child: DottedBorder(
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.butt,
                                  dashPattern: const [5, 5],
                                  padding: const EdgeInsets.all(0),
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(
                                      Dimensions.radiusDefault),
                                  child: Center(
                                    child: Visibility(
                                      visible:
                                          authController.pickedLogo != null,
                                      child: Container(
                                        padding: const EdgeInsets.all(25),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.white),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ])),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                        flex: 6,
                        child: Stack(children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                              child: authController.pickedCover != null
                                  ? GetPlatform.isWeb
                                      ? Image.network(
                                          authController.pickedCover!.path,
                                          width: context.width,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(
                                              authController.pickedCover!.path),
                                          width: context.width,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                  : SizedBox(
                                      width: context.width,
                                      height: 120,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.camera_alt,
                                                size: 38,
                                                color: Theme.of(context)
                                                    .disabledColor),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            Text(
                                              'upload_store_cover'.tr,
                                              style: robotoMedium.copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                              textAlign: TextAlign.center,
                                            ),
                                          ]),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            top: 0,
                            left: 0,
                            child: InkWell(
                              onTap: () =>
                                  authController.pickImage(false, false),
                              child: DottedBorder(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 1,
                                strokeCap: StrokeCap.butt,
                                dashPattern: const [5, 5],
                                padding: const EdgeInsets.all(0),
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(
                                    Dimensions.radiusDefault),
                                child: Center(
                                  child: Visibility(
                                    visible: authController.pickedCover != null,
                                    child: Container(
                                      padding: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 3, color: Colors.white),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt,
                                          color: Colors.white, size: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ])),
                  ])),
            ]),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            //authController.zoneList != null ? const SelectLocationView(fromView: true) : const Center(child: CircularProgressIndicator()),
            //const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [
              BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)
            ],
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.person),
              Text('owner_information'.tr,
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall))
            ]),
            const Divider(),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(children: [
              Expanded(
                  child: CustomTextField(
                titleText: 'first_name'.tr,
                controller: _fNameController,
                focusNode: _fNameFocus,
                nextFocus: _lNameFocus,
                inputType: TextInputType.name,
                capitalization: TextCapitalization.words,
                showTitle: ResponsiveHelper.isDesktop(context),
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                  child: CustomTextField(
                titleText: 'last_name'.tr,
                controller: _lNameController,
                focusNode: _lNameFocus,
                nextFocus: _phoneFocus,
                inputType: TextInputType.name,
                capitalization: TextCapitalization.words,
                showTitle: ResponsiveHelper.isDesktop(context),
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: CustomTextField(
                  titleText: 'phone'.tr,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocus: _emailFocus,
                  inputType: TextInputType.phone,
                  isPhone: true,
                  showTitle: ResponsiveHelper.isDesktop(context),
                  onCountryChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                  },
                  countryDialCode: _countryDialCode != null
                      ? CountryCode.fromCountryCode(Get.find<SplashController>()
                              .configModel!
                              .country!)
                          .code
                      : Get.find<LocalizationController>().locale.countryCode,
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [
              BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)
            ],
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.lock),
              Text('login_info'.tr,
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall))
            ]),
            const Divider(),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: CustomTextField(
                  titleText: 'email'.tr,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocus: _passwordFocus,
                  inputType: TextInputType.emailAddress,
                  showTitle: ResponsiveHelper.isDesktop(context),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  children: [
                    CustomTextField(
                      titleText: 'password'.tr,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      nextFocus: _confirmPasswordFocus,
                      inputType: TextInputType.visiblePassword,
                      isPassword: true,
                      onChanged: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!authController.showPassView) {
                            authController.showHidePass();
                          }
                          authController.validPassCheck(value);
                        } else {
                          if (authController.showPassView) {
                            authController.showHidePass();
                          }
                        }
                      },
                      showTitle: ResponsiveHelper.isDesktop(context),
                    ),
                    authController.showPassView
                        ? const PassView()
                        : const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                  child: CustomTextField(
                titleText: 'confirm_password'.tr,
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                inputType: TextInputType.visiblePassword,
                inputAction: TextInputAction.done,
                isPassword: true,
                showTitle: ResponsiveHelper.isDesktop(context),
              )),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [
              BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)
            ],
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.person),
              Text('additional_information'.tr,
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall))
            ]),
            const Divider(),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            AdditionalDataSection(
                authController: authController,
                scrollController: _scrollController),
          ]),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).hintColor)),
            width: 165,
            child: CustomButton(
              transparent: true,
              textColor: Theme.of(context).hintColor,
              radius: Dimensions.radiusSmall,
              onPressed: () {
                _phoneController.text = '';
                _emailController.text = '';
                _fNameController.text = '';
                _lNameController.text = '';
                _lNameController.text = '';
                _vatController.text = '';
                _passwordController.text = '';
                _confirmPasswordController.text = '';
                for (int i = 0; i < _nameController.length; i++) {
                  _nameController[i].text = '';
                }
                for (int i = 0; i < _addressController.length; i++) {
                  _addressController[i].text = '';
                }
                authController.resetRestaurantRegistration();

                authController.setRestaurantAdditionalJoinUsPageData(
                    isUpdate: true);
              },
              buttonText: 'reset'.tr,
              isBold: false,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeLarge),
          SizedBox(width: 165, child: buttonView()),
        ]),
      ]),
    );
  }

  Widget buttonView() {
    return GetBuilder<AuthController>(builder: (authController) {
      return CustomButton(
        isLoading: authController.isLoading,
        margin: EdgeInsets.all(
            (ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isWeb())
                ? 0
                : Dimensions.paddingSizeSmall),
        buttonText: authController.storeStatus == 0.4 &&
                !ResponsiveHelper.isDesktop(context)
            ? 'next'.tr
            : 'submit'.tr,
        onPressed: () {
          bool defaultNameNull = false;
          bool defaultAddressNull = false;
          bool customFieldEmpty = false;
          for (int index = 0; index < _languageList!.length; index++) {
            if (_languageList![index].key == 'en') {
              if (_nameController[index].text.trim().isEmpty) {
                defaultNameNull = true;
              }
              if (_addressController[index].text.trim().isEmpty) {
                defaultAddressNull = true;
              }
              break;
            }
          }

          Map<String, dynamic> additionalData = {};
          List<FilePickerResult> additionalDocuments = [];
          List<String> additionalDocumentsInputType = [];

          if (authController.storeStatus != 0.4) {
            for (DataModel data in authController.dataList!) {
              bool isTextField = data.fieldType == 'text' ||
                  data.fieldType == 'number' ||
                  data.fieldType == 'email' ||
                  data.fieldType == 'phone';
              bool isDate = data.fieldType == 'date';
              bool isCheckBox = data.fieldType == 'check_box';
              bool isFile = data.fieldType == 'file';
              int index = authController.dataList!.indexOf(data);
              bool isRequired = data.isRequired == 1;

              if (isTextField) {
                if (kDebugMode) {
                  print(
                      '=====check text field : ${authController.additionalList![index].text == ''}');
                }
                if (authController.additionalList![index].text != '') {
                  additionalData.addAll({
                    data.inputData!: authController.additionalList![index].text
                  });
                } else {
                  if (isRequired) {
                    customFieldEmpty = true;
                    showCustomSnackBar(
                        '${data.placeholderData} ${'can_not_be_empty'.tr}');
                    break;
                  }
                }
              } else if (isDate) {
                if (kDebugMode) {
                  print(
                      '---check date : ${authController.additionalList![index]}');
                }
                if (authController.additionalList![index] != null) {
                  additionalData.addAll(
                      {data.inputData!: authController.additionalList![index]});
                } else {
                  if (isRequired) {
                    customFieldEmpty = true;
                    showCustomSnackBar(
                        '${data.placeholderData} ${'can_not_be_empty'.tr}');
                    break;
                  }
                }
              } else if (isCheckBox) {
                List<String> checkData = [];
                bool noNeedToGoElse = false;
                for (var e in authController.additionalList![index]) {
                  if (e != 0) {
                    checkData.add(e);
                    customFieldEmpty = false;
                    noNeedToGoElse = true;
                  } else if (!noNeedToGoElse) {
                    customFieldEmpty = true;
                  }
                }
                if (customFieldEmpty && isRequired) {
                  showCustomSnackBar(
                      '${'please_set_data_in'.tr} ${authController.dataList![index].inputData!.replaceAll('_', ' ')} ${'field'.tr}');
                  break;
                } else {
                  additionalData.addAll({data.inputData!: checkData});
                }
              } else if (isFile) {
                if (kDebugMode) {
                  print(
                      '---check file : ${authController.additionalList![index]}');
                }
                if (authController.additionalList![index].length == 0 &&
                    isRequired) {
                  customFieldEmpty = true;
                  showCustomSnackBar(
                      '${'please_add'.tr} ${authController.dataList![index].inputData!.replaceAll('_', ' ')}');
                  break;
                } else {
                  authController.additionalList![index].forEach((file) {
                    additionalDocuments.add(file);
                    additionalDocumentsInputType
                        .add(authController.dataList![index].inputData!);
                  });
                }
              }
            }
          }

          String vat = _vatController.text.trim();
          String minTime = authController.storeMinTime;
          String maxTime = authController.storeMaxTime;
          String fName = _fNameController.text.trim();
          String lName = _lNameController.text.trim();
          String phone = _phoneController.text.trim();
          String email = _emailController.text.trim();
          String password = _passwordController.text.trim();
          String confirmPassword = _confirmPasswordController.text.trim();
          bool valid = false;
          try {
            double.parse(maxTime);
            double.parse(minTime);
            valid = true;
          } on FormatException {
            valid = false;
          }

          if (authController.storeStatus == 0.4 &&
              !ResponsiveHelper.isDesktop(context)) {
            if (authController.pickedLogo == null) {
              showCustomSnackBar('select_restaurant_logo'.tr);
            } else if (authController.pickedCover == null) {
              showCustomSnackBar('select_restaurant_cover_photo'.tr);
            } else if (defaultNameNull) {
              showCustomSnackBar('enter_restaurant_name'.tr);
            } else if (defaultAddressNull) {
              showCustomSnackBar('enter_restaurant_address'.tr);
            } else if (authController.selectedZoneIndex == 0) {
              showCustomSnackBar('please_select_zone_for_the_restaurant'.tr);
            } else if (vat.isEmpty) {
              showCustomSnackBar('enter_vat_amount'.tr);
            } else if (minTime.isEmpty) {
              showCustomSnackBar('enter_minimum_delivery_time'.tr);
            } else if (maxTime.isEmpty) {
              showCustomSnackBar('enter_maximum_delivery_time'.tr);
            } else if (!valid) {
              showCustomSnackBar('please_enter_the_max_min_delivery_time'.tr);
            } else if (valid && double.parse(minTime) > double.parse(maxTime)) {
              showCustomSnackBar(
                  'maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'
                      .tr);
            } else if (authController.restaurantLocation == null) {
              showCustomSnackBar('set_store_location'.tr);
            } else {
              authController.storeStatusChange(0.8);
              firstTime = true;
            }
          } else {
            if (ResponsiveHelper.isDesktop(context)) {
              if (authController.pickedLogo == null) {
                showCustomSnackBar('select_restaurant_logo'.tr);
              } else if (authController.pickedCover == null) {
                showCustomSnackBar('select_restaurant_cover_photo'.tr);
              } else if (defaultNameNull) {
                showCustomSnackBar('enter_restaurant_name'.tr);
              } else if (defaultAddressNull) {
                showCustomSnackBar('enter_restaurant_address'.tr);
              } else if (authController.selectedZoneIndex == 0) {
                showCustomSnackBar('please_select_zone_for_the_deliveryman'.tr);
              } else if (vat.isEmpty) {
                showCustomSnackBar('enter_vat_amount'.tr);
              } else if (minTime.isEmpty) {
                showCustomSnackBar('enter_minimum_delivery_time'.tr);
              } else if (maxTime.isEmpty) {
                showCustomSnackBar('enter_maximum_delivery_time'.tr);
              } else if (!valid) {
                showCustomSnackBar('please_enter_the_max_min_delivery_time'.tr);
              } else if (valid &&
                  double.parse(minTime) > double.parse(maxTime)) {
                showCustomSnackBar(
                    'maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'
                        .tr);
              } else if (authController.restaurantLocation == null) {
                showCustomSnackBar('set_store_location'.tr);
              }
            }
            if (fName.isEmpty) {
              showCustomSnackBar('enter_your_first_name'.tr);
            } else if (lName.isEmpty) {
              showCustomSnackBar('enter_your_last_name'.tr);
            } else if (phone.isEmpty) {
              showCustomSnackBar('enter_phone_number'.tr);
            } else if (email.isEmpty) {
              showCustomSnackBar('enter_email_address'.tr);
            } else if (!GetUtils.isEmail(email)) {
              showCustomSnackBar('enter_a_valid_email_address'.tr);
            } else if (password.isEmpty) {
              showCustomSnackBar('enter_password'.tr);
            } else if (password.length < 6) {
              showCustomSnackBar('password_should_be'.tr);
            } else if (password != confirmPassword) {
              showCustomSnackBar('confirm_password_does_not_matched'.tr);
            } else if (customFieldEmpty) {
              if (kDebugMode) {
                print('not provide addition data');
              }
            } else {
              List<Translation> translation = [];
              for (int index = 0; index < _languageList!.length; index++) {
                translation.add(Translation(
                  locale: _languageList![index].key,
                  key: 'name',
                  value: _nameController[index].text.trim().isNotEmpty
                      ? _nameController[index].text.trim()
                      : _nameController[0].text.trim(),
                ));
                translation.add(Translation(
                  locale: _languageList![index].key,
                  key: 'address',
                  value: _addressController[index].text.trim().isNotEmpty
                      ? _addressController[index].text.trim()
                      : _addressController[0].text.trim(),
                ));
              }

              List<String> cuisines = [];
              for (var index
                  in Get.find<CuisineController>().selectedCuisines!) {
                cuisines.add(Get.find<CuisineController>()
                    .cuisineModel!
                    .cuisines![index]
                    .id
                    .toString());
              }

              Map<String, String> data = {};

              data.addAll(RestaurantBody(
                deliveryTimeType: authController.storeTimeUnit,
                translation: jsonEncode(translation),
                vat: vat,
                minDeliveryTime: minTime,
                maxDeliveryTime: maxTime,
                lat: authController.restaurantLocation!.latitude.toString(),
                email: email,
                lng: authController.restaurantLocation!.longitude.toString(),
                fName: fName,
                lName: lName,
                phone: phone,
                password: password,
                zoneId: authController
                    .zoneList![authController.selectedZoneIndex!].id
                    .toString(),
                cuisineId: cuisines,
              ).toJson());

              data.addAll({
                'additional_data': jsonEncode(additionalData),
              });

              if (kDebugMode) {
                print('-------final data-- :  $data');
              }
              if (kDebugMode) {
                print('-------additional document-- :  $additionalDocuments');
              }
              if (kDebugMode) {
                print(
                    '-------additional document type-- :  $additionalDocumentsInputType');
              }

              authController.registerRestaurant(
                  data, additionalDocuments, additionalDocumentsInputType);
            }
          }
        },
      );
    });
  }
}
