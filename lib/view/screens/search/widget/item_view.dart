import 'package:efood_multivendor/controller/search_controller.dart' as search;
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/product_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemView extends StatelessWidget {
  final bool isRestaurant;
  const ItemView({Key? key, required this.isRestaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<search.SearchController>(builder: (searchController) {
        return SingleChildScrollView(
          child: FooterView(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: ProductView(
              isRestaurant: isRestaurant, products: searchController.searchProductList, restaurants: searchController.searchRestList,
            ))),
          ),
        );
      }),
    );
  }
}
