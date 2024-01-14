import 'dart:async';
import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart' as cart;
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/delivery_log_model.dart';
import 'package:efood_multivendor/data/model/response/distance_model.dart';
import 'package:efood_multivendor/data/model/response/offline_method_model.dart';
import 'package:efood_multivendor/data/model/response/order_cancellation_body.dart';
import 'package:efood_multivendor/data/model/response/order_details_model.dart';
import 'package:efood_multivendor/data/model/response/order_model.dart';
import 'package:efood_multivendor/data/model/response/pause_log_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/refund_model.dart';
import 'package:efood_multivendor/data/model/response/response_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/data/model/response/subscription_schedule_model.dart';
import 'package:efood_multivendor/data/model/response/timeslote_model.dart';
import 'package:efood_multivendor/data/repository/order_repo.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/order_successfull_dialog.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/partial_pay_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class OrderController extends GetxController implements GetxService {
  final OrderRepo orderRepo;
  OrderController({required this.orderRepo});

  List<OrderModel>? _runningOrderList;
  List<OrderModel>? _runningSubscriptionOrderList;
  List<OrderModel>? _historyOrderList;
  List<OrderDetailsModel>? _orderDetails;
  int _paymentMethodIndex = -1;
  OrderModel? _trackModel;
  ResponseModel? _responseModel;
  bool _isLoading = false;
  bool _subscriveLoading = false;
  bool _showCancelled = false;
  String _orderType = 'delivery';
  List<TimeSlotModel>? _timeSlots;
  List<TimeSlotModel>? _allTimeSlots;
  List<int>? _slotIndexList;
  int _selectedDateSlot = 0;
  int? _selectedTimeSlot = 0;
  int _selectedTips = 0;
  double? _distance;
  bool _runningPaginate = false;
  int? _runningPageSize;
  List<int> _runningOffsetList = [];
  int _runningOffset = 1;
  bool _runningSubscriptionPaginate = false;
  int? _runningSubscriptionPageSize;
  List<int> _runningSubscriptionOffsetList = [];
  int _runningSubscriptionOffset = 1;
  bool _historyPaginate = false;
  int? _historyPageSize;
  List<int> _historyOffsetList = [];
  int _historyOffset = 1;
  int _addressIndex = 0;
  double _tips = 0.0;
  Timer? _timer;
  List<String?>? _refundReasons;
  int _selectedReasonIndex = 0;
  XFile? _refundImage;
  bool _showBottomSheet = true;
  bool _showOneOrder = true;
  List<CancellationData>? _orderCancelReasons;
  String? _cancelReason;
  double? _extraCharge;
  PaginatedOrderModel? _subscriptionOrderModel;
  bool _subscriptionOrder = false;
  DateTimeRange? _subscriptionRange;
  String? _subscriptionType = 'daily';
  int _subscriptionTypeIndex = 0;
  List<DateTime?> _selectedDays = [null];
  List<SubscriptionScheduleModel>? _schedules;
  PaginatedDeliveryLogModel? _deliverLogs;
  PaginatedPauseLogModel? _pauseLogs;
  int? _cancellationIndex = 0;
  bool _canShowTipsField = false;
  bool _isDmTipSave = false;
  bool _acceptTerms = true;
  bool _isLoadingUpdate = false;

  bool _canReorder = true;
  String _reorderMessage = '';
  bool _isExpanded = false;
  int _selectedInstruction = -1;
  String _preferableTime = '';
  int? _mostDmTipAmount;
  bool _isPartialPay = false;
  String? _digitalPaymentName;
  double _viewTotalPrice = 0;
  bool _canShowTimeSlot = false;
  AddressModel? _guestAddress;
  List<OfflineMethodModel>? _offlineMethodList;
  int _selectedOfflineBankIndex = 0;
  List<TextEditingController> informationControllerList = [];
  List<FocusNode> informationFocusList = [];
  String? countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
      : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode ?? Get.find<LocalizationController>().locale.countryCode;

  final TextEditingController couponController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController tipController = TextEditingController(text: '0');
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();
  bool _customDateRestaurantClose = false;
  DateTime? _selectedCustomDate;

  List<OrderModel>? get runningOrderList => _runningOrderList;
  List<OrderModel>? get runningSubscriptionOrderList => _runningSubscriptionOrderList;
  List<OrderModel>? get historyOrderList => _historyOrderList;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;
  int get paymentMethodIndex => _paymentMethodIndex;
  OrderModel? get trackModel => _trackModel;
  ResponseModel? get responseModel => _responseModel;
  bool get isLoading => _isLoading;
  bool get subscriveLoading => _subscriveLoading;
  bool get showCancelled => _showCancelled;
  String get orderType => _orderType;
  List<TimeSlotModel>? get timeSlots => _timeSlots;
  List<TimeSlotModel>? get allTimeSlots => _allTimeSlots;
  List<int>? get slotIndexList => _slotIndexList;
  int get selectedDateSlot => _selectedDateSlot;
  int? get selectedTimeSlot => _selectedTimeSlot;
  int get selectedTips => _selectedTips;
  double? get distance => _distance;
  bool get runningPaginate => _runningPaginate;
  int? get runningPageSize => _runningPageSize;
  int get runningOffset => _runningOffset;
  bool get runningSubscriptionPaginate => _runningSubscriptionPaginate;
  int? get runningSubscriptionPageSize => _runningSubscriptionPageSize;
  int get runningSubscriptionOffset => _runningSubscriptionOffset;
  bool get historyPaginate => _historyPaginate;
  int? get historyPageSize => _historyPageSize;
  int get historyOffset => _historyOffset;
  int get addressIndex => _addressIndex;
  double get tips => _tips;
  // int get deliverySelectIndex => _deliverySelectIndex;
  int get selectedReasonIndex => _selectedReasonIndex;
  XFile? get refundImage => _refundImage;
  List<String?>? get refundReasons => _refundReasons;
  bool get showBottomSheet => _showBottomSheet;
  bool get showOneOrder => _showOneOrder;
  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;
  String? get cancelReason => _cancelReason;
  double? get extraCharge => _extraCharge;
  bool get subscriptionOrder => _subscriptionOrder;
  DateTimeRange? get subscriptionRange => _subscriptionRange;
  String? get subscriptionType => _subscriptionType;
  List<DateTime?> get selectedDays => _selectedDays;
  PaginatedOrderModel? get subscriptionOrderModel => _subscriptionOrderModel;
  List<SubscriptionScheduleModel>? get schedules => _schedules;
  PaginatedDeliveryLogModel? get deliveryLogs => _deliverLogs;
  PaginatedPauseLogModel? get pauseLogs => _pauseLogs;
  int? get cancellationIndex => _cancellationIndex;
  bool get isExpanded => _isExpanded;
  int get selectedInstruction => _selectedInstruction;
  String get preferableTime => _preferableTime;
  bool get canShowTipsField => _canShowTipsField;
  bool get isDmTipSave => _isDmTipSave;
  bool get acceptTerms => _acceptTerms;
  int? get mostDmTipAmount => _mostDmTipAmount;
  bool get isPartialPay => _isPartialPay;
  String? get digitalPaymentName => _digitalPaymentName;
  double? get viewTotalPrice => _viewTotalPrice;
  int get subscriptionTypeIndex => _subscriptionTypeIndex;
  bool get canShowTimeSlot => _canShowTimeSlot;
  AddressModel? get guestAddress => _guestAddress;
  List<OfflineMethodModel>? get offlineMethodList => _offlineMethodList;
  int get selectedOfflineBankIndex => _selectedOfflineBankIndex;
  bool get customDateRestaurantClose => _customDateRestaurantClose;
  DateTime? get selectedCustomDate => _selectedCustomDate;
  bool get isLoadingUpdate => _isLoadingUpdate;

  void setCustomDate(DateTime? date, bool instanceOrder, {bool canUpdate = true}) {
    _selectedCustomDate = date;
    if(instanceOrder) {
      _selectedTimeSlot = 0;
    } else {
      _selectedTimeSlot = 1;
    }
    if(canUpdate) {
      update();
    }
  }

  void setDateCloseRestaurant(bool status) {
    _customDateRestaurantClose = status;
    update();
  }

  void setTotalAmount(double amount){
    _viewTotalPrice = amount;
  }

  void showHideTimeSlot(){
    _canShowTimeSlot = !_canShowTimeSlot;
    update();
  }

  void changePartialPayment({bool isUpdate = true}){
    _isPartialPay = !_isPartialPay;
    if(isUpdate) {
      update();
    }
  }

  void setGuestAddress(AddressModel? address) {
    _guestAddress = address;
    update();
  }

  void changeDigitalPaymentName(String name){
    _digitalPaymentName = name;
    update();
  }

  void selectOfflineBank(int index){
    _selectedOfflineBankIndex = index;
    update();
  }

  Future<void> getOfflineMethodList()async {
    Response response = await orderRepo.getOfflineMethodList();
    if (response.statusCode == 200) {
      _offlineMethodList = [];

      response.body.forEach((method) => _offlineMethodList!.add(OfflineMethodModel.fromJson(method)));

    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<bool> saveOfflineInfo(String data) async {
    _isLoading = true;
    bool success = false;
    update();
    Response response = await orderRepo.saveOfflineInfo(data);
    if (response.statusCode == 200) {
      success = true;
      _isLoading = false;
      _guestAddress = null;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  Future<bool> updateOfflineInfo(String data) async {
    _isLoadingUpdate = true;
    bool success = false;
    update();
    Response response = await orderRepo.updateOfflineInfo(data);
    if (response.statusCode == 200) {
      success = true;
      _isLoadingUpdate = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  void changesMethod() {
    List<MethodInformations>? methodInformation = offlineMethodList![selectedOfflineBankIndex].methodInformations!;

    informationControllerList = [];
    informationFocusList = [];

    for(int index=0; index<methodInformation.length; index++) {
      informationControllerList.add(TextEditingController());
      informationFocusList.add(FocusNode());
    }
    update();
  }

  Future<void> getDmTipMostTapped() async {
    _mostDmTipAmount = 0;
    Response response = await orderRepo.getDmTipMostTapped();
    if (response.statusCode == 200) {
      _mostDmTipAmount = response.body['most_tips_amount'];
    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<bool> checkBalanceStatus(double totalPrice, {double discount = 0, double extraCharge = 0}) async {
    totalPrice = (totalPrice - discount) + extraCharge;
    if(Get.find<OrderController>().isPartialPay){
      Get.find<OrderController>().changePartialPayment();
    }
    Get.find<OrderController>().setPaymentMethod(-1);
    print('--total : $totalPrice , compare balance : ${Get.find<UserController>().userInfoModel!.walletBalance! < totalPrice}');
    if((Get.find<UserController>().userInfoModel!.walletBalance! < totalPrice) && (Get.find<UserController>().userInfoModel!.walletBalance! != 0.0)){
      Get.dialog(PartialPayDialog(isPartialPay: true, totalPrice: totalPrice), useSafeArea: false,);
    }else{
      Get.dialog(PartialPayDialog(isPartialPay: false, totalPrice: totalPrice), useSafeArea: false,);
    }

    update();
    return true;
  }

  void showTipsField(){
    _canShowTipsField = !_canShowTipsField;
    update();
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }


  void setCancelIndex(int? index) {
    _cancellationIndex = index;
    update();
  }

  Future<void> reOrder(List<OrderDetailsModel> orderedFoods, int? restaurantZoneId) async {
    _isLoading = true;
    update();

    List<int?> foodIds = [];
    for(int i=0; i<orderedFoods.length; i++){
      foodIds.add(orderedFoods[i].foodDetails!.id);
    }
    Response response = await orderRepo.getFoodsWithFoodIds(foodIds);
    if (response.statusCode == 200) {
      _canReorder = true;
      List<Product> foods = [];
      response.body.forEach((food) => foods.add(Product.fromJson(food)));

      List<OnlineCart> onlineCartList = [];
      List<CartModel> offlineCartList = [];

      if(Get.find<LocationController>().getUserAddress()!.zoneIds!.contains(restaurantZoneId)){

        for(int i=0; i < orderedFoods.length; i++){
          for(int j=0; j<foods.length; j++){
            if(orderedFoods[i].foodDetails!.id == foods[j].id){
              onlineCartList.add(_sortOutProductAddToCard(orderedFoods[i].variation, foods[j], orderedFoods[i], getOnlineCart: true));
              offlineCartList.add(_sortOutProductAddToCard(orderedFoods[i].variation, foods[j], orderedFoods[i], getOnlineCart: false));
            }
          }
        }

      } else{
        _canReorder = false;
        _reorderMessage = 'you_are_not_in_the_order_zone';
      }

      if(_canReorder) {
        _checkProductVariationHasChanged(offlineCartList);
      }

      _isLoading = false;
      update();

      if(_canReorder) {
        await Get.find<CartController>().reorderAddToCart(onlineCartList);
        Get.toNamed(RouteHelper.getCartRoute(fromReorder: true));
      }else{
        showCustomSnackBar(_reorderMessage.tr);
      }

    }else{
      ApiChecker.checkApi(response);
    }

  }


  dynamic _sortOutProductAddToCard(List<Variation>? orderedVariation, Product currentFood, OrderDetailsModel orderDetailsModel, {bool getOnlineCart = true}){
    List<List<bool?>> selectedVariations = [];

    double price = currentFood.price!;
    double variationPrice = 0;
    int? quantity = orderDetailsModel.quantity;
    List<int?> addOnIdList = [];
    List<cart.AddOn> addOnIdWithQtnList = [];
    List<bool> addOnActiveList = [];
    List<int?> addOnQtyList = [];
    List<AddOns> addOnsList = [];
    List<OrderVariation> variations = [];

    if(currentFood.variations != null && currentFood.variations!.isNotEmpty){
      for(int i=0; i<currentFood.variations!.length; i++){
        selectedVariations.add([]);
        for(int j=0; j<orderedVariation!.length; j++){
          if(currentFood.variations![i].name == orderedVariation[j].name){
            for(int x=0; x<currentFood.variations![i].variationValues!.length; x++){
              selectedVariations[i].add(false);
              for(int y=0; y<orderedVariation[j].variationValues!.length; y++){
                if(currentFood.variations![i].variationValues![x].level == orderedVariation[j].variationValues![y].level){
                  selectedVariations[i][x] = true;
                }
              }
            }
          }
        }
      }
    }

    if(currentFood.variations != null && currentFood.variations!.isNotEmpty){
      for(int i=0; i<currentFood.variations!.length; i++){
        if(selectedVariations[i].contains(true)){
          variations.add(OrderVariation(name: currentFood.variations![i].name, values: OrderVariationValue(label: [])));
          for(int j=0; j<currentFood.variations![i].variationValues!.length; j++) {
            if(selectedVariations[i][j]!) {
              variations[variations.length-1].values!.label!.add(currentFood.variations![i].variationValues![j].level);
            }
          }
        }
      }
    }

    if(currentFood.variations != null){
      for(int index = 0; index< currentFood.variations!.length; index++) {
        for(int i=0; i<currentFood.variations![index].variationValues!.length; i++) {
          if(selectedVariations[index].isNotEmpty && selectedVariations[index][i]!) {
            variationPrice += currentFood.variations![index].variationValues![i].optionPrice!;
          }
        }
      }
    }

    for (var addon in currentFood.addOns!) {
      for(int i=0; i<orderDetailsModel.addOns!.length; i++){
        if(orderDetailsModel.addOns![i].id == addon.id){
          addOnIdList.add(addon.id);
          addOnIdWithQtnList.add(cart.AddOn(id: addon.id, quantity: orderDetailsModel.addOns![i].quantity));
        }
      }
      addOnsList.add(addon);
    }


    for (var addOn in currentFood.addOns!) {
      if(addOnIdList.contains(addOn.id)) {
        addOnActiveList.add(true);
        addOnQtyList.add(orderDetailsModel.addOns![addOnIdList.indexOf(addOn.id)].quantity);
      }else {
        addOnActiveList.add(false);
      }
    }

    double? discount = (currentFood.restaurantDiscount == 0) ? currentFood.discount : currentFood.restaurantDiscount;
    String? discountType = (currentFood.restaurantDiscount == 0) ? currentFood.discountType : 'percent';
    double? priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType);

    double priceWithVariation = price + variationPrice;


    CartModel cartModel = CartModel(
      null, priceWithVariation, priceWithDiscount, (price - PriceConverter.convertWithDiscount(price, discount, discountType)!),
      quantity, addOnIdWithQtnList, addOnsList, false, currentFood, selectedVariations, currentFood.quantityLimit,
    );

    OnlineCart onlineCart = OnlineCart(
        null, currentFood.id, null,
        priceWithVariation.toString(), variations,
        quantity, addOnIdList, addOnsList, addOnQtyList, 'Food'
    );

    if(getOnlineCart) {
      return onlineCart;
    } else {
      return cartModel;
    }
  }

  void _checkProductVariationHasChanged(List<CartModel> cartList){

    for(CartModel cart in cartList){
      if(cart.product!.variations != null && cart.product!.variations!.isNotEmpty){
        print('--------varialtions ${cartList.indexOf(cart)} : ${jsonEncode(cart.product!.variations!)}');
        for (var pv in cart.product!.variations!) {
          print('=====item ${cart.product!.variations!.indexOf(pv)} : ${pv.toJson()}');
          int selectedValues = 0;

          print('========is required : ${pv.required!}');

          if(pv.required!){
            print('---required 11111111111111--->> ${cart.variations![cart.product!.variations!.indexOf(pv)]}');
            for (var selected in cart.variations![cart.product!.variations!.indexOf(pv)]) {
              if(selected!){
                selectedValues = selectedValues + 1;
              }
            }

            if(selectedValues >= pv.min! && selectedValues<= pv.max! || (pv.min==0 && pv.max==0)){
              _canReorder = true;
            }else{
              _canReorder = false;
              _reorderMessage = 'this_ordered_products_are_updated_so_can_not_reorder_this_order';
            }

            print('====can reorder 1: $_canReorder');

          }else{
            print('---11111111111111--->> ${cart.variations![cart.product!.variations!.indexOf(pv)]}');
            for (var selected in cart.variations![cart.product!.variations!.indexOf(pv)]) {
              if(selected!){
                selectedValues = selectedValues + 1;
              }
            }

            if(selectedValues == 0){
              _canReorder = true;
            }else{
              print('---22222222222--->> ${selectedValues} >= ${pv.min}  && $selectedValues <= ${pv.max}');
              if((selectedValues >= pv.min! && selectedValues<= pv.max!) || (pv.min == 0 && pv.max == 0)){
                _canReorder = true;
              }else{
                _canReorder = false;
                print('======check 2');
                _reorderMessage = 'this_ordered_products_are_updated_so_can_not_reorder_this_order';
              }
            }
            print('====can reorder 2: $_canReorder');
          }
        }
      }

    }
  }

  Future<void> getDeliveryLogs(int? subscriptionID, int offset) async {
    if(offset == 1) {
      _deliverLogs = null;
    }
    Response response = await orderRepo.getSubscriptionDeliveryLog(subscriptionID, offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _deliverLogs = PaginatedDeliveryLogModel.fromJson(response.body);
      }else {
        _deliverLogs!.data!.addAll(PaginatedDeliveryLogModel.fromJson(response.body).data!);
        _deliverLogs!.offset = PaginatedDeliveryLogModel.fromJson(response.body).offset;
        _deliverLogs!.totalSize = PaginatedDeliveryLogModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getPauseLogs(int? subscriptionID, int offset) async {
    if(offset == 1) {
      _pauseLogs = null;
    }
    Response response = await orderRepo.getSubscriptionPauseLog(subscriptionID, offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _pauseLogs = PaginatedPauseLogModel.fromJson(response.body);
      }else {
        _pauseLogs!.data!.addAll(PaginatedPauseLogModel.fromJson(response.body).data!);
        _pauseLogs!.offset = PaginatedPauseLogModel.fromJson(response.body).offset;
        _pauseLogs!.totalSize = PaginatedPauseLogModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getSubscriptions(int offset, {bool notify = true}) async {
    if(offset == 1) {
      _subscriptionOrderModel = null;
      if(notify) {
        update();
      }
    }
    Response response = await orderRepo.getSubscriptionList(offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _subscriptionOrderModel = PaginatedOrderModel.fromJson(response.body);
      }else {
        _subscriptionOrderModel!.orders!.addAll(PaginatedOrderModel.fromJson(response.body).orders!);
        _subscriptionOrderModel!.offset = PaginatedOrderModel.fromJson(response.body).offset;
        _subscriptionOrderModel!.totalSize = PaginatedOrderModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void setOrderCancelReason(String? reason){
    _cancelReason = reason;
    update();
  }

  Future<double?> getExtraCharge(double? distance) async {
    _extraCharge = null;
    Response response = await orderRepo.getExtraCharge(distance);
    if (response.statusCode == 200) {
      _extraCharge = double.parse(response.body.toString());
    } else {
      _extraCharge = 0;
    }
    return _extraCharge;
  }

  Future<void> getOrderCancelReasons()async {
    Response response = await orderRepo.getCancelReasons();
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody = OrderCancellationBody.fromJson(response.body);
      _orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        _orderCancelReasons!.add(element);
      }

    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  void callTrackOrderApi({required OrderModel orderModel, required String orderId, String? contactNumber}){
    if(orderModel.orderStatus != 'delivered' && orderModel.orderStatus != 'failed' && orderModel.orderStatus != 'canceled') {
      if (kDebugMode) {
        print('start api call------------');
      }

      Get.find<OrderController>().timerTrackOrder(orderId.toString(), contactNumber: contactNumber);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if(Get.currentRoute.contains(RouteHelper.orderDetails)){
          Get.find<OrderController>().timerTrackOrder(orderId.toString(), contactNumber: contactNumber);
        } else {
          _timer?.cancel();
        }
      });
    }else{
      Get.find<OrderController>().timerTrackOrder(orderId.toString(), contactNumber: contactNumber);
    }
  }

  void showOrders(){
    _showOneOrder = !_showOneOrder;
    update();
  }

  void showRunningOrders(){
    _showBottomSheet = !_showBottomSheet;
    update();
  }

  void selectReason(int index,{bool isUpdate = true}){
    _selectedReasonIndex = index;
    if(isUpdate) {
      update();
    }
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  // void selectDelivery(int index){
  //   _deliverySelectIndex = index;
  //   update();
  // }


  // void closeRunningOrder(bool isUpdate){
  //   _isRunningOrderViewShow = !_isRunningOrderViewShow;
  //   if(isUpdate){
  //     update();
  //   }
  // }

  Future<void> addTips(double tips, {bool notify = true}) async {
    _tips = tips;
    if(notify) {
      update();
    }
  }

  void pickRefundImage(bool isRemove) async {
    if(isRemove) {
      _refundImage = null;
    }else {
      _refundImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      update();
    }
  }

  Future<void> getRefundReasons()async {
    Response response = await orderRepo.getRefundReasons();
    if (response.statusCode == 200) {
      RefundModel refundModel = RefundModel.fromJson(response.body);
      _refundReasons = [];
      _refundReasons!.insert(0, 'select_an_option');
      for (var element in refundModel.refundReasons!) {
        _refundReasons!.add(element.reason);
      }
    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> submitRefundRequest(String note, String? orderId)async {
    if(_selectedReasonIndex == 0){
      showCustomSnackBar('please_select_reason'.tr);
    }else{
      _isLoading = true;
      update();
      Map<String, String> body = {};
      body.addAll(<String, String>{
        'customer_reason': _refundReasons![selectedReasonIndex]!,
        'order_id': orderId!,
        'customer_note': note,
      });
      Response response = await orderRepo.submitRefundRequest(body, _refundImage, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
      if (response.statusCode == 200) {
        showCustomSnackBar(response.body['message'], isError: false);
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }else {
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
    }
  }

  Future<void> getRunningOrders(int offset, {bool notify = true}) async {
    if(offset == 1) {
      _runningOffsetList = [];
      _runningOffset = 1;
      _runningOrderList = null;
      if(notify) {
        update();
      }
    }
    if (!_runningOffsetList.contains(offset)) {
      _runningOffsetList.add(offset);
      Response response = await orderRepo.getRunningOrderList(offset, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
      if (response.statusCode == 200) {
        if (offset == 1) {
          _runningOrderList = [];
        }
        _runningOrderList!.addAll(PaginatedOrderModel.fromJson(response.body).orders!);
        _runningPageSize = PaginatedOrderModel.fromJson(response.body).totalSize;
        _runningPaginate = false;
        // if(fromHome && _isRunningOrderViewShow){
        //   canActiveOrder();
        // }
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_runningPaginate) {
        _runningPaginate = false;
        update();
      }
    }
  }

  Future<void> getRunningSubscriptionOrders(int offset, {bool notify = true}) async {
    if(offset == 1) {
      _runningSubscriptionOffsetList = [];
      _runningSubscriptionOffset = 1;
      _runningSubscriptionOrderList = null;
      if(notify) {
        update();
      }
    }
    if (!_runningSubscriptionOffsetList.contains(offset)) {
      _runningSubscriptionOffsetList.add(offset);
      Response response = await orderRepo.getRunningSubscriptionOrderList(offset);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _runningSubscriptionOrderList = [];
        }
        _runningSubscriptionOrderList!.addAll(PaginatedOrderModel.fromJson(response.body).orders!);
        _runningSubscriptionPageSize = PaginatedOrderModel.fromJson(response.body).totalSize;
        _runningSubscriptionPaginate = false;
        // if(fromHome && _isRunningOrderViewShow){
        //   canActiveOrder();
        // }
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_runningSubscriptionPaginate) {
        _runningSubscriptionPaginate = false;
        update();
      }
    }
  }

  /*void canActiveOrder(){
    if(_runningOrderList.isNotEmpty){
      _reversRunningOrderList = List.from(_runningOrderList.reversed);

      for(int i = 0; i < _reversRunningOrderList.length; i++){
        if(_reversRunningOrderList[i].orderStatus == AppConstants.PENDING || _reversRunningOrderList[i].orderStatus == AppConstants.ACCEPTED
            || _reversRunningOrderList[i].orderStatus == AppConstants.PROCESSING || _reversRunningOrderList[i].orderStatus == AppConstants.CONFIRMED
            || _reversRunningOrderList[i].orderStatus == AppConstants.HANDOVER || _reversRunningOrderList[i].orderStatus == AppConstants.PICKED_UP){

          _isRunningOrderViewShow = true;
          _runningOrderIndex = i;
          print(_runningOrderIndex);
          break;
        }else{
          _isRunningOrderViewShow = false;
          print('not found any ongoing order');
        }
      }
      update();
    }
  }*/

  Future<void> getHistoryOrders(int offset, {bool notify = true}) async {
    if(offset == 1) {
      _historyOffsetList = [];
      _historyOrderList = null;
      if(notify) {
        update();
      }
    }
    _historyOffset = offset;
    if (!_historyOffsetList.contains(offset)) {
      _historyOffsetList.add(offset);
      Response response = await orderRepo.getHistoryOrderList(offset);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _historyOrderList = [];
        }
        _historyOrderList!.addAll(PaginatedOrderModel.fromJson(response.body).orders!);
        _historyPageSize = PaginatedOrderModel.fromJson(response.body).totalSize;
        _historyPaginate = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_historyPaginate) {
        _historyPaginate = false;
        update();
      }
    }
  }

  void showBottomLoader(bool isRunning) {
    if(isRunning) {
      _runningPaginate = true;
    }else {
      _historyPaginate = true;
    }
    update();
  }

  void setOffset(int offset, bool isRunning) {
    if(isRunning) {
      _runningOffset = offset;
    }else {
      _historyOffset = offset;
    }
  }

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID) async {
    _isLoading = true;
    _showCancelled = false;

    Response response = await orderRepo.getOrderDetails(orderID, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if (response.statusCode == 200) {
      _orderDetails = [];
      _schedules = [];
      if(response.body['details'] != null){
        response.body['details'].forEach((orderDetail) => _orderDetails!.add(OrderDetailsModel.fromJson(orderDetail)));
      }
      if(response.body['subscription_schedules'] != null){
        response.body['subscription_schedules'].forEach((schedule) => _schedules!.add(SubscriptionScheduleModel.fromJson(schedule)));
      }

    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return _orderDetails;
  }

  void setPaymentMethod(int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if(isUpdate) {
      update();
    }
  }

  Future<ResponseModel?> trackOrder(String? orderID, OrderModel? orderModel, bool fromTracking, {String? contactNumber, bool? fromGuestInput = false}) async {
    _trackModel = null;
    _responseModel = null;
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if(orderModel == null) {
      _isLoading = true;
      // if(contactNumber != null && fromGuestInput!){
      //   update();
      // }
      Response response = await orderRepo.trackOrder(
        orderID, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId(),
        contactNumber: contactNumber,
      );
      if (response.statusCode == 200) {
        _trackModel = OrderModel.fromJson(response.body);
        _responseModel = ResponseModel(true, response.body.toString());
        // callTrackOrderApi(orderModel: _trackModel, orderId: orderID);
      } else {
        _responseModel = ResponseModel(false, response.statusText);
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
    }else {
      _trackModel = orderModel;
      _responseModel = ResponseModel(true, 'Successful');
      // callTrackOrderApi(orderModel: _trackModel, orderId: orderID);
    }
    return _responseModel;
  }

  Future<ResponseModel?> timerTrackOrder(String orderID, {String? contactNumber}) async {
    _showCancelled = false;

    Response response = await orderRepo.trackOrder(
      orderID, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId(),
      contactNumber: contactNumber,
    );
    if (response.statusCode == 200) {
      _trackModel = OrderModel.fromJson(response.body);
      _responseModel = ResponseModel(true, response.body.toString());
    } else {
      _responseModel = ResponseModel(false, response.statusText);
      ApiChecker.checkApi(response);
    }
    update();

    return _responseModel;
  }

  Future<String> placeOrder(PlaceOrderBody placeOrderBody, int? zoneID, double amount, double? maximumCodOrderAmount, bool fromCart,
      bool isCashOnDeliveryActive, {bool isOfflinePay = false}) async {
    _isLoading = true;
    update();
    String orderID = '';
    Response response = await orderRepo.placeOrder(placeOrderBody);
    _isLoading = false;
    if (response.statusCode == 200) {
      String? message = response.body['message'];
      orderID = response.body['order_id'].toString();
      orderRepo.sendNotificationRequest(orderID, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
      if(!isOfflinePay) {
        callback(true, message, orderID, zoneID, amount, maximumCodOrderAmount, fromCart, isCashOnDeliveryActive, placeOrderBody.contactPersonNumber!);
      } else {
        Get.find<CartController>().getCartDataOnline();
      }
      if (kDebugMode) {
        print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      if(!isOfflinePay){
        callback(false, response.statusText, '-1', zoneID, amount, maximumCodOrderAmount, fromCart, isCashOnDeliveryActive, placeOrderBody.contactPersonNumber!);
      }else{
        showCustomSnackBar(response.statusText);
      }
    }
    update();
    return orderID;
  }

  void callback(bool isSuccess, String? message, String orderID, int? zoneID, double amount,
      double? maximumCodOrderAmount, bool fromCart, bool isCashOnDeliveryActive, String? contactNumber) async {
    if(isSuccess) {
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      if(fromCart) {
        Get.find<CartController>().clearCartList();
      }
      Get.find<OrderController>().setGuestAddress(null);
      Get.find<OrderController>().stopLoader();
      if(Get.find<OrderController>().paymentMethodIndex == 0 || Get.find<OrderController>().paymentMethodIndex == 1) {
        double total = ((amount / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
        Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
        if(ResponsiveHelper.isDesktop(Get.context)) {
          Get.offNamed(RouteHelper.getInitialRoute());
          Future.delayed(const Duration(seconds: 2) , () => Get.dialog(Center(child: SizedBox(height: 350, width : 500, child: OrderSuccessfulDialog(orderID: orderID, contactNumber: contactNumber)))));
        } else {
          Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'success', amount, contactNumber));
        }

      }else {
        if(GetPlatform.isWeb) {
          // Get.back();
          await Get.find<AuthController>().saveGuestNumber(contactNumber ?? '');
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&customer_id=${Get.find<UserController>().userInfoModel?.id ?? Get.find<AuthController>().getGuestId()}'
              '&payment_method=${Get.find<OrderController>().digitalPaymentName}&payment_platform=web&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&amount=$amount&status=';
          html.window.open(selectedUrl,"_self");
        } else{
          Get.offNamed(RouteHelper.getPaymentRoute(
            OrderModel(id: int.parse(orderID), userId: Get.find<UserController>().userInfoModel?.id ?? 0, orderAmount: amount, restaurant: Get.find<RestaurantController>().restaurant),
            Get.find<OrderController>().digitalPaymentName, guestId: Get.find<AuthController>().getGuestId(), contactNumber: contactNumber,
          ),
          );
        }
      }
      Get.find<OrderController>().clearPrevData();
      Get.find<OrderController>().updateTips(0);
      Get.find<CouponController>().removeCouponData(false);
    }else {
      showCustomSnackBar(message);
    }
  }

  void stopLoader({bool isUpdate = true}) {
    _isLoading = false;
    if(isUpdate) {
      update();
    }
  }

  void clearPrevData() {
    _addressIndex = 0;
    _paymentMethodIndex = -1;
    _selectedDateSlot = 0;
    _selectedTimeSlot = 0;
    _distance = null;
    _subscriptionOrder = false;
    _selectedDays = [null];
    _subscriptionType = 'daily';
    _subscriptionRange = null;
    _isDmTipSave = false;
  }

  void setAddressIndex(int index, {bool canUpdate = true} ) {
    _addressIndex = index;
    if(canUpdate) {
      update();
    }
  }

  Future<bool> cancelOrder(int? orderID, String? cancelReason) async {
    bool success = false;
    _isLoading = true;
    update();
    Response response = await orderRepo.cancelOrder(orderID.toString(), cancelReason);
    _isLoading = false;
    Get.back();
    if (response.statusCode == 200) {
      success = true;
      OrderModel? orderModel;
      for(OrderModel order in _runningOrderList!) {
        if(order.id == orderID) {
          orderModel = order;
          break;
        }
      }
      _runningOrderList!.remove(orderModel);
      _showCancelled = true;
      showCustomSnackBar(response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  void setOrderType(String type, {bool notify = true}) {
    _orderType = type;
    if(notify) {
      update();
    }
  }

  Future<void> initializeTimeSlot(Restaurant restaurant) async {
    _timeSlots = [];
    _allTimeSlots = [];
    int minutes = 0;
    DateTime now = DateTime.now();
    for(int index=0; index<restaurant.schedules!.length; index++) {
      DateTime openTime = DateTime(
        now.year, now.month, now.day, DateConverter.convertStringTimeToDate(restaurant.schedules![index].openingTime!).hour,
        DateConverter.convertStringTimeToDate(restaurant.schedules![index].openingTime!).minute,
      );
      DateTime closeTime = DateTime(
        now.year, now.month, now.day, DateConverter.convertStringTimeToDate(restaurant.schedules![index].closingTime!).hour,
        DateConverter.convertStringTimeToDate(restaurant.schedules![index].closingTime!).minute,
      );
      if(closeTime.difference(openTime).isNegative) {
        minutes = openTime.difference(closeTime).inMinutes;
      }else {
        minutes = closeTime.difference(openTime).inMinutes;
      }
      if(minutes > Get.find<SplashController>().configModel!.scheduleOrderSlotDuration!) {
        DateTime time = openTime;
        for(;;) {
          if(time.isBefore(closeTime)) {
            DateTime start = time;
            DateTime end = start.add(Duration(minutes: Get.find<SplashController>().configModel!.scheduleOrderSlotDuration!));
            if(end.isAfter(closeTime)) {
              end = closeTime;
            }
            _timeSlots!.add(TimeSlotModel(day: restaurant.schedules![index].day, startTime: start, endTime: end));
            _allTimeSlots!.add(TimeSlotModel(day: restaurant.schedules![index].day, startTime: start, endTime: end));
            time = time.add(Duration(minutes: Get.find<SplashController>().configModel!.scheduleOrderSlotDuration!));
          }else {
            break;
          }
        }
      }else {
        _timeSlots!.add(TimeSlotModel(day: restaurant.schedules![index].day, startTime: openTime, endTime: closeTime));
        _allTimeSlots!.add(TimeSlotModel(day: restaurant.schedules![index].day, startTime: openTime, endTime: closeTime));
      }
    }
    validateSlot(_allTimeSlots!, DateTime.now(), notify: false);
  }

  void updateTimeSlot(int? index, bool instanceOrder, {bool notify = true}) {

    if(!instanceOrder) {
      if(index == 0) {
        if(notify) {
          showCustomSnackBar('instance_order_is_not_active'.tr, showToaster: true);
        }
      } else {
        _selectedTimeSlot = index;
      }
    } else {
      _selectedTimeSlot = index;
    }
    if(notify) {
      update();
    }
  }

  void updateTips(int index, {bool notify = true}) {
    _selectedTips = index;
    if(_selectedTips == 0 || _selectedTips == AppConstants.tips.length -1) {
      _tips = 0;
    }else{
      _tips = double.parse(AppConstants.tips[index]);
    }
    if(notify) {
      update();
    }
  }

  void updateDateSlot(int index, DateTime date, bool instanceOrder, {bool fromCustomDate = false}) {
    if(!fromCustomDate) {
      _selectedDateSlot = index;
    }
    if(instanceOrder) {
      _selectedTimeSlot = 0;
    } else {
      _selectedTimeSlot = 1;
    }
    if(_allTimeSlots != null) {
      validateSlot(_allTimeSlots!, date);
    }
    update();
  }

  void validateSlot(List<TimeSlotModel> slots, DateTime date, {bool notify = true}) {
    _timeSlots = [];
    int day = 0;
    bool isToday = DateTime(date.year, date.month, date.day).isAtSameMomentAs(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    day = date.weekday;

    if(day == 7) {
      day = 0;
    }
    _slotIndexList = [];
    int index0 = 0;
    for(int index=0; index<slots.length; index++) {
      if (day == slots[index].day && (isToday ? slots[index].endTime!.isAfter(DateTime.now()) : true)) {
        _timeSlots!.add(slots[index]);
        _slotIndexList!.add(index0);
        index0 ++;
      }
    }
    if(notify) {
      update();
    }
  }

  Future<bool> switchToCOD(String? orderID, String? contactNumber, {double? points}) async {
    _isLoading = true;
    update();
    Response response = await orderRepo.switchToCOD(orderID);
    bool isSuccess;
    if (response.statusCode == 200) {
      if(points != null) {
        Get.find<AuthController>().saveEarningPoint(points.toStringAsFixed(0));
      }
      if(Get.find<AuthController>().isGuestLoggedIn()) {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID!, 'success', 0, contactNumber));
      }else {
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      }
      showCustomSnackBar(response.body['message'], isError: false);
      isSuccess = true;
    } else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<double?> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    _distance = -1;
    Response response = await orderRepo.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _distance = DistanceModel.fromJson(response.body).rows![0].elements![0].distance!.value! / 1000;
      } else {
        _distance = Geolocator.distanceBetween(
          originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
        ) / 1000;
      }
    } catch (e) {
      _distance = Geolocator.distanceBetween(
        originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
      ) / 1000;
    }
    await getExtraCharge(_distance);

    update();
    return _distance;
  }

  Future<double?> getDistanceInKM(LatLng originLatLng, LatLng destinationLatLng, {bool isDuration = false, bool isRiding = false, bool fromDashboard = false}) async {
    _distance = -1;
    Response response = await orderRepo.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        if(isDuration){
          _distance = DistanceModel.fromJson(response.body).rows![0].elements![0].duration!.value! / 3600;
        }else{
          _distance = DistanceModel.fromJson(response.body).rows![0].elements![0].distance!.value! / 1000;
        }
      } else {
        if(!isDuration) {
          _distance = Geolocator.distanceBetween(
            originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
          ) / 1000;
        }
      }
    } catch (e) {
      if(!isDuration) {
        _distance = Geolocator.distanceBetween(originLatLng.latitude, originLatLng.longitude,
            destinationLatLng.latitude, destinationLatLng.longitude) / 1000;
      }
    }
    if(!fromDashboard) {
      await getExtraCharge(_distance);
    }

    update();
    return _distance;
  }


  void setSubscription(bool isSubscribed) {
    _subscriptionOrder = isSubscribed;
    _orderType = 'delivery';
    update();
  }

  void setSubscriptionRange(DateTimeRange range) {
    _subscriptionRange = range;
    update();
  }

  void setSubscriptionType(String? type, int index) {
    _subscriptionType = type;
    _selectedDays = [];
    for(int index=0; index < (type == 'weekly' ? 7 : type == 'monthly' ? 31 : 1); index++) {
      _selectedDays.add(null);
    }
    _subscriptionTypeIndex = index;
    update();
  }

  void addDay(int index, TimeOfDay? time) {
    if(time != null) {
      _selectedDays[index] = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    }else {
      _selectedDays[index] = null;
    }
    update();
  }

  Future<bool> updateSubscriptionStatus(int? subscriptionID, DateTime? startDate, DateTime? endDate, String status, String note, String? reason) async {
    _subscriveLoading = true;
    update();
    Response response = await orderRepo.updateSubscriptionStatus(
      subscriptionID, startDate != null ? DateConverter.dateToDateAndTime(startDate) : null,
      endDate != null ? DateConverter.dateToDateAndTime(endDate) : null, status, note, reason,
    );
    bool isSuccess;
    if (response.statusCode == 200) {
      Get.back();
      if(status == 'canceled' || startDate!.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
        _trackModel!.subscription!.status = status;
      }
      showCustomSnackBar(
        status == 'paused' ? 'subscription_paused_successfully'.tr : 'subscription_cancelled_successfully'.tr, isError: false,
      );
      isSuccess = true;
    } else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    _subscriveLoading = false;
    update();
    return isSuccess;
  }


  void expandedUpdate(bool status){
    _isExpanded = status;
    update();
  }

  void setInstruction(int index){
    if(_selectedInstruction == index){
      _selectedInstruction = -1;
    }else {
      _selectedInstruction = index;
    }
    update();
  }

  void setPreferenceTimeForView(String time, bool instanceOrder, {bool isUpdate = true}){
    if(instanceOrder) {
      _preferableTime = time;
    }else {
      _preferableTime = '';
    }
    if(isUpdate) {
      update();
    }
  }

  void toggleDmTipSave() {
    _isDmTipSave = !_isDmTipSave;
    update();
  }

}

class MyClass<T> {
  final T Function() creator;
  MyClass(this.creator);

  T getGenericInstance() {
    return creator();
  }
}