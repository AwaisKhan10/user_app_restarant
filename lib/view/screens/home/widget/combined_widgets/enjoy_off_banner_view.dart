import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromotionalBannerView extends StatelessWidget {
  const PromotionalBannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Get.find<SplashController>().configModel!.bannerData != null ? Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.isMobile(context)  ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge,
        horizontal: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : 0,
      ),
      child: SizedBox(
        height: ResponsiveHelper.isMobile(context) ? 70 : 122, width: Dimensions.webMaxWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: CustomImage(
              placeholder: Images.placeholder,
              image: '${Get.find<SplashController>().configModel!.baseUrls!.bannerImageUrl}'
                  '/${Get.find<SplashController>().configModel!.bannerData!.promotionalBannerImage}',
              fit: BoxFit.fitWidth, width: ResponsiveHelper.isMobile(context) ? 70 : 122,
          ),
        ),
      ),
    ) : const SizedBox();
  }
}
