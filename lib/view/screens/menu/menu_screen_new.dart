// ignore_for_file: deprecated_member_use, unused_element

import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/screens/auth/sign_in_screen.dart';
import 'package:efood_multivendor/view/screens/menu/widget/portion_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'dart:io' as io;
import 'package:url_launcher/url_launcher.dart';

class MenuScreenNew extends StatefulWidget {
  const MenuScreenNew({Key? key}) : super(key: key);

  @override
  State<MenuScreenNew> createState() => _MenuScreenNewState();
}

class _MenuScreenNewState extends State<MenuScreenNew> {
  launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  openStore() {
    // Replace 'your_package_name' with the actual package name of your app
    String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.weekook.cuistot';
    String appStoreUrl = 'https://apps.apple.com/app/id6474425838';

    String url = (io.Platform.isAndroid) ? playStoreUrl : appStoreUrl;

    launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<UserController>(builder: (userController) {
        final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

        return Column(children: [
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeOverLarge,
                right: Dimensions.paddingSizeOverLarge,
                top: 50,
                bottom: Dimensions.paddingSizeOverLarge,
              ),
              child: Row(children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(1),
                  child: ClipOval(
                      child: CustomImage(
                    placeholder: Images.guestIconLight,
                    image:
                        '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                        '/${(userController.userInfoModel != null && isLoggedIn) ? userController.userInfoModel!.image : ''}',
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  )),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoggedIn && userController.userInfoModel == null
                            ? Shimmer(
                                duration: const Duration(seconds: 2),
                                enabled: true,
                                child: Container(
                                  height: 16,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[
                                        Get.find<ThemeController>().darkTheme
                                            ? 700
                                            : 200],
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                  ),
                                ),
                              )
                            : Text(
                                isLoggedIn
                                    ? '${userController.userInfoModel?.fName} ${userController.userInfoModel?.lName}'
                                    : 'guest_user'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge,
                                    color: Theme.of(context).cardColor),
                              ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        isLoggedIn && userController.userInfoModel != null
                            ? Text(
                                DateConverter.containTAndZToUTCFormat(
                                    userController.userInfoModel!.createdAt!),
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).cardColor),
                              )
                            : InkWell(
                                onTap: () async {
                                  if (!ResponsiveHelper.isDesktop(context)) {
                                    Get.toNamed(RouteHelper.getSignInRoute(
                                            Get.currentRoute))
                                        ?.then((value) {
                                      userController.getUserInfo();
                                    });
                                  } else {
                                    Get.dialog(const SignInScreen(
                                            exitFromApp: true,
                                            backFromThis: true))
                                        .then((value) {
                                      userController.getUserInfo();
                                    });
                                  }
                                },
                                child: Text(
                                  'login_to_view_all_feature'.tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).cardColor),
                                ),
                              ),
                      ]),
                ),
              ]),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Ink(
              color: Get.find<ThemeController>().darkTheme
                  ? Theme.of(context).colorScheme.background
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: Column(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Text(
                      'general'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                          icon: Images.profileIcon,
                          title: 'profile'.tr,
                          route: RouteHelper.getProfileRoute()),
                      PortionWidget(
                          icon: Images.addressIcon,
                          title: 'my_address'.tr,
                          route: RouteHelper.getAddressRoute()),
                      PortionWidget(
                          icon: Images.languageIcon,
                          title: 'language'.tr,
                          hideDivider: true,
                          route: RouteHelper.getLanguageRoute('menu')),
                    ]),
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Text(
                      'promotional_activity'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                          icon: Images.couponIcon,
                          title: 'coupon'.tr,
                          route:
                              RouteHelper.getCouponRoute(fromCheckout: false)),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .loyaltyPointStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.pointIcon,
                              title: 'loyalty_points'.tr,
                              route: RouteHelper.getWalletRoute(false),
                              hideDivider: Get.find<SplashController>()
                                          .configModel!
                                          .customerWalletStatus ==
                                      1
                                  ? false
                                  : true,
                              suffix: !isLoggedIn
                                  ? null
                                  : '${userController.userInfoModel?.loyaltyPoint != null ? Get.find<UserController>().userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .customerWalletStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.walletIcon,
                              title: 'my_wallet'.tr,
                              hideDivider: true,
                              route: RouteHelper.getWalletRoute(true),
                              suffix: !isLoggedIn
                                  ? null
                                  : PriceConverter.convertPrice(
                                      userController.userInfoModel != null
                                          ? Get.find<UserController>()
                                              .userInfoModel!
                                              .walletBalance
                                          : 0),
                            )
                          : const SizedBox(),
                    ]),
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Text(
                      'earnings'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      (Get.find<SplashController>()
                                  .configModel!
                                  .refEarningStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.referIcon,
                              title: 'refer_and_earn'.tr,
                              route: RouteHelper.getReferAndEarnRoute(),
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .toggleDmRegistration! &&
                              !ResponsiveHelper.isDesktop(context))
                          ? PortionWidget(
                              icon: Images.dmIcon,
                              title: 'join_as_a_delivery_man'.tr,
                              route:
                                  RouteHelper.getDeliverymanRegistrationRoute(),
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .toggleRestaurantRegistration! &&
                              !ResponsiveHelper.isDesktop(context))
                          ?

                          //  PortionWidget(
                          //   icon: ,
                          //   title: ,
                          //   hideDivider: true,

                          //   ///
                          //   /// Link Used PlaySore AND App Store
                          //   ///
                          //   // route:
                          //   //     'https://play.google.com/store/apps/details?id=com.weekook.cuistot'
                          // ),

                          InkWell(
                              onTap: () {
                                openStore();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeSmall),
                                child: Column(children: [
                                  Row(children: [
                                    Image.asset(Images.storeIcon,
                                        height: 16, width: 16),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Expanded(
                                        child: Text('open_store'.tr,
                                            style: robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeDefault))),
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     color:
                                    //         Theme.of(context).colorScheme.error,
                                    //     borderRadius: BorderRadius.circular(
                                    //         Dimensions.radiusDefault),
                                    //   ),
                                    //   padding: const EdgeInsets.symmetric(
                                    //       vertical:
                                    //           Dimensions.paddingSizeExtraSmall,
                                    //       horizontal:
                                    //           Dimensions.paddingSizeSmall),
                                    //   child: Text('',
                                    //       style: robotoRegular.copyWith(
                                    //           fontSize:
                                    //               Dimensions.fontSizeSmall,
                                    //           color:
                                    //               Theme.of(context).cardColor)),
                                    // ),
                                  ]),
                                  const SizedBox()
                                ]),
                              ),
                            )
                          : const SizedBox(),
                    ]),
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Text(
                      'help_and_support'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                          icon: Images.chatIcon,
                          title: 'live_chat'.tr,
                          route: RouteHelper.getConversationRoute()),
                      PortionWidget(
                          icon: Images.helpIcon,
                          title: 'help_and_support'.tr,
                          route: RouteHelper.getSupportRoute()),
                      PortionWidget(
                          icon: Images.aboutIcon,
                          title: 'about_us'.tr,
                          route: RouteHelper.getHtmlRoute('about-us')),
                      PortionWidget(
                          icon: Images.termsIcon,
                          title: 'terms_conditions'.tr,
                          route:
                              RouteHelper.getHtmlRoute('terms-and-condition')),
                      PortionWidget(
                          icon: Images.privacyIcon,
                          title: 'privacy_policy'.tr,
                          route: RouteHelper.getHtmlRoute('privacy-policy')),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .refundPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.refundIcon,
                              title: 'refund_policy'.tr,
                              route: RouteHelper.getHtmlRoute('refund-policy'),
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .cancellationPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.cancelationIcon,
                              title: 'cancellation_policy'.tr,
                              route: RouteHelper.getHtmlRoute(
                                  'cancellation-policy'),
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .shippingPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.shippingIcon,
                              title: 'shipping_policy'.tr,
                              hideDivider: true,
                              route:
                                  RouteHelper.getHtmlRoute('shipping-policy'),
                            )
                          : const SizedBox(),
                    ]),
                  )
                ]),
                InkWell(
                  onTap: () {
                    if (Get.find<AuthController>().isLoggedIn()) {
                      Get.dialog(
                          ConfirmationDialog(
                              icon: Images.support,
                              description: 'are_you_sure_to_logout'.tr,
                              isLogOut: true,
                              onYesPressed: () {
                                Get.find<AuthController>().clearSharedData();
                                Get.find<AuthController>().socialLogout();
                                Get.find<CartController>().clearCartList();
                                Get.find<WishListController>().removeWishes();
                                Get.offAllNamed(RouteHelper.getSignInRoute(
                                    RouteHelper.splash));
                              }),
                          useSafeArea: false);
                    } else {
                      Get.find<WishListController>().removeWishes();
                      Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute))
                          ?.then((success) {
                        if (success) {
                          userController.getUserInfo();
                        }
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            child: Icon(Icons.power_settings_new_sharp,
                                size: 14, color: Theme.of(context).cardColor),
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Text(
                              Get.find<AuthController>().isLoggedIn()
                                  ? 'logout'.tr
                                  : 'sign_in'.tr,
                              style: robotoMedium)
                        ]),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeOverLarge)
              ]),
            ),
          )),
        ]);
      }),
    );
  }
}
