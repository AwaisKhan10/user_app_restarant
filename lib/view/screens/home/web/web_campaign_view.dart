import 'package:efood_multivendor/controller/campaign_controller.dart';
import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/discount_tag.dart';
import 'package:efood_multivendor/view/base/hover/on_hover.dart';
import 'package:efood_multivendor/view/base/not_available_widget.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:efood_multivendor/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebCampaignView extends StatelessWidget {
  const WebCampaignView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return GetBuilder<CampaignController>(builder: (campaignController) {
      return (campaignController.itemCampaignList != null && campaignController.itemCampaignList!.isEmpty) ? const SizedBox() : Row(children: [

        Container(
          height: 270, width: 275,
          decoration : BoxDecoration(
            color: const Color(0xFFEFF6FD),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), spreadRadius: 1, blurRadius: 5)],
          ),
          child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Image.asset(Images.nearRestaurantWeb, height: 111, width: 156, fit: BoxFit.cover),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              'find_restaurants_near_you'.tr, textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomButton(buttonText: 'see_location'.tr, width: 120, height: 40, isBold: false, fontSize: Dimensions.fontSizeExtraSmall, radius: Dimensions.radiusSmall,
              onPressed: ()=> Get.toNamed(RouteHelper.getMapViewRoute())),
            ],
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeLarge),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: TitleWidget(
                  title: 'trending_food_offers'.tr,
                  onTap: (){},
                ),
              ),

              // campaignController.itemCampaignList != null ?
              //     CustomWebSliderWidget(
              //       height: 235, weight: 700, productList: campaignController.itemCampaignList!,
              //       child: (context, index){
              //         print('--------sssss------: $index');
              //         double price = campaignController.itemCampaignList![index].price!;
              //         double discount = campaignController.itemCampaignList![index].discount!;
              //         double discountPrice = PriceConverter.convertWithDiscount(price, discount, campaignController.itemCampaignList![index].discountType)!;
              //
              //         return Padding(
              //           padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeExtraSmall),
              //           child: InkWell(
              //             onTap: () {
              //               ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
              //                 ProductBottomSheet(product: campaignController.itemCampaignList![index], isCampaign: true),
              //                 backgroundColor: Colors.transparent, isScrollControlled: true,
              //               ) : Get.dialog(
              //                 Dialog(child: ProductBottomSheet(product: campaignController.itemCampaignList![index], isCampaign: true)),
              //               );
              //             },
              //             child: OnHover(
              //               isItem: true,
              //               child: Container(
              //                 decoration: BoxDecoration(
              //                   color: Theme.of(context).cardColor,
              //                   borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              //                   border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.5)),
              //                   // boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
              //                 ),
              //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              //
              //                   Stack(children: [
              //                     ClipRRect(
              //                       borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
              //                       child: CustomImage(
              //                         image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}'
              //                             '/${campaignController.itemCampaignList![index].image}',
              //                         height: 135, fit: BoxFit.cover, width: context.width/4,
              //                       ),
              //                     ),
              //                     DiscountTag(
              //                       discount: campaignController.itemCampaignList![index].restaurantDiscount! > 0
              //                           ? campaignController.itemCampaignList![index].restaurantDiscount
              //                           : campaignController.itemCampaignList![index].discount,
              //                       discountType: campaignController.itemCampaignList![index].restaurantDiscount! > 0 ? 'percent'
              //                           : campaignController.itemCampaignList![index].discountType,
              //                       fromTop: Dimensions.paddingSizeLarge, fontSize: Dimensions.fontSizeExtraSmall,
              //                     ),
              //                     Get.find<ProductController>().isAvailable(campaignController.itemCampaignList![index])
              //                         ? const SizedBox() : const NotAvailableWidget(),
              //                   ]),
              //
              //                   Expanded(
              //                     child: Padding(
              //                       padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              //                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              //                         Text(
              //                           campaignController.itemCampaignList![index].name!,
              //                           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              //                           maxLines: 2, overflow: TextOverflow.ellipsis,
              //                         ),
              //                         const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              //
              //                         Text(
              //                           campaignController.itemCampaignList![index].restaurantName!,
              //                           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
              //                           maxLines: 1, overflow: TextOverflow.ellipsis,
              //                         ),
              //                         const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              //
              //                         Row(
              //                           children: [
              //                             Expanded(
              //                               child: Row(children: [
              //                                 Text(
              //                                   PriceConverter.convertPrice(discountPrice),
              //                                   style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
              //                                 ),
              //
              //                                 discountPrice < price ? Text(
              //                                   PriceConverter.convertPrice(price), textDirection: TextDirection.ltr,
              //                                   style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
              //                                 ) : const SizedBox(),
              //                               ]),
              //                             ),
              //                             Icon(Icons.star, color: Theme.of(context).primaryColor, size: 12),
              //                             Text(
              //                               campaignController.itemCampaignList![index].avgRating!.toStringAsFixed(1),
              //                               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              //                             ),
              //                           ],
              //                         ),
              //                       ]),
              //                     ),
              //                   ),
              //
              //                 ]),
              //               ),
              //             ),
              //           ),
              //         );
              //       },
              //     ) : WebPopularFoodShimmer(campaignController: campaignController),

              campaignController.itemCampaignList != null ? Column(
                children: [

                  SizedBox(
                    height: 235,
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: pageController,
                          itemCount: (campaignController.itemCampaignList!.length/4).ceil(),
                          onPageChanged: (int index) => campaignController.setCurrentIndex(index, true),
                          itemBuilder: (context, index) {
                            int index1 = index * 4;
                            int index2 = (index * 4) + 1;
                            int index3 = (index * 4) + 2;
                            int index4 = (index * 4) + 3;
                            bool hasSecond = index4 < campaignController.itemCampaignList!.length;
                            return Row(children: [

                              Expanded(child: campaignCart(context, index1, campaignController)),
                              const SizedBox(width: Dimensions.paddingSizeDefault),

                              Expanded(child: campaignCart(context, index2, campaignController)),
                              const SizedBox(width: Dimensions.paddingSizeDefault),

                              Expanded(child: campaignCart(context, index3, campaignController)),

                              const SizedBox(width: Dimensions.paddingSizeDefault),

                              Expanded(child: hasSecond ? campaignCart(context, index4, campaignController) : const SizedBox()),

                            ]);
                          },
                        ),

                        campaignController.currentIndex != 0 ? Positioned(
                          top: 0, bottom: 0, left: 0,
                          child: InkWell(
                            onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                            child: Container(
                              height: 40, width: 40, alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Theme.of(context).cardColor,
                              ),
                              child: const Icon(Icons.arrow_back_ios),
                            ),
                          ),
                        ) : const SizedBox(),

                        campaignController.currentIndex != ((campaignController.itemCampaignList!.length/4).ceil()-1) ? Positioned(
                          top: 0, bottom: 0, right: 0,
                          child: InkWell(
                            onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                            child: Container(
                              height: 40, width: 40, alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Theme.of(context).cardColor,
                              ),
                              child: const Icon(Icons.arrow_forward_ios_sharp),
                            ),
                          ),
                        ) : const SizedBox(),
                      ],
                    ),
                  ),

                ],
              ) : WebPopularFoodShimmer(campaignController: campaignController),

            ],
          ),
        )

      ]);
    });
  }
}

Widget campaignCart(BuildContext context, int index, CampaignController campaignController) {
  double price = campaignController.itemCampaignList![index].price!;
  double discount = campaignController.itemCampaignList![index].discount!;
  double discountPrice = PriceConverter.convertWithDiscount(price, discount, campaignController.itemCampaignList![index].discountType)!;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeExtraSmall),
    child: InkWell(
      onTap: () {
        ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
          ProductBottomSheet(product: campaignController.itemCampaignList![index], isCampaign: true),
          backgroundColor: Colors.transparent, isScrollControlled: true,
        ) : Get.dialog(
          Dialog(child: ProductBottomSheet(product: campaignController.itemCampaignList![index], isCampaign: true)),
        );
      },
      child: OnHover(
        isItem: true,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.all(1),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

            Stack(children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                child: CustomImage(
                  image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}'
                      '/${campaignController.itemCampaignList![index].image}',
                  height: 135, fit: BoxFit.cover, width: context.width/4,
                ),
              ),
              DiscountTag(
                discount: campaignController.itemCampaignList![index].restaurantDiscount! > 0
                    ? campaignController.itemCampaignList![index].restaurantDiscount
                    : campaignController.itemCampaignList![index].discount,
                discountType: campaignController.itemCampaignList![index].restaurantDiscount! > 0 ? 'percent'
                    : campaignController.itemCampaignList![index].discountType,
                fromTop: Dimensions.paddingSizeLarge, fontSize: Dimensions.fontSizeExtraSmall,
              ),
              Get.find<ProductController>().isAvailable(campaignController.itemCampaignList![index])
                  ? const SizedBox() : const NotAvailableWidget(),
            ]),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    campaignController.itemCampaignList![index].name!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    campaignController.itemCampaignList![index].restaurantName!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(
                    children: [
                      Expanded(
                        child: Row(children: [
                          Text(
                            PriceConverter.convertPrice(discountPrice),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                          ),

                          discountPrice < price ? Text(
                            PriceConverter.convertPrice(price), textDirection: TextDirection.ltr,
                            style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                          ) : const SizedBox(),
                        ]),
                      ),
                      Icon(Icons.star, color: Theme.of(context).primaryColor, size: 12),
                      Text(
                        campaignController.itemCampaignList![index].avgRating!.toStringAsFixed(1),
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ]),
              ),
            ),

          ]),
        ),
      ),
    ),
  );
}

class WebPopularFoodShimmer extends StatelessWidget {
  final CampaignController campaignController;
  const WebPopularFoodShimmer({Key? key, required this.campaignController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: (1/1.1),
        mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      itemCount: 4,
      itemBuilder: (context, index){
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: campaignController.itemCampaignList == null,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 135,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                  color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 15, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                    const SizedBox(height: 5),

                    Container(height: 10, width: 130, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                    const SizedBox(height: 5),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(height: 10, width: 30, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                      const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                    ]),
                  ]),
                ),
              ),

            ]),
          ),
        );
      },
    );
  }
}



/// Previous code
// import 'package:efood_multivendor/controller/campaign_controller.dart';
// import 'package:efood_multivendor/controller/product_controller.dart';
// import 'package:efood_multivendor/controller/splash_controller.dart';
// import 'package:efood_multivendor/controller/theme_controller.dart';
// import 'package:efood_multivendor/helper/price_converter.dart';
// import 'package:efood_multivendor/helper/responsive_helper.dart';
// import 'package:efood_multivendor/helper/route_helper.dart';
// import 'package:efood_multivendor/util/dimensions.dart';
// import 'package:efood_multivendor/util/styles.dart';
// import 'package:efood_multivendor/view/base/custom_image.dart';
// import 'package:efood_multivendor/view/base/discount_tag.dart';
// import 'package:efood_multivendor/view/base/not_available_widget.dart';
// import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
// import 'package:efood_multivendor/view/base/rating_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shimmer_animation/shimmer_animation.dart';
//
// class WebCampaignView extends StatelessWidget {
//   const WebCampaignView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CampaignController>(builder: (campaignController) {
//       return (campaignController.itemCampaignList != null && campaignController.itemCampaignList!.isEmpty) ? const SizedBox() : Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
//             child: Text('trending_food_offers'.tr, style: robotoMedium.copyWith(fontSize: 24)),
//           ),
//
//           campaignController.itemCampaignList != null ? GridView.builder(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4, childAspectRatio: (1/1.1),
//               mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
//             ),
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//             itemCount: campaignController.itemCampaignList!.length > 3 ? 4 : campaignController.itemCampaignList!.length,
//             itemBuilder: (context, index){
//               double price = campaignController.itemCampaignList![index].price!;
//               double discount = campaignController.itemCampaignList![index].discount!;
//               double discountPrice = PriceConverter.convertWithDiscount(price, discount, campaignController.itemCampaignList![index].discountType)!;
//               if(index == 3) {
//                 return InkWell(
//                   onTap: () => Get.toNamed(RouteHelper.getItemCampaignRoute()),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).primaryColor,
//                       borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                       boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
//                     ),
//                     alignment: Alignment.center,
//                     child: Text(
//                       '+${campaignController.itemCampaignList!.length-3}\n${'more'.tr}', textAlign: TextAlign.center,
//                       style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
//                     ),
//                   ),
//                 );
//               }
//
//               return InkWell(
//                 onTap: () {
//                   ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
//                     ProductBottomSheet(product: campaignController.itemCampaignList![index], isCampaign: true),
//                     backgroundColor: Colors.transparent, isScrollControlled: true,
//                   ) : Get.dialog(
//                     Dialog(child: ProductBottomSheet(product: campaignController.itemCampaignList![index], isCampaign: true)),
//                   );
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                     boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
//                   ),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
//
//                     Stack(children: [
//                       ClipRRect(
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
//                         child: CustomImage(
//                           image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}'
//                               '/${campaignController.itemCampaignList![index].image}',
//                           height: 135, fit: BoxFit.cover, width: context.width/4,
//                         ),
//                       ),
//                       DiscountTag(
//                         discount: campaignController.itemCampaignList![index].restaurantDiscount! > 0
//                             ? campaignController.itemCampaignList![index].restaurantDiscount
//                             : campaignController.itemCampaignList![index].discount,
//                         discountType: campaignController.itemCampaignList![index].restaurantDiscount! > 0 ? 'percent'
//                             : campaignController.itemCampaignList![index].discountType,
//                         fromTop: Dimensions.paddingSizeLarge, fontSize: Dimensions.fontSizeExtraSmall,
//                       ),
//                       Get.find<ProductController>().isAvailable(campaignController.itemCampaignList![index])
//                           ? const SizedBox() : const NotAvailableWidget(),
//                     ]),
//
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
//                         child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
//                           Text(
//                             campaignController.itemCampaignList![index].name!,
//                             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
//                             maxLines: 2, overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//
//                           Text(
//                             campaignController.itemCampaignList![index].restaurantName!,
//                             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
//                             maxLines: 1, overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Row(children: [
//                                   Text(
//                                     PriceConverter.convertPrice(discountPrice),
//                                     style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
//                                   ),
//
//                                   discountPrice < price ? Text(
//                                     PriceConverter.convertPrice(price), textDirection: TextDirection.ltr,
//                                     style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
//                                   ) : const SizedBox(),
//                                 ]),
//                               ),
//                               Icon(Icons.star, color: Theme.of(context).primaryColor, size: 12),
//                               Text(
//                                 campaignController.itemCampaignList![index].avgRating!.toStringAsFixed(1),
//                                 style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
//                               ),
//                             ],
//                           ),
//                         ]),
//                       ),
//                     ),
//
//                   ]),
//                 ),
//               );
//             },
//           ) : WebPopularFoodShimmer(campaignController: campaignController),
//         ],
//       );
//     });
//   }
// }
//
// class WebPopularFoodShimmer extends StatelessWidget {
//   final CampaignController campaignController;
//   const WebPopularFoodShimmer({Key? key, required this.campaignController}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4, childAspectRatio: (1/1.1),
//         mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
//       ),
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//       itemCount: 8,
//       itemBuilder: (context, index){
//         return Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//           ),
//           child: Shimmer(
//             duration: const Duration(seconds: 2),
//             enabled: campaignController.itemCampaignList == null,
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//               Container(
//                 height: 135,
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
//                   color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
//                 ),
//               ),
//
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Container(height: 15, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
//                     const SizedBox(height: 5),
//
//                     Container(height: 10, width: 130, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
//                     const SizedBox(height: 5),
//
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                       Container(height: 10, width: 30, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
//                       const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
//                     ]),
//                   ]),
//                 ),
//               ),
//
//             ]),
//           ),
//         );
//       },
//     );
//   }
// }
