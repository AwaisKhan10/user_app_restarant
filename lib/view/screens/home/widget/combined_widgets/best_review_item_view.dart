import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/arrow_icon_button.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/item_card.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BestReviewItemView extends StatelessWidget {
  final bool isPopular;
  const BestReviewItemView({Key? key, required this.isPopular}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelect = false;
    return GetBuilder<ProductController>(builder: (productController) {
        return (productController.reviewedProductList !=null && productController.reviewedProductList!.isEmpty) ? const SizedBox() : Padding(
          padding:  EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context)  ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
          child: SizedBox(
            height: ResponsiveHelper.isMobile(context) ? 300 : 315, width: Dimensions.webMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                  child: Row(children: [
                      Text('best_review_item'.tr, style: robotoMedium.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),

                      const Spacer(),

                      ArrowIconButton(
                        onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(isPopular)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),


              productController.reviewedProductList !=null ? Expanded(
                  child: SizedBox(
                    height: ResponsiveHelper.isMobile(context) ? 240 : 255,
                    child: ListView.builder(
                      itemCount: productController.reviewedProductList!.length,
                      padding: EdgeInsets.only(right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr) ? 0 : Dimensions.paddingSizeDefault),
                          child: ItemCard(
                            isBestItem: true, product: productController.reviewedProductList![index],
                          ),
                        );
                      },
                    ),
                  ),
                ) : const ItemCardShimmer(isPopularNearbyItem: false),
              ],
            ),

          ),
        );
      }
    );
  }
}
