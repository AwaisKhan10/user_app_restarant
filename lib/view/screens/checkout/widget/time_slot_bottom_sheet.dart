
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/helper/checkout_helper.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TimeSlotBottomSheet extends StatefulWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  final Restaurant restaurant;
  const TimeSlotBottomSheet({Key? key, required this.tomorrowClosed, required this.todayClosed, required this.restaurant}) : super(key: key);

  @override
  State<TimeSlotBottomSheet> createState() => _TimeSlotBottomSheetState();
}

class _TimeSlotBottomSheetState extends State<TimeSlotBottomSheet> {
  bool _instanceOrder = false;
  @override
  void initState() {
    super.initState();
    _instanceOrder = (Get.find<SplashController>().configModel!.instantOrder! && widget.restaurant.instantOrder!);
    Get.find<OrderController>().setCustomDate(null, false, canUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isRestaurantSelfDeliveryOn = widget.restaurant.selfDeliverySystem == 1;

    return Container(
      width: context.width,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            !ResponsiveHelper.isDesktop(context) ? Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: ()=> Get.back(),
                child: Container(
                  height: 4, width: 35,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ) : const SizedBox(),

            Flexible(
              child: SingleChildScrollView(
                padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
                child: GetBuilder<OrderController>(
                    builder: (orderController) {
                      return GetBuilder<RestaurantController>(
                        builder: (restaurantController) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                            SizedBox(
                              width: isDesktop ? 300 : double.infinity,
                              child: Row(children: [
                                Expanded(
                                  child: tobView(context:context, title: 'today'.tr, isSelected: orderController.selectedDateSlot == 0, onTap: (){
                                    orderController.updateDateSlot(0, DateTime.now(), _instanceOrder);
                                  }),
                                ),

                                Expanded(
                                  child: tobView(context:context, title: 'tomorrow'.tr, isSelected: orderController.selectedDateSlot == 1, onTap: (){
                                    orderController.updateDateSlot(1, DateTime.now().add(const Duration(days: 1)), true);
                                  }),
                                ),

                               (isRestaurantSelfDeliveryOn ? widget.restaurant.customerDateOrderStatus! : Get.find<SplashController>().configModel!.customerDateOrderStatus!) ? Expanded(
                                  child: tobView(context:context, title: 'custom_date'.tr, isSelected: orderController.selectedDateSlot == 2, onTap: (){
                                    orderController.updateDateSlot(2, DateTime.now(), _instanceOrder);
                                    Get.find<OrderController>().setCustomDate(null, false, canUpdate: false);
                                  }),
                                ) : const SizedBox(),
                              ]),
                            ),
                            SizedBox(height: isDesktop ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge),

                            orderController.selectedDateSlot == 2 ? Column(children: [
                              Center(child: Text('set_date_and_time'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
                              const SizedBox(height: Dimensions.paddingSizeLarge),

                              SfDateRangePicker(
                                initialSelectedDate: DateTime.now(),
                                selectionShape: DateRangePickerSelectionShape.rectangle,
                                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                                  DateTime selectedDate = DateConverter.dateTimeStringToDate(args.value.toString());
                                  DateTime now = DateTime.now();
                                  print('======ssss====> $selectedDate == ${DateTime(now.year, now.month, now.day)}');
                                  orderController.setDateCloseRestaurant(restaurantController.isRestaurantClosed(
                                    selectedDate, restaurantController.restaurant!.active!,
                                    restaurantController.restaurant!.schedules,
                                  ));
                                  orderController.updateDateSlot(2, selectedDate, _instanceOrder, fromCustomDate: true);
                                  orderController.setCustomDate(selectedDate, _instanceOrder && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).isAtSameMomentAs(orderController.selectedCustomDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));

                                },
                                showNavigationArrow: true,
                                selectableDayPredicate: (DateTime val) {
                                 return CheckoutHelper.canSelectDate(duration: isRestaurantSelfDeliveryOn ? widget.restaurant.customerOrderDate! : Get.find<SplashController>().configModel!.customerOrderDate!, value: val);
                                }
                              ),

                              Builder(
                                builder: (context) {
                                  print('=======hhh : ${orderController.selectedTimeSlot} / ${orderController.preferableTime} / ${orderController.canShowTimeSlot}');
                                  return SizedBox(
                                    height: 50,
                                    child: (orderController.selectedDateSlot == 2 && orderController.customDateRestaurantClose)
                                    ? Center(child: Text('restaurant_is_closed'.tr )) : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: orderController.timeSlots!.length,
                                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                        itemBuilder: (context, index) {
                                      String time = (index == 0 && orderController.selectedDateSlot == 2
                                          && restaurantController.isRestaurantOpenNow(restaurantController.restaurant!.active!, restaurantController.restaurant!.schedules)
                                          && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).isAtSameMomentAs(orderController.selectedCustomDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                          ? _instanceOrder
                                          ? 'now'.tr : 'not_available'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots![index].startTime!)} '
                                          '- ${DateConverter.dateToTimeOnly(orderController.timeSlots![index].endTime!)}');
                                      print('====time : $time');
                                      return SlotWidget(
                                        title: time, fromCustomDate: true,
                                        isSelected: orderController.selectedTimeSlot == index,
                                        onTap: () {
                                          orderController.updateTimeSlot(index, time != 'Not Available');
                                          orderController.setPreferenceTimeForView(time, time != 'Not Available');
                                          orderController.showHideTimeSlot();
                                        },
                                      );
                                    }),
                                  );
                                }
                              ),

                              const Padding(
                                padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                                child: Divider(),
                              ),

                            ]) : ((orderController.selectedDateSlot == 0 && widget.todayClosed) || (orderController.selectedDateSlot == 1 && widget.tomorrowClosed))
                              ? Center(child: Text('restaurant_is_closed'.tr ))
                                : orderController.timeSlots != null
                              ? orderController.timeSlots!.isNotEmpty ? GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 5 : 3,
                                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                                  crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
                                  childAspectRatio: isDesktop ? 3.5 : 3
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: orderController.timeSlots!.length,
                                itemBuilder: (context, index){
                                  String time = (index == 0 && orderController.selectedDateSlot == 0
                                      && restaurantController.isRestaurantOpenNow(restaurantController.restaurant!.active!, restaurantController.restaurant!.schedules)
                                      ? _instanceOrder
                                      ? 'now'.tr : 'not_available'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots![index].startTime!)} '
                                      '- ${DateConverter.dateToTimeOnly(orderController.timeSlots![index].endTime!)}');
                                  return SlotWidget(
                                    title: time,
                                    isSelected: orderController.selectedTimeSlot == index,
                                    onTap: () {
                                      orderController.updateTimeSlot(index, time != 'Not Available');
                                      orderController.setPreferenceTimeForView(time, time != 'Not Available');
                                      orderController.showHideTimeSlot();
                                    },
                                  );
                            }) : Center(child: Text('no_slot_available'.tr)) : const Center(child: CircularProgressIndicator()),

                          ]);
                        }
                      );
                    }
                ),
              ),
            ),

           !isDesktop ? GetBuilder<OrderController>(
             builder: (orderController) {
               return GetBuilder<RestaurantController>(
                 builder: (restaurantController) {
                   return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        Expanded(
                          child: CustomButton(
                            buttonText: 'cancel'.tr,
                            color: Theme.of(context).disabledColor,
                            onPressed: () => Get.back(),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: CustomButton(
                            buttonText: 'schedule'.tr,
                            onPressed: () {
                              if((orderController.selectedTimeSlot == 0 || orderController.selectedTimeSlot == 1) && (orderController.selectedDateSlot == 0 || orderController.selectedDateSlot == 1)){
                                if(orderController.timeSlots != null ) {
                                  String time = (orderController.selectedTimeSlot == 0 && orderController.selectedDateSlot == 0
                                      && restaurantController.isRestaurantOpenNow(restaurantController.restaurant!.active!, restaurantController.restaurant!.schedules)
                                      ? _instanceOrder
                                      ? 'now'.tr : 'not_available'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots![orderController.selectedTimeSlot!].startTime!)} '
                                      '- ${DateConverter.dateToTimeOnly(orderController.timeSlots![orderController.selectedTimeSlot!].endTime!)}');

                                  orderController.setPreferenceTimeForView(time, time != 'Not Available');

                                }
                              } else if((orderController.selectedTimeSlot == 0 || orderController.selectedTimeSlot == 1) && orderController.selectedDateSlot == 2) {
                                String time = (orderController.selectedTimeSlot == 0 && orderController.selectedDateSlot == 2
                                    && restaurantController.isRestaurantOpenNow(restaurantController.restaurant!.active!, restaurantController.restaurant!.schedules)
                                    && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).isAtSameMomentAs(orderController.selectedCustomDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                                    ? _instanceOrder
                                    ? 'now'.tr : 'not_available'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots![orderController.selectedTimeSlot!].startTime!)} '
                                    '- ${DateConverter.dateToTimeOnly(orderController.timeSlots![orderController.selectedTimeSlot!].endTime!)}');

                                orderController.setPreferenceTimeForView(time, time != 'Not Available');
                              }
                              Get.back();
                            },
                          ),
                        ),
                      ]),
                    );
                 }
               );
             }
           ) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget tobView({required BuildContext context, required String title, required bool isSelected, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: isSelected ? robotoBold.copyWith(color: Theme.of(context).primaryColor) : robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Divider(color: isSelected ? Theme.of(context).primaryColor : ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).disabledColor, thickness: isSelected ? 2 : 0.7),
        ],
      ),
    );
  }
}
