import 'package:efood_multivendor/controller/banner_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/data/model/response/basic_campaign_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/screens/restaurant/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebBannerView extends StatelessWidget {
  final BannerController bannerController;
  const WebBannerView({Key? key, required this.bannerController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Container(
      color: const Color(0xFF171A29),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(width: 1210, height: 225, child: bannerController.bannerImageList != null ? Stack(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: PageView.builder(
                  controller: pageController,
                  itemCount: (bannerController.bannerImageList!.length/2).ceil(),
                  itemBuilder: (context, index) {
                    int index1 = index * 2;
                    int index2 = (index * 2) + 1;
                    bool hasSecond = index2 < bannerController.bannerImageList!.length;
                    String? baseUrl1 = bannerController.bannerDataList![index1] is BasicCampaignModel ? Get.find<SplashController>()
                        .configModel!.baseUrls!.campaignImageUrl : Get.find<SplashController>().configModel!.baseUrls!.bannerImageUrl;
                    String? baseUrl2 = hasSecond ? bannerController.bannerDataList![index2] is BasicCampaignModel ? Get.find<SplashController>()
                        .configModel!.baseUrls!.campaignImageUrl : Get.find<SplashController>().configModel!.baseUrls!.bannerImageUrl : '';
                    return Row(children: [

                      Expanded(child: InkWell(
                        onTap: () => _onTap(index1, context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '$baseUrl1/${bannerController.bannerImageList![index1]}', fit: BoxFit.cover, height: 220,
                          ),
                        ),
                      )),

                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: hasSecond ? InkWell(
                        onTap: () => _onTap(index2, context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '$baseUrl2/${bannerController.bannerImageList![index2]}', fit: BoxFit.cover, height: 220,
                          ),
                        ),
                      ) : const SizedBox()),

                    ]);
                  },
                  onPageChanged: (int index) => bannerController.setCurrentIndex(index, true),
                ),
              ),

              bannerController.currentIndex != 0 ? Positioned(
                top: 0, bottom: 0, left: 0,
                child: InkWell(
                  onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Theme.of(context).cardColor,
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
              ) : const SizedBox(),

              bannerController.currentIndex != ((bannerController.bannerImageList!.length/2).ceil()-1) ? Positioned(
                top: 0, bottom: 0, right: 0,
                child: InkWell(
                  onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Theme.of(context).cardColor,
                    ),
                    child: const Icon(Icons.arrow_forward),
                  ),
                ),
              ) : const SizedBox(),
            ],
          ) : WebBannerShimmer(bannerController: bannerController)),


          const SizedBox(height: Dimensions.paddingSizeLarge),
          bannerController.bannerImageList != null ? Builder(
              builder: (context) {
                List<String> finalBanner = [];
                for(int i=0; i<bannerController.bannerImageList!.length; i++){
                  if(i%2==0){
                    finalBanner.add(bannerController.bannerImageList![i]!);
                  }
                }
                int totalBanner = bannerController.bannerImageList!.length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: finalBanner.map((bnr) {
                    int index = finalBanner.indexOf(bnr);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: index == bannerController.currentIndex ? Container(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        child: Text('${(index*2) + 2}/$totalBanner', style: robotoRegular.copyWith(color: Colors.white, fontSize: 12)),
                      ) : Container(
                        height: 4.18, width: 5.57,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.5), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                      ),
                    );
                  }).toList(),
                );
              }
          ) : const SizedBox(),

        ],
      ),
    );
  }

  void _onTap(int index, BuildContext context) {
    if(bannerController.bannerDataList![index] is Product) {
      Product? product = bannerController.bannerDataList![index];
      ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (con) => ProductBottomSheet(product: product),
      ) : showDialog(context: context, builder: (con) => Dialog(
          child: ProductBottomSheet(product: product)),
      );
    }else if(bannerController.bannerDataList![index] is Restaurant) {
      Restaurant restaurant = bannerController.bannerDataList![index];
      Get.toNamed(
        RouteHelper.getRestaurantRoute(restaurant.id),
        arguments: RestaurantScreen(restaurant: restaurant),
      );
    }else if(bannerController.bannerDataList![index] is BasicCampaignModel) {
      BasicCampaignModel campaign = bannerController.bannerDataList![index];
      Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
    }
  }
}

class WebBannerShimmer extends StatelessWidget {
  final BannerController bannerController;
  const WebBannerShimmer({Key? key, required this.bannerController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: bannerController.bannerImageList == null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Row(children: [

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
          )),

          const SizedBox(width: Dimensions.paddingSizeLarge),

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
          )),

        ]),
      ),
    );
  }
}

