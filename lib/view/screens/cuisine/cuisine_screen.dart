import 'package:efood_multivendor/controller/cuisine_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/web_header.dart';
import 'package:efood_multivendor/view/base/web_page_title_widget.dart';
import 'package:efood_multivendor/view/screens/home/widget/new/cuisine_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class CuisineScreen extends StatefulWidget {
  const CuisineScreen({Key? key}) : super(key: key);

  @override
  State<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Get.find<CuisineController>().getCuisineList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'cuisines'.tr),
      backgroundColor: Theme.of(context).colorScheme.background,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              WebScreenTitleWidget(title: 'cuisines'.tr),

              Center(child: FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          await Get.find<CuisineController>().getCuisineList();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault, right: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault),
                          child: GetBuilder<CuisineController>(
                              builder: (cuisineController) {
                                return cuisineController.cuisineModel != null ? GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: ResponsiveHelper.isMobile(context) ? 4 : ResponsiveHelper.isDesktop(context) ? 8 : 6,
                                        mainAxisSpacing: Dimensions.paddingSizeDefault,
                                        crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 35 : Dimensions.paddingSizeDefault,
                                        childAspectRatio: 1
                                    ),
                                    shrinkWrap: true,
                                    itemCount: cuisineController.cuisineModel!.cuisines!.length,
                                    scrollDirection: Axis.vertical,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index){
                                      return InkWell(
                                        hoverColor: Colors.transparent,
                                        onTap: (){
                                          Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name));
                                        },
                                        child: SizedBox(
                                          height: 130,
                                          child: CuisineCard(
                                            image: '${Get.find<SplashController>().configModel!.baseUrls!.cuisineImageUrl}/${cuisineController.cuisineModel!.cuisines![index].image}',
                                            name: cuisineController.cuisineModel!.cuisines![index].name!,
                                          ),
                                        ),
                                      );
                                    }) : const Center(child: CircularProgressIndicator());
                              }
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
