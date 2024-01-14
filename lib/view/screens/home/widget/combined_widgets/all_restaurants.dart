import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/view/base/paginated_list_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/restaurants_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AllRestaurants extends StatelessWidget {
  final ScrollController scrollController;
  const AllRestaurants({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      return PaginatedListView(
        scrollController: scrollController,
        totalSize: restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : null,
        offset: restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.offset : null,
        onPaginate: (int? offset) async => await restaurantController.getRestaurantList(offset!, false),
        productView: RestaurantsView(restaurants: restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.restaurants : null),
      );
    });
  }
}
