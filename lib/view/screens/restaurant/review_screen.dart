import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/no_data_screen.dart';
import 'package:efood_multivendor/view/base/web_header_skeleton.dart';
import 'package:efood_multivendor/view/screens/restaurant/widget/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewScreen extends StatefulWidget {
  final String? restaurantID;
  const ReviewScreen({Key? key, required this.restaurantID}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<RestaurantController>().getRestaurantReviewList(widget.restaurantID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'restaurant_reviews'.tr),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return restController.restaurantReviewList != null ? restController.restaurantReviewList!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await restController.getRestaurantReviewList(widget.restaurantID);
          },
          child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                    childAspectRatio: (1/0.2), crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: restController.restaurantReviewList!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    return ReviewWidget(
                      review: restController.restaurantReviewList![index],
                      hasDivider: index != restController.restaurantReviewList!.length-1,
                    );
                  },
                ))),
              )),
        ) : Center(child: NoDataScreen(title: 'no_review_found'.tr)) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
