import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/product_view.dart';
import 'package:efood_multivendor/view/base/web_header_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularFoodScreen extends StatefulWidget {
  final bool isPopular;
  final bool fromIsRestaurantFood;
  final int? restaurantId;
  const PopularFoodScreen({Key? key, required this.isPopular, required this.fromIsRestaurantFood, this.restaurantId}) : super(key: key);

  @override
  State<PopularFoodScreen> createState() => _PopularFoodScreenState();
}

class _PopularFoodScreenState extends State<PopularFoodScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if(widget.isPopular) {
      Get.find<ProductController>().getPopularProductList(true, Get.find<ProductController>().popularType, false);
    } else if(widget.fromIsRestaurantFood) {
      Get.find<RestaurantController>().getRestaurantRecommendedItemList(widget.restaurantId, false);
    } else {
      Get.find<ProductController>().getReviewedProductList(true, Get.find<ProductController>().reviewType, false);
    }
  }
  @override
  Widget build(BuildContext context) {

    return GetBuilder<ProductController>(
      builder: (productController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: widget.isPopular ? widget.fromIsRestaurantFood? 'popular_in_this_restaurant'.tr : 'popular_foods_nearby'.tr : 'best_reviewed_food'.tr,
            showCart: true,
            type: widget.isPopular ? productController.popularType : productController.reviewType,
            onVegFilterTap: widget.fromIsRestaurantFood ? null : (String type) {
              if(widget.isPopular) {
                productController.getPopularProductList(true, type, true);
              }else {
                productController.getReviewedProductList(true, type, true);
              }
            },
          ),
          endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
          body: Scrollbar(controller: scrollController, child: SingleChildScrollView(controller: scrollController, child: FooterView(
            child: Center(child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: GetBuilder<ProductController>(builder: (productController) {
                return GetBuilder<RestaurantController>(
                    builder: (restaurantController) {

                      return ProductView(
                        isRestaurant: false, restaurants: null,
                        products: widget.isPopular ? productController.popularProductList : widget.fromIsRestaurantFood ? restaurantController.recommendedProductModel?.products : productController.reviewedProductList,
                      );
                    }
                );
              }),
            )),
          ))),
        );
      }
    );
  }
}
