// import 'package:efood_multivendor/controller/cuisine_controller.dart';
// import 'package:efood_multivendor/controller/splash_controller.dart';
// import 'package:efood_multivendor/controller/theme_controller.dart';
// import 'package:efood_multivendor/helper/route_helper.dart';
// import 'package:efood_multivendor/util/dimensions.dart';
// import 'package:efood_multivendor/util/styles.dart';
// import 'package:efood_multivendor/view/base/custom_image.dart';
// import 'package:efood_multivendor/view/base/hover/on_hover.dart';
// import 'package:efood_multivendor/view/base/title_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shimmer_animation/shimmer_animation.dart';
//
// class WebCuisineView extends StatelessWidget {
//   const WebCuisineView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final PageController pageController = PageController();
//     return GetBuilder<CuisineController>(builder: (cuisineController) {
//       return (cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isEmpty) ? const SizedBox() : Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
//             child: TitleWidget(
//               title: 'cuisines'.tr,
//               onTap: (){},
//             ),
//           ),
//
//           cuisineController.cuisineModel != null ? Column(
//             children: [
//
//               SizedBox(
//                 height: 170,
//                 child: Stack(
//                   clipBehavior: Clip.none,
//                   fit: StackFit.expand,
//                   children: [
//                     PageView.builder(
//                       controller: pageController,
//                       itemCount: (cuisineController.cuisineModel!.cuisines!.length/8).ceil(),
//                       onPageChanged: (int index) => cuisineController.setCurrentIndex(index, true),
//                       itemBuilder: (context, index) {
//                         int index1 = index * 8;
//                         int index2 = (index * 8) + 1;
//                         int index3 = (index * 8) + 2;
//                         int index4 = (index * 8) + 3;
//                         int index5 = (index * 8) + 4;
//                         int index6 = (index * 8) + 5;
//                         int index7 = (index * 8) + 6;
//                         int index8 = (index * 8) + 7;
//                         return Row(children: [
//
//                           Expanded(child: index1 < cuisineController.cuisineModel!.cuisines!.length
//                               ? webCuisineCart(context, index1, cuisineController) : const SizedBox()),
//                           const SizedBox(width: Dimensions.paddingSizeDefault),
//
//                           Expanded(child: index2 < cuisineController.cuisineModel!.cuisines!.length
//                               ? webCuisineCart(context, index2, cuisineController) : const SizedBox()),
//                           const SizedBox(width: Dimensions.paddingSizeDefault),
//
//                           Expanded(child: index3 < cuisineController.cuisineModel!.cuisines!.length
//                               ? webCuisineCart(context, index3, cuisineController) : const SizedBox()),
//                           const SizedBox(width: Dimensions.paddingSizeDefault),
//
//                           Expanded(child: index4 < cuisineController.cuisineModel!.cuisines!.length
//                               ? webCuisineCart(context, index4, cuisineController) : const SizedBox()),
//                           const SizedBox(width: Dimensions.paddingSizeDefault),
//
//                           Expanded(child: index5 < cuisineController.cuisineModel!.cuisines!.length
//                               ? webCuisineCart(context, index5, cuisineController) : const SizedBox()),
//                           const SizedBox(width: Dimensions.paddingSizeDefault),
//
//                           Expanded(child: index6 < cuisineController.cuisineModel!.cuisines!.length
//                               ? webCuisineCart(context, index6, cuisineController) : const SizedBox()),
//                           const SizedBox(width: Dimensions.paddingSizeDefault),
//
//                           Expanded(child: index7 < cuisineController.cuisineModel!.cuisines!.length
//                               ? webCuisineCart(context, index7, cuisineController) : const SizedBox()),
//                           const SizedBox(width: Dimensions.paddingSizeDefault),
//
//                           Expanded(child: index8 < cuisineController.cuisineModel!.cuisines!.length ?
//                           webCuisineCart(context, index8, cuisineController) : const SizedBox()),
//
//                         ]);
//                       },
//                     ),
//
//                     cuisineController.currentIndex != 0 ? Positioned(
//                       top: 0, bottom: 0, left: -20,
//                       child: InkWell(
//                         onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
//                         child: Container(
//                           height: 40, width: 40, alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle, color: Theme.of(context).cardColor,
//                           ),
//                           child: const Icon(Icons.arrow_back_ios),
//                         ),
//                       ),
//                     ) : const SizedBox(),
//
//                     cuisineController.currentIndex != ((cuisineController.cuisineModel!.cuisines!.length/8).ceil()-1) ? Positioned(
//                       top: 0, bottom: 0, right: -20,
//                       child: InkWell(
//                         onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
//                         child: Container(
//                           height: 40, width: 40, alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle, color: Theme.of(context).cardColor,
//                           ),
//                           child: const Icon(Icons.arrow_forward_ios_sharp),
//                         ),
//                       ),
//                     ) : const SizedBox(),
//                   ],
//                 ),
//               ),
//
//             ],
//           ) : WebCuisineShimmer(cuisineController: cuisineController),
//
//         ],
//       );
//     });
//   }
//
//   Widget webCuisineCart(BuildContext context, int index, CuisineController cuisineController) {
//     return Padding(
//       padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//       child: InkWell(
//         onTap: () =>  Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name)),
//         child: OnHover(
//           isItem: true,
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
//
//             Align(
//               alignment: Alignment.center,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(100),
//                 child: CustomImage(
//                   image: '${Get.find<SplashController>().configModel!.baseUrls!.cuisineImageUrl}'
//                       '/${cuisineController.cuisineModel!.cuisines![index].image}',
//                   height: 120, fit: BoxFit.cover, width: 120,
//                 ),
//               ),
//             ),
//
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
//                 child: Center(
//                   child: Text(
//                     cuisineController.cuisineModel!.cuisines![index].name!,
//                     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
//                     maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//
//           ]),
//         ),
//       ),
//     );
//   }
// }
//
// class WebCuisineShimmer extends StatelessWidget {
//   final CuisineController cuisineController;
//   const WebCuisineShimmer({Key? key, required this.cuisineController}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 8, childAspectRatio: 0.7,
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
//             enabled: cuisineController.cuisineModel == null,
//             child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
//
//               Container(
//                 height: 120, width: 120,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   // borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
//                   color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
//                 ),
//               ),
//
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Container(height: 15, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
//                     const SizedBox(height: 5),
//
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

