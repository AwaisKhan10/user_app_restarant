import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/banner_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/web_header.dart';
import 'package:efood_multivendor/view/screens/home/web/web_new/web_cuisine_view.dart';
import 'package:efood_multivendor/view/screens/home/web/web_new/web_new_on_stackfood_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/all_restaurant_filter_widget.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/all_restaurants.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/best_review_item_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/enjoy_off_banner_view.dart';
import 'package:efood_multivendor/view/screens/home/web/web_new/web_loaction_and_refer_banner_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/order_again_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/popular_foods_nearby_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/popular_restaurants_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/today_trends_view.dart';
import 'package:efood_multivendor/view/screens/home/web/web_banner_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/what_on_your_mind_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/bad_weather_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  const WebHomeScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  ConfigModel? _configModel;

  @override
  void initState() {
    super.initState();
    Get.find<BannerController>().setCurrentIndex(0, false);
    _configModel = Get.find<SplashController>().configModel;
  }

  @override
  Widget build(BuildContext context) {

    bool isLogin = Get.find<AuthController>().isLoggedIn();

    return CustomScrollView(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [

        const SliverToBoxAdapter(
          child: Center(child: SizedBox(width: Dimensions.webMaxWidth,
              child: WhatOnYourMindView()),
          ),
        ),

        SliverToBoxAdapter(child: GetBuilder<BannerController>(builder: (bannerController) {
          return bannerController.bannerImageList == null ? WebBannerView(bannerController: bannerController)
              : bannerController.bannerImageList!.isEmpty ? const SizedBox() : WebBannerView(bannerController: bannerController);
        })),


        SliverToBoxAdapter(
            child: Center(child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(children: [
                const BadWeatherWidget(),

                const TodayTrendsView(),

                isLogin ? const OrderAgainView() : const SizedBox(),

                _configModel!.popularFood == 1 ?  const BestReviewItemView(isPopular: false) : const SizedBox(),

                const WebCuisineView(),

                const PopularRestaurantsView(),

                const PopularFoodNearbyView(),

                isLogin ? const PopularRestaurantsView(isRecentlyViewed: true) : const SizedBox(),

                const WebLocationAndReferBannerView(),

                _configModel!.newRestaurant == 1 ? const WebNewOnStackFoodView(isLatest: true) : const SizedBox(),

                const PromotionalBannerView(),



                const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                // _configModel!.popularRestaurant == 1 ? const WebPopularRestaurantView(isPopular: true) : const SizedBox(),

                // const SizedBox(height: Dimensions.paddingSizeSmall),
                // const WebCampaignView(),

                //const WebCuisineView(),

                // _configModel!.popularFood == 1 ? const WebPopularFoodView(isPopular: true) : const SizedBox(),

                // isLogin ? const WebPopularRestaurantView(isPopular: false) : const SizedBox(),

                // _configModel!.newRestaurant == 1 ? const WebPopularRestaurantView(isPopular: false) : const SizedBox(),

                // _configModel!.mostReviewedFoods == 1 && isLogin ? const WebPopularRestaurantView(isPopular: false, isRecentlyViewed: true) : const SizedBox(),



              ]),
            ))
        ),


        SliverPersistentHeader(
          pinned: true,
          delegate: SliverDelegate(
            child: const AllRestaurantFilterWidget(),
          ),
        ),



        SliverToBoxAdapter(child: Center(child: Column(
          children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),

            FooterView(
              child: AllRestaurants(scrollController: widget.scrollController),
            ),
          ],
        ))),

      ],
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}
