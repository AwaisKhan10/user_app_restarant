import 'package:carousel_slider/carousel_slider.dart';
import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/arrow_icon_button.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/item_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularFoodNearbyView extends StatefulWidget {
  const PopularFoodNearbyView({Key? key}) : super(key: key);

  @override
  State<PopularFoodNearbyView> createState() => _PopularFoodNearbyViewState();
}

class _PopularFoodNearbyViewState extends State<PopularFoodNearbyView> {

  CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (productController) {
        return (productController.popularProductList !=null && productController.popularProductList!.isEmpty) ? const SizedBox() : Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context)  ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
          child: SizedBox(
            height: ResponsiveHelper.isMobile(context) ? 300 : 330, width: Dimensions.webMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ResponsiveHelper.isDesktop(context) ?  Padding(
                  padding: const EdgeInsets.only(bottom: 45),
                  child: Text('popular_foods_nearby'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                ): Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeLarge),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('popular_foods_nearby'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    ArrowIconButton(onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(true))),
                  ],
                )),

                Row(children: [
                    ResponsiveHelper.isDesktop(context) ? ArrowIconButton(
                      isLeft: true,
                      onTap: ()=> carouselController.previousPage(),
                    ) : const SizedBox(),

                    productController.popularProductList !=null ? Expanded(
                      child: CarouselSlider.builder(
                        carouselController: carouselController,
                        options: CarouselOptions(
                          height: ResponsiveHelper.isMobile(context) ? 240 : 260,
                          viewportFraction: ResponsiveHelper.isDesktop(context) ? 0.2 : 0.55,
                          enlargeFactor: ResponsiveHelper.isDesktop(context) ? 0.2 : 0.25,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          disableCenter: true,
                          onPageChanged: (index, reason) {

                          },
                        ),
                        itemCount: productController.popularProductList!.length,
                        itemBuilder: (context, index, _) {

                          return SizedBox(
                            // height: 240, width: 190,
                            child: ItemCard(
                              product: productController.popularProductList![index],
                              isBestItem: true,
                              isPopularNearbyItem: true,
                            ),
                          );
                        },
                      ),
                    ) : const ItemCardShimmer(isPopularNearbyItem: true),

                    ResponsiveHelper.isDesktop(context) ? ArrowIconButton(
                      onTap: () => carouselController.nextPage(),
                    ) : const SizedBox(),
                  ],
                ),

             ],
            )
          ),
        );
      }
    );
  }
}
