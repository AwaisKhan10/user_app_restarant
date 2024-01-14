import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/web_header_skeleton.dart';
import 'package:efood_multivendor/view/screens/support/widget/web_support_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: 'help_support'.tr, bgColor: Theme.of(context).primaryColor),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: Center(
        child: ResponsiveHelper.isDesktop(context) ? SingleChildScrollView(controller: scrollController, child: const FooterView(child: SizedBox( width: double.infinity, height: 650, child: WebSupportScreen())))
            : SizedBox(
          width: Dimensions.webMaxWidth,
          child: Stack(
            children: [
              Column(children: [
                Expanded(flex: 4, child: Container(color: Theme.of(context).primaryColor)),
                Expanded(flex: 7, child: Container(color: Theme.of(context).cardColor)),
              ]),

              SingleChildScrollView(
                controller: scrollController,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Column(children: [

                      const SizedBox(height: 50),

                      Text('how_we_can_help_you'.tr, style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).cardColor,
                      )),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Text('hey_let_us_know_your_problem'.tr, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor,
                      )),
                      const SizedBox(height: 50),

                      Stack(clipBehavior: Clip.none, children: [
                        Container(
                          height: size.height * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [BoxShadow(
                              color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]!,
                              blurRadius: 5, spreadRadius: 1,
                            )],
                          ),
                        ),

                        Positioned(
                          top: -20, left: 20, right: 20,
                          child: Column(
                            children: [
                              customCard(context,
                                  child: element(context,
                                    image: Images.helpAddress,
                                    title: 'address'.tr,
                                    subTitle: Get.find<SplashController>().configModel!.address!,
                                    onTap: (){},
                                  )
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),

                              Row(children: [
                                Expanded(child: customCard(context,
                                  child: element(context,
                                      image: Images.helpPhone, title: 'call'.tr,
                                      subTitle: Get.find<SplashController>().configModel!.phone!,
                                      onTap: ()async {
                                        if(await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                                          launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication);
                                        }else {
                                          showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
                                        }
                                      }
                                  ),
                                )),
                                const SizedBox(width: Dimensions.paddingSizeLarge),

                                Expanded(child: customCard(context,
                                  child: element(context,
                                    image: Images.helpEmail, title: 'email_us'.tr,
                                    subTitle: Get.find<SplashController>().configModel!.email!,
                                    onTap: () {
                                      final Uri emailLaunchUri = Uri(
                                        scheme: 'mailto',
                                        path: Get.find<SplashController>().configModel!.email,
                                      );
                                      launchUrlString(emailLaunchUri.toString(), mode: LaunchMode.externalApplication);
                                    },
                                  ),
                                )),
                              ])
                            ],
                          ),
                        )

                      ])
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      /*body: Scrollbar(child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Image.asset(Images.supportImage, height: 120),
          const SizedBox(height: 30),

          Image.asset(Images.logo, width: 100),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Image.asset(Images.logoName, width: 100),
          *//*Text(AppConstants.APP_NAME, style: robotoBold.copyWith(
            fontSize: 20, color: Theme.of(context).primaryColor,
          )),*//*
          const SizedBox(height: 30),

          SupportButton(
            icon: Icons.location_on, title: 'address'.tr, color: Colors.blue,
            info: Get.find<SplashController>().configModel!.address,
            onTap: () {},
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SupportButton(
            icon: Icons.call, title: 'call'.tr, color: Colors.red,
            info: Get.find<SplashController>().configModel!.phone,
            onTap: () async {
              if(await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication);
              }else {
                showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
              }
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SupportButton(
            icon: Icons.mail_outline, title: 'email_us'.tr, color: Colors.green,
            info: Get.find<SplashController>().configModel!.email,
            onTap: () {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: Get.find<SplashController>().configModel!.email,
              );
              launchUrlString(emailLaunchUri.toString(), mode: LaunchMode.externalApplication);
            },
          ),

        ]))),
      )),*/
    );
  }

  Widget customCard(BuildContext context, {required Widget child}){
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor,
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).primaryColor.withOpacity(0.5),
              Theme.of(context).primaryColor,
            ],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          )
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: child,
      ),
    );
  }

  Widget element(BuildContext context,{required String image, required String title, required String subTitle, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(children: [
        Image.asset(image, height: 45, width: 45, fit: BoxFit.cover),

        Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
        Text(
          subTitle,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
        ),

      ]),
    );
  }
}
