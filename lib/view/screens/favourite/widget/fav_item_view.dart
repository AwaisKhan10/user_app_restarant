import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/product_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavItemView extends StatelessWidget {
  final bool isRestaurant;
  const FavItemView({Key? key, required this.isRestaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<WishListController>(builder: (wishController) {
        return (wishController.wishProductList != null && wishController.wishRestList != null) ? RefreshIndicator(
          onRefresh: () async {
            await wishController.getWishList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(child: SizedBox(
              width: Dimensions.webMaxWidth, child:  ProductView(
                isRestaurant: isRestaurant, products: wishController.wishProductList, restaurants: wishController.wishRestList,
                noDataText: 'no_wish_data_found'.tr,
              ),
            )),
          ),
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
