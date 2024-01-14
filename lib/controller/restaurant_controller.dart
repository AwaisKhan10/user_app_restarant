import 'package:efood_multivendor/controller/category_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/cart_suggested_item_model.dart';
import 'package:efood_multivendor/data/model/response/category_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/recommended_product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/data/model/response/review_model.dart';
import 'package:efood_multivendor/data/repository/restaurant_repo.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_dropdown.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/address/widget/address_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantController extends GetxController implements GetxService {
  final RestaurantRepo restaurantRepo;
  RestaurantController({required this.restaurantRepo});

  RestaurantModel? _restaurantModel;
  List<Restaurant>? _restaurantList;
  List<Restaurant>? _popularRestaurantList;
  List<Restaurant>? _latestRestaurantList;
  List<Restaurant>? _recentlyViewedRestaurantList;
  Restaurant? _restaurant;
  List<Product>? _restaurantProducts;
  ProductModel? _restaurantProductModel;
  ProductModel? _restaurantSearchProductModel;
  int _categoryIndex = 0;
  List<CategoryModel>? _categoryList;
  bool _isLoading = false;
  String _restaurantType = 'all';
  List<ReviewModel>? _restaurantReviewList;
  bool _foodPaginate = false;
  int? _foodPageSize;
  List<int> _foodOffsetList = [];
  int _foodOffset = 1;
  String _type = 'all';
  String _searchType = 'all';
  String _searchText = '';
  RecommendedProductModel? _recommendedProductModel;
  CartSuggestItemModel? _cartSuggestItemModel;
  List<Product>? _suggestedItems;
  int? _foodPageOffset ;
  bool _isSearching = false;
  List<Restaurant>? _orderAgainRestaurantList;
  int _topRated = 0;
  int _discount = 0;
  int _veg = 0;
  int _nonVeg = 0;
  List<DropdownItem<int>> _addressList = [];
  List<AddressModel> _address = [];


  RestaurantModel? get restaurantModel => _restaurantModel;
  List<Restaurant>? get restaurantList => _restaurantList;
  List<Restaurant>? get popularRestaurantList => _popularRestaurantList;
  List<Restaurant>? get latestRestaurantList => _latestRestaurantList;
  List<Restaurant>? get recentlyViewedRestaurantList => _recentlyViewedRestaurantList;
  Restaurant? get restaurant => _restaurant;
  ProductModel? get restaurantProductModel => _restaurantProductModel;
  ProductModel? get restaurantSearchProductModel => _restaurantSearchProductModel;
  List<Product>? get restaurantProducts => _restaurantProducts;
  int get categoryIndex => _categoryIndex;
  List<CategoryModel>? get categoryList => _categoryList;
  bool get isLoading => _isLoading;
  String get restaurantType => _restaurantType;
  List<ReviewModel>? get restaurantReviewList => _restaurantReviewList;
  bool get foodPaginate => _foodPaginate;
  int? get foodPageSize => _foodPageSize;
  int get foodOffset => _foodOffset;
  String get type => _type;
  String get searchType => _searchType;
  String get searchText => _searchText;
  RecommendedProductModel? get recommendedProductModel => _recommendedProductModel;
  CartSuggestItemModel? get cartSuggestItemModel => _cartSuggestItemModel;
  List<Product>? get suggestedItems => _suggestedItems;
  int? get foodPageOffset => _foodPageOffset;
  bool get isSearching => _isSearching;
  List<Restaurant>? get orderAgainRestaurantList => _orderAgainRestaurantList;
  int get topRated => _topRated;
  int get discount => _discount;
  int get veg => _veg;
  int get nonVeg => _nonVeg;
  List<DropdownItem<int>> get addressList => _addressList;
  List<AddressModel> get address => _address;

  void insertAddresses(BuildContext context, AddressModel? addressModel, {bool notify = false}) {
    _addressList = [];
    _address = [];

    _addressList.add(
        DropdownItem<int>(value: -1, child: SizedBox(
          width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(children: [
              const Expanded(child: SizedBox()),
              Text(
                'add_new_address'.tr,
                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Icon(Icons.add_circle_outline_sharp, size: 20, color: Theme.of(context).primaryColor)
            ]),
          ),
        ))
    );

    _address.add(Get.find<LocationController>().getUserAddress()!);
    _addressList.add(
        DropdownItem<int>(value: 0, child: SizedBox(
          width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
          child: AddressWidget(
            address: Get.find<LocationController>().getUserAddress(),
            fromAddress: false, fromCheckout: true,
          ),
        ))
    );

    if(restaurant != null) {
      if(Get.find<LocationController>().addressList != null) {
        int i = 0;
        for(int index=0; index<Get.find<LocationController>().addressList!.length; index++) {
          if(Get.find<LocationController>().addressList![index].zoneIds!.contains(restaurant!.zoneId)) {

            _address.add(Get.find<LocationController>().addressList![index]);
            _addressList.add(DropdownItem<int>(value: i + 1, child: SizedBox(
              width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
              child: AddressWidget(
                address: Get.find<LocationController>().addressList![index],
                fromAddress: false, fromCheckout: true,
              ),
            )));
            i++;
          }
        }

      }

      if(addressModel != null) {
        _address.add(addressModel);
        _addressList.add(DropdownItem<int>(value: _address.length- 1, child: SizedBox(
          width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
          child: AddressWidget(
            address: addressModel,
            fromAddress: false, fromCheckout: true,
          ),
        )));
        Get.find<OrderController>().setAddressIndex(_address.length- 1);
      }

      _addressList.add(
          DropdownItem<int>(value: -2, child: SizedBox(
            width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Row(children: [
                const Expanded(child: SizedBox()),

                Icon(Icons.my_location_sharp, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(
                  'use_my_current_location'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                ),
                const Expanded(child: SizedBox()),

              ]),
            ),
          ))
      );
    }
    if(notify) {
      update();
    }
  }

  String filteringUrl(String slug){
    List<String> routes = Get.currentRoute.split('?');
    String replace = '';
    if(slug.isNotEmpty){
      replace = '${routes[0]}?slug=$slug';
    }else {
      replace = '${routes[0]}?slug=${_restaurant!.id}';
    }
    return replace;
  }

  Future<void> getOrderAgainRestaurantList(bool reload) async {
    if(reload) {
      _orderAgainRestaurantList = null;
      update();
    }
    Response response = await restaurantRepo.getOrderAgainRestaurantList();
    if (response.statusCode == 200) {
      _orderAgainRestaurantList = [];
      response.body.forEach((restaurant) => _orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant)));

    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }


  Future<void> getRecentlyViewedRestaurantList(bool reload, String type, bool notify) async {
    _type = type;
    if(reload){
      _recentlyViewedRestaurantList = null;
    }
    if(notify) {
      update();
    }
    if(_recentlyViewedRestaurantList == null || reload) {
      Response response = await restaurantRepo.getRecentlyViewedRestaurantList(type);
      if (response.statusCode == 200) {
        _recentlyViewedRestaurantList = [];
        response.body.forEach((restaurant) => _recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant)));

      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getRestaurantRecommendedItemList(int? restaurantId, bool reload) async {
    _recommendedProductModel = null;
    if(reload) {
      _restaurantModel = null;
      update();
    }
    Response response = await restaurantRepo.getRestaurantRecommendedItemList(restaurantId);
    if (response.statusCode == 200) {
      _recommendedProductModel = RecommendedProductModel.fromJson(response.body);

    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }



  Future<void> getRestaurantList(int offset, bool reload) async {
    if(reload) {
      _restaurantModel = null;
      update();
    }
    Response response = await restaurantRepo.getRestaurantList(offset, _restaurantType, _topRated, _discount, _veg, _nonVeg);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _restaurantModel = RestaurantModel.fromJson(response.body);
      }else {
        _restaurantModel!.totalSize = RestaurantModel.fromJson(response.body).totalSize;
        _restaurantModel!.offset = RestaurantModel.fromJson(response.body).offset;
        _restaurantModel!.restaurants!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void setRestaurantType(String type) {
    _restaurantType = type;
    getRestaurantList(1, true);
  }

  void setTopRated() {
    if(_topRated == 0) {
      _topRated = 1;
    }else {
      _topRated = 0;
    }
    getRestaurantList(1, true);
  }
  void setDiscount() {
    if(_discount == 0) {
      _discount = 1;
    }else {
      _discount = 0;
    }
    getRestaurantList(1, true);
  }

  void setVeg() {
    if(_veg == 0) {
      _veg = 1;
    }else {
      _veg = 0;
    }
    getRestaurantList(1, true);
  }

  void setNonVeg() {
    if(_nonVeg == 0) {
      _nonVeg = 1;
    }else {
      _nonVeg = 0;
    }
    getRestaurantList(1, true);
  }

  Future<void> getPopularRestaurantList(bool reload, String type, bool notify) async {
    _type = type;
    if(reload){
      _popularRestaurantList = null;
    }
    if(notify) {
      update();
    }
    if(_popularRestaurantList == null || reload) {
      Response response = await restaurantRepo.getPopularRestaurantList(type);
      if (response.statusCode == 200) {
        _popularRestaurantList = [];
        response.body.forEach((restaurant) => _popularRestaurantList!.add(Restaurant.fromJson(restaurant)));
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getLatestRestaurantList(bool reload, String type, bool notify) async {
    _type = type;
    if(reload){
      _latestRestaurantList = null;
    }
    if(notify) {
      update();
    }
    if(_latestRestaurantList == null || reload) {
      Response response = await restaurantRepo.getLatestRestaurantList(type);
      if (response.statusCode == 200) {
        _latestRestaurantList = [];
        response.body.forEach((restaurant) => _latestRestaurantList!.add(Restaurant.fromJson(restaurant)));
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void setCategoryList() {
    if(Get.find<CategoryController>().categoryList != null && _restaurant != null) {
      _categoryList = [];
      _categoryList!.add(CategoryModel(id: 0, name: 'all'.tr));
      for (var category in Get.find<CategoryController>().categoryList!) {
        if(_restaurant!.categoryIds!.contains(category.id)) {
          _categoryList!.add(category);
        }
      }
    }
  }

  Future<void> initCheckoutData(int? restaurantID) async {
    // if(_restaurant == null || _restaurant!.id != restaurantID || Get.find<OrderController>().distance == null) {
    //   Get.find<CouponController>().removeCouponData(false);
    //   Get.find<OrderController>().clearPrevData();
    //   Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantID));
    // }else {
    //   Get.find<OrderController>().initializeTimeSlot(_restaurant!);
    // }
    Get.find<CouponController>().removeCouponData(false);
    Get.find<OrderController>().clearPrevData();
    await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantID));
    Get.find<OrderController>().initializeTimeSlot(_restaurant!);
    insertAddresses(Get.context!, null);
  }

  Future<Restaurant?> getRestaurantDetails(Restaurant restaurant, {bool fromCart = false, String slug = ''}) async {
    _categoryIndex = 0;
    if(restaurant.name != null) {
      _restaurant = restaurant;
    }else {
      _isLoading = true;
      _restaurant = null;
      Response response = await restaurantRepo.getRestaurantDetails(restaurant.id.toString(), slug);
      if (response.statusCode == 200) {
        _restaurant = Restaurant.fromJson(response.body);
        if(_restaurant != null && _restaurant!.latitude != null){
          Get.find<OrderController>().initializeTimeSlot(_restaurant!);
          if(!fromCart && slug.isEmpty){
            Get.find<OrderController>().getDistanceInMeter(
              LatLng(
                double.parse(Get.find<LocationController>().getUserAddress()!.latitude!),
                double.parse(Get.find<LocationController>().getUserAddress()!.longitude!),
              ),
              LatLng(double.parse(_restaurant!.latitude!), double.parse(_restaurant!.longitude!)),
            );
          }
          if(slug.isNotEmpty){
            await Get.find<LocationController>().setStoreAddressToUserAddress(LatLng(double.parse(_restaurant!.latitude!), double.parse(_restaurant!.longitude!)));
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
      Get.find<OrderController>().setOrderType(
        (_restaurant != null && _restaurant!.delivery != null) ? _restaurant!.delivery! ? 'delivery' : 'take_away' : 'delivery', notify: false,
      );

      _isLoading = false;
      update();
    }
    return _restaurant;
  }

  void makeEmptyRestaurant() {
    _restaurant = null;
    update();
  }

  Future<void> getCartRestaurantSuggestedItemList(int? restaurantID) async {
    Response response = await restaurantRepo.getCartRestaurantSuggestedItemList(restaurantID);
    if (response.statusCode == 200) {
      _suggestedItems =  [];
      response.body.forEach((product) {
        _suggestedItems!.add(Product.fromJson(product));
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getRestaurantProductList(int? restaurantID, int offset, String type, bool notify) async {
    _foodOffset = offset;
    if(offset == 1 || _restaurantProducts == null) {
      _type = type;
      _foodOffsetList = [];
      _restaurantProducts = null;
      _foodOffset = 1;
      if(notify) {
        update();
      }
    }
    if (!_foodOffsetList.contains(offset)) {
      _foodOffsetList.add(offset);
      Response response = await restaurantRepo.getRestaurantProductList(
        restaurantID, offset,
        (_restaurant != null && _restaurant!.categoryIds!.isNotEmpty && _categoryIndex != 0)
            ? _categoryList![_categoryIndex].id : 0, type,
      );
      if (response.statusCode == 200) {
        if (offset == 1) {
          _restaurantProducts = [];
        }
        _restaurantProducts!.addAll(ProductModel.fromJson(response.body).products!);
        _foodPageSize = ProductModel.fromJson(response.body).totalSize;
        _foodPageOffset = ProductModel.fromJson(response.body).offset;
        _foodPaginate = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_foodPaginate) {
        _foodPaginate = false;
        update();
      }
    }
  }

  void showFoodBottomLoader() {
    _foodPaginate = true;
    update();
  }

  void setFoodOffset(int offset) {
    _foodOffset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<void> getRestaurantSearchProductList(String searchText, String? storeID, int offset, String type) async {
    if(searchText.isEmpty) {
      showCustomSnackBar('write_item_name'.tr);
    }else {
      _isSearching = true;
      _searchText = searchText;
      if(offset == 1 || _restaurantSearchProductModel == null) {
        _searchType = type;
        _restaurantSearchProductModel = null;
        update();
      }
      Response response = await restaurantRepo.getRestaurantSearchProductList(searchText, storeID, offset, type);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _restaurantSearchProductModel = ProductModel.fromJson(response.body);
        }else {
          _restaurantSearchProductModel!.products!.addAll(ProductModel.fromJson(response.body).products!);
          _restaurantSearchProductModel!.totalSize = ProductModel.fromJson(response.body).totalSize;
          _restaurantSearchProductModel!.offset = ProductModel.fromJson(response.body).offset;
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void changeSearchStatus({bool isUpdate = true}) {
    _isSearching = !_isSearching;
    if(isUpdate) {
      update();
    }
  }

  void initSearchData() {
    _restaurantSearchProductModel = ProductModel(products: []);
    _searchText = '';
  }

  void setCategoryIndex(int index) {
    _categoryIndex = index;
    _restaurantProducts = null;
    getRestaurantProductList(_restaurant!.id, 1, Get.find<RestaurantController>().type, false);
    update();
  }

  Future<void> getRestaurantReviewList(String? restaurantID) async {
    _restaurantReviewList = null;
    Response response = await restaurantRepo.getRestaurantReviewList(restaurantID);
    if (response.statusCode == 200) {
      _restaurantReviewList = [];
      response.body.forEach((review) => _restaurantReviewList!.add(ReviewModel.fromJson(review)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  bool isRestaurantClosed(DateTime dateTime, bool active, List<Schedules>? schedules, {int? customDateDuration}) {
    if(!active) {
      return true;
    }
    DateTime date = dateTime;
    int weekday = date.weekday;
    if(weekday == 7) {
      weekday = 0;
    }
    for(int index=0; index<schedules!.length; index++) {
      if(weekday == schedules[index].day) {
        return false;
      }
    }
    return true;
  }

  bool isRestaurantOpenNow(bool active, List<Schedules>? schedules) {
    if(isRestaurantClosed(DateTime.now(), active, schedules)) {
      return false;
    }
    int weekday = DateTime.now().weekday;
    if(weekday == 7) {
      weekday = 0;
    }
    for(int index=0; index<schedules!.length; index++) {
      if(weekday == schedules[index].day
          && DateConverter.isAvailable(schedules[index].openingTime, schedules[index].closingTime)) {
        return true;
      }
    }
    return false;
  }

  bool isOpenNow(Restaurant restaurant) => restaurant.open == 1 && restaurant.active!;

  double? getDiscount(Restaurant restaurant) => restaurant.discount != null ? restaurant.discount!.discount : 0;

  String? getDiscountType(Restaurant restaurant) => restaurant.discount != null ? restaurant.discount!.discountType : 'percent';

}