import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/web_page_title_widget.dart';
import 'package:efood_multivendor/view/screens/language/widget/language_widget.dart';
import 'package:efood_multivendor/view/screens/language/widget/web_language_widget.dart';
import 'package:flutter/material.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const ChooseLanguageScreen({Key? key, this.fromMenu = false}) : super(key: key);

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context)) ? CustomAppBar(title: 'language'.tr, isBackButtonExist: true) : null,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<LocalizationController>(builder: (localizationController) {
          return Column(children: [
            WebScreenTitleWidget(title: 'language'.tr),

            Expanded(child: Center(
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage(Images.languageBackground),)
                ),
                child: Scrollbar(
                  controller: scrollController,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall),
                    child: FooterView(
                      child: Center(child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                          !ResponsiveHelper.isDesktop(context) ? Column(children: [
                            Center(child: Image.asset(Images.logo, width: 60)),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Center(child: Image.asset(Images.logoName, width: 100)),
                          ]) : const SizedBox(),

                          //Center(child: Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE))),
                          const SizedBox(height: 30),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Text('select_language'.tr, style: robotoMedium),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 2 : ResponsiveHelper.isTab(context) ? 3 : 2,
                                childAspectRatio: ResponsiveHelper.isDesktop(context) ? 6 : (1/1),
                                mainAxisSpacing: Dimensions.paddingSizeDefault,
                                crossAxisSpacing: Dimensions.paddingSizeDefault,
                              ),
                              itemCount: localizationController.languages.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              itemBuilder: (context, index) => ResponsiveHelper.isDesktop(context) ? WebLanguageWidget(
                                languageModel: localizationController.languages[index],
                                localizationController: localizationController, index: index,
                              ) : LanguageWidget(
                                languageModel: localizationController.languages[index],
                                localizationController: localizationController, index: index,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          // ResponsiveHelper.isDesktop(context) ? LanguageSaveButton(localizationController: localizationController, fromMenu: widget.fromMenu) : const SizedBox(),

                        ]),
                      )),
                    ),
                  ),
                ),
              ),
            )),

            ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : LanguageSaveButton(localizationController: localizationController, fromMenu: widget.fromMenu),

          ]);
        }),
      ),
    );
  }
}

class LanguageSaveButton extends StatelessWidget {
  final LocalizationController localizationController;
  final bool? fromMenu;
  const LanguageSaveButton({Key? key, required this.localizationController, this.fromMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(
          child: Text(
            'you_can_change_language'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
        ),
      ),

      CustomButton(
        radius: 10,
        buttonText: 'save'.tr,
        margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        onPressed: () {
          if(localizationController.languages.isNotEmpty && localizationController.selectedIndex != -1) {
            localizationController.setLanguage(Locale(
              AppConstants.languages[localizationController.selectedIndex].languageCode!,
              AppConstants.languages[localizationController.selectedIndex].countryCode,
            ));
            if (fromMenu!) {
              Navigator.pop(context);
            } else {
              Get.offNamed(RouteHelper.getOnBoardingRoute());
            }
          }else {
            showCustomSnackBar('select_a_language'.tr);
          }
        },
      ),
    ]);
  }
}