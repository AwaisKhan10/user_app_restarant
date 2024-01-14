import 'package:efood_multivendor/controller/category_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/hover/on_hover.dart';
import 'package:efood_multivendor/view/base/hover/text_hover.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


class WebCategoryView extends StatelessWidget {
  const WebCategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
      builder: (categoryController) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: EdgeInsets.only(
              top: Dimensions.paddingSizeLarge,
              left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeExtraSmall : 0,
              right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeExtraSmall,
              bottom: Dimensions.paddingSizeSmall,
            ),
            child: Text('categories'.tr, style: robotoMedium.copyWith(fontSize: 24)),
          ),

          SizedBox(
            height: 170,
            child: categoryController.categoryList != null ? ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
              itemCount: categoryController.categoryList!.length > 9 ? 10 : categoryController.categoryList!.length,
              itemBuilder: (context, index) {

                if(index == 9) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
                      child: TextHover(
                        builder: (hovered) {
                          return Container(
                            width: 108,
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            // margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                            child: Column(children: [

                              Container(
                                height: 80, width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Icon(Icons.arrow_forward, color: Theme.of(context).cardColor),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Text(
                                'view_all'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: hovered ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor,
                                ),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),

                            ]),
                          );
                        }
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                      categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                    )),
                    child: OnHover(
                      isItem: true,
                      child: TextHover(
                        builder: (hovered) {
                          return Container(
                            width: 108,
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                            ),
                            child: Column(children: [

                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 0.5)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: CustomImage(
                                    image: '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.categoryList![index].image}',
                                    height: 80, width: double.infinity, fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Expanded(child: Text(
                                categoryController.categoryList![index].name!,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: hovered ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor,
                                ),
                                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                              )),

                            ]),
                          );
                        }
                      ),
                    ),
                  ),
                );
              },
            ) : WebCategoryShimmer(categoryController: categoryController),
          ),

        ]);
      }
    );
  }
}

class WebCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const WebCategoryShimmer({Key? key, required this.categoryController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
            child: Container(
              width: 108,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              child: Shimmer(
                duration: const Duration(seconds: 2),
                enabled: categoryController.categoryList == null,
                child: Column(children: [

                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
                    height: 80, width: 70,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(height: 15, width: 150, color: Colors.grey[300]),

                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}


// class WebCategoryView extends StatelessWidget {
//   const WebCategoryView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CategoryController>(builder: (categoryController) {
//       return (categoryController.categoryList != null && categoryController.categoryList!.isEmpty) ? const SizedBox() : Container(
//         width: 250,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusSmall)),
//           boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
//         ),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//           Padding(
//             padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
//             child: Text('categories'.tr, style: robotoMedium.copyWith(fontSize: 24)),
//           ),
//           const SizedBox(height: Dimensions.paddingSizeDefault),
//
//           categoryController.categoryList != null ? ListView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             itemCount: categoryController.categoryList!.length > 10 ? 11 : categoryController.categoryList!.length,
//             itemBuilder: (context, index) {
//
//               if(index == 10) {
//                 return InkWell(
//                   onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
//                   child: Container(
//                     padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                     color: Theme.of(context).primaryColor.withOpacity(0.1),
//                     margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//                     child: Row(children: [
//
//                       Container(
//                         height: 65, width: 70,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                           color: Theme.of(context).primaryColor,
//                         ),
//                         child: Icon(Icons.arrow_downward, color: Theme.of(context).cardColor),
//                       ),
//                       const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                       Text(
//                         'view_all'.tr,
//                         style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
//                         maxLines: 2, overflow: TextOverflow.ellipsis,
//                       ),
//
//                     ]),
//                   ),
//                 );
//               }
//
//               return InkWell(
//                 onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
//                   categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
//                 )),
//                 child: Container(
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                   color: Theme.of(context).primaryColor.withOpacity(0.1),
//                   margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//                   child: Row(children: [
//
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                       child: CustomImage(
//                         image: '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.categoryList![index].image}',
//                         height: 65, width: 70, fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                     Expanded(child: Text(
//                       categoryController.categoryList![index].name!,
//                       style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
//                       maxLines: 2, overflow: TextOverflow.ellipsis,
//                     )),
//
//                   ]),
//                 ),
//               );
//             },
//           ) : WebCategoryShimmer(categoryController: categoryController),
//
//         ]),
//       );
//     });
//   }
// }
//
// class WebCategoryShimmer extends StatelessWidget {
//   final CategoryController categoryController;
//   const WebCategoryShimmer({Key? key, required this.categoryController}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: 5,
//       itemBuilder: (context, index) {
//         return Container(
//           padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//           color: Theme.of(context).primaryColor.withOpacity(0.1),
//           margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//           child: Shimmer(
//             duration: const Duration(seconds: 2),
//             enabled: categoryController.categoryList == null,
//             child: Row(children: [
//
//               Container(
//                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
//                 height: 65, width: 70,
//               ),
//               const SizedBox(width: Dimensions.paddingSizeSmall),
//
//               Container(height: 15, width: 150, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
//
//             ]),
//           ),
//         );
//       },
//     );
//   }
// }

