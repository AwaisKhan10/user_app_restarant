
import 'dart:math';

import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CuisineCard extends StatelessWidget {
  final String image;
  final String name;
  const CuisineCard({Key? key, required this.image, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)),
      child: Stack(
        children: [
          Positioned(bottom: ResponsiveHelper.isMobile(context) ? -75 : -55, left: 0, right: ResponsiveHelper.isMobile(context) ? -17 : 0,
            child: Transform.rotate(
              angle: 40,
              child: Container(
                height: ResponsiveHelper.isMobile(context) ? 132 : 120, width: ResponsiveHelper.isMobile(context) ? 150 : 120,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(decoration: BoxDecoration( color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CustomImage(image: image,
                    fit: BoxFit.cover, height: 100, width: 100),
              ),
            ),
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              alignment: Alignment.center,
              height: 30, width: 120,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]!, spreadRadius: 0.5, blurRadius: 0.5)],
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)),
              ),
              child: Text( name, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}