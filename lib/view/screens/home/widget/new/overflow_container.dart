
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverFlowContainer extends StatelessWidget {
  final String image;
  const OverFlowContainer({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      height: 30, width: 30,
      decoration:  BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CustomImage(
          image: '${Get.find<SplashController>().configModel!.baseUrls!.productImageUrl}/$image',
          fit: BoxFit.cover, height: 30, width: 30,
        ),
      ),
    );
  }
}
