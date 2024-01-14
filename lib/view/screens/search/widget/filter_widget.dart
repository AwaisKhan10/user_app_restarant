import 'package:efood_multivendor/controller/search_controller.dart' as search;
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/screens/search/widget/custom_check_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterWidget extends StatelessWidget {
  final double? maxValue;
  final bool isRestaurant;
  const FilterWidget({Key? key, required this.maxValue, required this.isRestaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      decoration: ResponsiveHelper.isMobile(context)? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
      ): null,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: GetBuilder<search.SearchController>(builder: (searchController) {
        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text('filter'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

            SizedBox(
              width: 50,
              child: Divider(
                color: Theme.of(context).disabledColor.withOpacity(0.5),
                thickness: 4,
              ),
            ),

            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(Icons.close, color: Theme.of(context).disabledColor),
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('sort_by'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  GridView.builder(
                    itemCount: searchController.sortList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                      childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          searchController.setSortIndex(index);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: searchController.sortIndex == index ? Colors.transparent
                                : Theme.of(context).disabledColor),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            color: searchController.sortIndex == index ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor.withOpacity(0.1),
                          ),
                          child: Text(
                            searchController.sortList[index],
                            textAlign: TextAlign.center,
                            style: robotoMedium.copyWith(
                              color: searchController.sortIndex == index ? Colors.white : Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text('filter_by'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Get.find<SplashController>().configModel!.toggleVegNonVeg! ? CustomCheckBox(
                    title: 'veg'.tr,
                    value: searchController.veg,
                    onClick: () => searchController.toggleVeg(),
                  ) : const SizedBox(),
                  Get.find<SplashController>().configModel!.toggleVegNonVeg! ? CustomCheckBox(
                    title: 'non_veg'.tr,
                    value: searchController.nonVeg,
                    onClick: () => searchController.toggleNonVeg(),
                  ) : const SizedBox(),
                  CustomCheckBox(
                    title: isRestaurant ? 'currently_opened_restaurants'.tr : 'currently_available_foods'.tr,
                    value: searchController.isAvailableFoods,
                    onClick: () {
                      searchController.toggleAvailableFoods();
                    },
                  ),
                  CustomCheckBox(
                    title: isRestaurant ? 'discounted_restaurants'.tr : 'discounted_foods'.tr,
                    value: searchController.isDiscountedFoods,
                    onClick: () {
                      searchController.toggleDiscountedFoods();
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  isRestaurant ? const SizedBox() : Column(children: [
                    Text('price'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    RangeSlider(
                      values: RangeValues(searchController.lowerValue, searchController.upperValue),
                      max: maxValue!.toInt().toDouble(),
                      min: 0,
                      divisions: maxValue!.toInt(),
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
                      labels: RangeLabels(searchController.lowerValue.toString(), searchController.upperValue.toString()),
                      onChanged: (RangeValues rangeValues) {
                        searchController.setLowerAndUpperValue(rangeValues.start, rangeValues.end);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ]),

                  Text('rating'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  Container(
                    height: 30, alignment: Alignment.center,
                    child: ListView.builder(
                      itemCount: 5,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => searchController.setRating(index + 1),
                          child: Icon(
                            searchController.rating < (index + 1) ? Icons.star_border : Icons.star,
                            size: 30,
                            color: searchController.rating < (index + 1) ? Theme.of(context).disabledColor
                                : Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          Row(children: [
              Expanded(
                flex: 1,
                child:  CustomButton(
                  color: Theme.of(context).disabledColor.withOpacity(0.5),
                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    searchController.resetFilter();
                  },
                  buttonText: 'reset'.tr,
                )),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                flex: 2,
                child: CustomButton(
                  buttonText: 'apply'.tr,
                  onPressed: () {
                    if(isRestaurant) {
                      searchController.sortRestSearchList();
                    }else {
                      searchController.sortFoodSearchList();
                    }
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ]);
      }),
    );
  }
}
