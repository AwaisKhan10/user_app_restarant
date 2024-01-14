import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/pricing_view_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_method_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPlaceButton extends StatelessWidget {
  final OrderController orderController;
  final RestaurantController restController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? deliveryCharge;
  final double tax;
  final double? discount;
  final double total;
  final double? maxCodOrderAmount;
  final int subscriptionQty;
  final List<CartModel> cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final bool fromCart;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final CouponController couponController;
  final double subTotal;
  final bool taxIncluded;
  final double taxPercent;

  const OrderPlaceButton({
    Key? key, required this.orderController, required this.restController, required this.locationController,
    required this.todayClosed, required this.tomorrowClosed, required this.orderAmount, this.deliveryCharge,
    required this.tax, this.discount, required this.total, this.maxCodOrderAmount, required this.subscriptionQty,
    required this.cartList, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.fromCart, required this.guestNameTextEditingController, required this.guestNumberTextEditingController,
    required this.guestNumberNode, required this.isOfflinePaymentActive, required this.couponController, required this.subTotal,
    required this.taxIncluded, required this.taxPercent, required this.guestEmailController, required this.guestEmailNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: SafeArea(
        child: CustomButton(
            buttonText: orderController.isPartialPay ? 'place_order'.tr : 'confirm_order'.tr,
            radius: Dimensions.radiusDefault,
            isLoading: orderController.isLoading,
            onPressed: () {
          bool isAvailable = true;
          DateTime scheduleStartDate = DateTime.now();
          DateTime scheduleEndDate = DateTime.now();
          bool isGuestLogIn = Get.find<AuthController>().isGuestLoggedIn();
          if(orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
            isAvailable = false;
          }else {
            DateTime date = orderController.selectedDateSlot == 0 ? DateTime.now()
                : orderController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : orderController.selectedCustomDate!;
            DateTime startTime = orderController.timeSlots![orderController.selectedTimeSlot!].startTime!;
            DateTime endTime = orderController.timeSlots![orderController.selectedTimeSlot!].endTime!;
            scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
            scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
            for (CartModel cart in cartList) {
              if (!DateConverter.isAvailable(
                cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
                time: restController.restaurant!.scheduleOrder! ? scheduleStartDate : null,
              ) && !DateConverter.isAvailable(
                cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
                time: restController.restaurant!.scheduleOrder! ? scheduleEndDate : null,
              )) {
                isAvailable = false;
                break;
              }
            }
          }

          bool datePicked = false;
          for(DateTime? time in orderController.selectedDays) {
            if(time != null) {
              datePicked = true;
              break;
            }
          }

          if(Get.find<OrderController>().isDmTipSave && orderController.selectedTips != AppConstants.tips.length - 1) {
            Get.find<AuthController>().saveDmTipIndex(Get.find<OrderController>().selectedTips.toString());
          }
          if(!Get.find<OrderController>().isDmTipSave){
            Get.find<AuthController>().saveDmTipIndex('0');
          }

          if(isGuestLogIn && orderController.guestAddress == null && orderController.orderType != 'take_away'){
            showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
          } else if(isGuestLogIn && orderController.orderType == 'take_away' && guestNameTextEditingController.text.isEmpty){
            showCustomSnackBar('please_enter_contact_person_name'.tr);
          } else if(isGuestLogIn && orderController.orderType == 'take_away' && guestNumberTextEditingController.text.isEmpty){
            showCustomSnackBar('please_enter_contact_person_number'.tr);
          } else if(!isCashOnDeliveryActive && !isDigitalPaymentActive && !isWalletActive) {
            showCustomSnackBar('no_payment_method_is_enabled'.tr);
          }else if(!Get.find<SplashController>().configModel!.instantOrder! && !restController.restaurant!.instantOrder! && restController.restaurant!.scheduleOrder! && (orderController.preferableTime.isEmpty || orderController.preferableTime == 'Not Available')) {
            showCustomSnackBar('please_select_order_preference_time'.tr);
          } else if(orderController.paymentMethodIndex == -1) {
            if(ResponsiveHelper.isDesktop(context)){
              Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
                isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
              )));
            }else{
              showModalBottomSheet(
                context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                builder: (con) => PaymentMethodBottomSheet(
                  isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                  isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
                ),
              );
            }
          }else if(orderAmount < restController.restaurant!.minimumOrder!) {
            showCustomSnackBar('${'minimum_order_amount_is'.tr} ${restController.restaurant!.minimumOrder}');
          }else if(orderController.subscriptionOrder && orderController.subscriptionRange == null) {
            showCustomSnackBar('select_a_date_range_for_subscription'.tr);
          }else if(orderController.subscriptionOrder && !datePicked && orderController.subscriptionType == 'daily') {
            showCustomSnackBar('choose_time'.tr);
          }else if(orderController.subscriptionOrder && !datePicked) {
            showCustomSnackBar('select_at_least_one_day_for_subscription'.tr);
          }else if((orderController.selectedDateSlot == 0 && todayClosed) || (orderController.selectedDateSlot == 1 && tomorrowClosed)) {
            showCustomSnackBar('restaurant_is_closed'.tr);
          }else if(orderController.paymentMethodIndex == 0 && Get.find<SplashController>().configModel!.cashOnDelivery! && maxCodOrderAmount != null && (total > maxCodOrderAmount!)){
            showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
          } else if (orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
            if(restController.restaurant!.scheduleOrder! && !orderController.subscriptionOrder) {
              showCustomSnackBar('select_a_time'.tr);
            }else {
              showCustomSnackBar('restaurant_is_closed'.tr);
            }
          }else if (!isAvailable && !orderController.subscriptionOrder) {
            showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
          }else if (orderController.orderType != 'take_away' && orderController.distance == -1 && deliveryCharge == -1) {
            showCustomSnackBar('delivery_fee_not_set_yet'.tr);
          } else if(orderController.paymentMethodIndex == 1 && Get.find<UserController>().userInfoModel
              != null && Get.find<UserController>().userInfoModel!.walletBalance! < total) {
            showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
          }else {

            AddressModel? finalAddress = isGuestLogIn ? orderController.guestAddress :  restController.address[orderController.addressIndex];

            if(isGuestLogIn && orderController.orderType == 'take_away') {
              String number = orderController.countryDialCode! + guestNumberTextEditingController.text;
              finalAddress = AddressModel(contactPersonName: guestNameTextEditingController.text, contactPersonNumber: number,
                address: Get.find<LocationController>().getUserAddress()!.address!, latitude: Get.find<LocationController>().getUserAddress()!.latitude,
                longitude: Get.find<LocationController>().getUserAddress()!.longitude, zoneId: Get.find<LocationController>().getUserAddress()!.zoneId,
                email: guestEmailController.text,
              );
            }

            if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
              finalAddress.contactPersonNumber = Get.find<UserController>().userInfoModel!.phone;
            }

            List<OnlineCart> carts = [];
            for (int index = 0; index < cartList.length; index++) {
              CartModel cart = cartList[index];
              List<int?> addOnIdList = [];
              List<int?> addOnQtyList = [];
              List<OrderVariation> variations = [];
              for (var addOn in cart.addOnIds!) {
                addOnIdList.add(addOn.id);
                addOnQtyList.add(addOn.quantity);
              }
              if(cart.product!.variations != null){
                for(int i=0; i<cart.product!.variations!.length; i++) {
                  if(cart.variations![i].contains(true)) {
                    variations.add(OrderVariation(name: cart.product!.variations![i].name, values: OrderVariationValue(label: [])));
                    for(int j=0; j<cart.product!.variations![i].variationValues!.length; j++) {
                      if(cart.variations![i][j]!) {
                        variations[variations.length-1].values!.label!.add(cart.product!.variations![i].variationValues![j].level);
                      }
                    }
                  }
                }
              }
              carts.add(OnlineCart(
                  cart.id, cart.product!.id, cart.isCampaign! ? cart.product!.id : null,
                  cart.discountedPrice.toString(), variations,
                  cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Food', itemType: !fromCart ? "App\Models\ItemCampaign" : null,
              ));
            }

            List<SubscriptionDays> days = [];
            for(int index=0; index<orderController.selectedDays.length; index++) {
              if(orderController.selectedDays[index] != null) {
                days.add(SubscriptionDays(
                  day: orderController.subscriptionType == 'weekly' ? (index == 6 ? 0 : (index + 1)).toString()
                      : orderController.subscriptionType == 'monthly' ? (index + 1).toString() : index.toString(),
                  time: DateConverter.dateToTime(orderController.selectedDays[index]!),
                ));
              }
            }

            PlaceOrderBody placeOrderBody = PlaceOrderBody(
              cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
              couponDiscountTitle: Get.find<CouponController>().discount! > 0 ? Get.find<CouponController>().coupon!.title : null,
              scheduleAt: !restController.restaurant!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
                  && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleStartDate),
              orderAmount: total, orderNote: orderController.noteController.text, orderType: orderController.orderType,
              paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                  : orderController.paymentMethodIndex == 1 ? 'wallet'
                  : orderController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
              couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                  && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
              restaurantId: cartList[0].product!.restaurantId,
              address: finalAddress!.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude, addressType: finalAddress.addressType,
              contactPersonName: finalAddress.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
                  '${Get.find<UserController>().userInfoModel!.lName}',
              contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
              discountAmount: discount, taxAmount: tax, cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
              road: isGuestLogIn ? finalAddress.road??'' : orderController.streetNumberController.text.trim(),
              house: isGuestLogIn ? finalAddress.house??'' : orderController.houseController.text.trim(),
              floor: isGuestLogIn ? finalAddress.floor??'' : orderController.floorController.text.trim(),
              dmTips: (orderController.orderType == 'take_away' || orderController.subscriptionOrder || orderController.selectedTips == 0) ? '' : orderController.tips.toString(),
              subscriptionOrder: orderController.subscriptionOrder ? '1' : '0',
              subscriptionType: orderController.subscriptionType, subscriptionQuantity: subscriptionQty.toString(),
              subscriptionDays: days,
              subscriptionStartAt: orderController.subscriptionOrder ? DateConverter.dateToDateAndTime(orderController.subscriptionRange!.start) : '',
              subscriptionEndAt: orderController.subscriptionOrder ? DateConverter.dateToDateAndTime(orderController.subscriptionRange!.end) : '',
              unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
              deliveryInstruction: orderController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[orderController.selectedInstruction] : '',
              partialPayment: orderController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(Get.find<AuthController>().getGuestId()) : 0,
              isBuyNow: fromCart ? 0 : 1, guestEmail: isGuestLogIn ? finalAddress.email : null,
            );

            if(orderController.paymentMethodIndex == 3){
              Get.toNamed(RouteHelper.getOfflinePaymentScreen(placeOrderBody: placeOrderBody, zoneId: restController.restaurant!.zoneId!, total: total, maxCodOrderAmount: maxCodOrderAmount,
                  fromCart: fromCart, isCodActive: isCashOnDeliveryActive,
                  pricingView: PricingViewModel(subTotal: subTotal, subscriptionQty: subscriptionQty, discount: discount!,
                      taxIncluded: taxIncluded, tax: tax, deliveryCharge: deliveryCharge!, total: total, taxPercent: taxPercent)),
              );
            }else{
              orderController.placeOrder(placeOrderBody, restController.restaurant!.zoneId!, total, maxCodOrderAmount, fromCart, isCashOnDeliveryActive);
            }

          }
        }),
      ),
    );
  }
}
