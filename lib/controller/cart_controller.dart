import 'dart:convert';

import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/online_cart_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/repository/cart_repo.dart';
import 'package:efood_multivendor/helper/cart_helper.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class CartController extends GetxController implements GetxService {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});

  List<CartModel> _cartList = [];
  List<OnlineCartModel> _onlineCartList = [];

  double _subTotal = 0;
  double _itemPrice = 0;
  double _itemDiscountPrice = 0;
  double _addOns = 0;
  List<List<AddOns>> _addOnsList = [];
  List<bool> _availableList = [];
  bool _addCutlery = false;
  int _notAvailableIndex = -1;
  List<String> notAvailableList = ['Remove it from my cart', 'I’ll wait until it’s restocked', 'Please cancel the order', 'Call me ASAP', 'Notify me when it’s back'];
  bool _isLoading = false;
  double _variationPrice = 0;

  List<CartModel> get cartList => _cartList;
  List<OnlineCartModel> get onlineCartList => _onlineCartList;
  double get subTotal => _subTotal;
  double get itemPrice => _itemPrice;
  double get itemDiscountPrice => _itemDiscountPrice;
  double get addOns => _addOns;
  List<List<AddOns>> get addOnsList => _addOnsList;
  List<bool> get availableList => _availableList;
  bool get addCutlery => _addCutlery;
  int get notAvailableIndex => _notAvailableIndex;
  bool get isLoading => _isLoading;
  double get variationPrice => _variationPrice;

  double calculationCart(){
    _itemPrice = 0 ;
    _itemDiscountPrice = 0;
    _subTotal = 0;
    _addOns = 0;
    _availableList= [];
    _addOnsList = [];
    _variationPrice = 0;
    double variationWithoutDiscountPrice = 0;
    double variationPrice = 0;
    for (var cartModel in _cartList) {

      variationWithoutDiscountPrice = 0;
      variationPrice = 0;

      double? discount = cartModel.product!.restaurantDiscount == 0 ? cartModel.product!.discount : cartModel.product!.restaurantDiscount;
      String? discountType = cartModel.product!.restaurantDiscount == 0 ? cartModel.product!.discountType : 'percent';

      List<AddOns> addOnList = [];
      for (var addOnId in cartModel.addOnIds!) {
        for(AddOns addOns in cartModel.product!.addOns!) {
          if(addOns.id == addOnId.id) {
            addOnList.add(addOns);
            break;
          }
        }
      }
      _addOnsList.add(addOnList);

      _availableList.add(DateConverter.isAvailable(cartModel.product!.availableTimeStarts, cartModel.product!.availableTimeEnds));

      for(int index=0; index<addOnList.length; index++) {
        _addOns = _addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
      }

      if(cartModel.product!.variations!.isNotEmpty) {
        for(int index = 0; index< cartModel.product!.variations!.length; index++) {
          for(int i=0; i<cartModel.product!.variations![index].variationValues!.length; i++) {
            if(cartModel.variations![index][i]!) {
              variationWithoutDiscountPrice += (PriceConverter.convertWithDiscount(cartModel.product!.variations![index].variationValues![i].optionPrice!, discount, discountType, isVariation: true)! * cartModel.quantity!);
              variationPrice += (cartModel.product!.variations![index].variationValues![i].optionPrice! * cartModel.quantity!);
            }
          }
        }
      } else {
        variationWithoutDiscountPrice = 0;
        variationPrice = 0;
      }

      double price = (cartModel.product!.price! * cartModel.quantity!);
      double discountPrice =  (price - (PriceConverter.convertWithDiscount(cartModel.product!.price!, discount, discountType)! * cartModel.quantity!));

      _variationPrice += variationPrice;
      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice + (variationPrice - variationWithoutDiscountPrice);

      print('==check : ${_cartList.indexOf(cartModel)} ====> $_itemDiscountPrice = $_itemDiscountPrice + $discountPrice + ($variationPrice - $variationWithoutDiscountPrice)');
    }
    _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns + _variationPrice;

    return _subTotal;
  }

  Future<void> reorderAddToCart(List<OnlineCart> cartList) async {
    print('=======reorder cart data : ${jsonEncode(cartList)}');
    await clearCartList();
    addMultipleCartItemOnline(cartList);

    update();
  }

  void setQuantity(bool isIncrement, CartModel cart, {int? cartIndex}) {
    int index = cartIndex ?? _cartList.indexOf(cart);
    if (isIncrement) {
      int? quantityLimit = _cartList[index].product!.quantityLimit;
      if(quantityLimit != null) {
        if(_cartList[index].quantity! >= quantityLimit && quantityLimit != 0) {
          showCustomSnackBar('${'maximum_quantity_limit'.tr} $quantityLimit', showToaster: true);
        } else {
          _cartList[index].quantity = _cartList[index].quantity! + 1;
        }
      }else {
        _cartList[index].quantity = _cartList[index].quantity! + 1;
      }
    } else {
      _cartList[index].quantity = _cartList[index].quantity! - 1;
    }
    cartRepo.addToCartList(_cartList);

    calculationCart();

    updateCartQuantityOnline(_cartList[index].id!, _cartList[index].price!, _cartList[index].quantity!);

    update();
  }

  void removeFromCart(int index) {
    int cartId = _cartList[index].id!;
    _cartList.removeAt(index);
    update();
    removeCartItemOnline(cartId);
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index].addOnIds!.removeAt(addOnIndex);
    cartRepo.addToCartList(_cartList);
    calculationCart();
    update();
  }

  Future<void> clearCartList() async {
    _cartList = [];
    if(Get.find<AuthController>().isLoggedIn() || Get.find<AuthController>().isGuestLoggedIn()) {
      await clearCartOnline();
    }
  }


  int isExistInCart(int? productID, int? cartIndex) {
    for(int index=0; index<_cartList.length; index++) {
      if(_cartList[index].product!.id == productID) {
        if((index == cartIndex)) {
          return -1;
        }else {
          return index;
        }
      }
    }
    return -1;
  }

  int isExistInCartForBottomSheet(int? productID, int? cartIndex, List<List<bool?>>? variations) {
    for(int index=0; index<_cartList.length; index++) {
      if(_cartList[index].product!.id == productID) {
        if((index == cartIndex)) {
          return -1;
        }else {
          if(variations != null) {
            bool same = false;
            for(int i=0; i<variations.length; i++) {
              for(int j=0; j<variations[i].length; j++) {
                if(variations[i][j] == _cartList[index].variations![i][j]) {
                  same = true;
                } else {
                  same = false;
                  break;
                }

              }
              if(!same) {
                break;
              }
            }
            if(!same) {
              continue;
            }
            if(same) {
              return index;
            } else {
              return -1;
            }
          } else {
            return -1;
          }
        }
      }
    }
    return -1;
  }


  int? getCartIndex (Product product) {
    for(int index = 0; index < _cartList.length; index ++) {
      if(_cartList[index].product!.id == product.id ) {
        if(_cartList[index].product!.variations![0].multiSelect  != null){
          if(_cartList[index].product!.variations![0].multiSelect == product.variations![0].multiSelect){
            return index;
          }
        }
        else{
          return index;
        }

      }
    }
    return null;
  }

  bool existAnotherRestaurantProduct(int? restaurantID) {
    for(CartModel cartModel in _cartList) {
      if(cartModel.product!.restaurantId != restaurantID) {
        return true;
      }
    }
    return false;
  }

  void updateCutlery({bool isUpdate = true}){
    _addCutlery = !_addCutlery;
    if(isUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool isUpdate = true}){
    if(_notAvailableIndex == index){
      _notAvailableIndex = -1;
    }else {
      _notAvailableIndex = index;
    }
    if(isUpdate) {
      update();
    }
  }

  int cartQuantity(int productID) {
    int quantity = 0;
    for(CartModel cart in _cartList) {
      if(cart.product!.id == productID) {
        quantity += cart.quantity!;
      }
    }
    return quantity;
  }


  Future<void> addToCartOnline(OnlineCart cart) async {
    _isLoading = true;
    update();
    Response response = await cartRepo.addToCartOnline(cart, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if(response.statusCode == 200) {
      _onlineCartList = [];
      _cartList = [];
      response.body.forEach((cart) => _onlineCartList.add(OnlineCartModel.fromJson(cart)));

      print('----------check : ${jsonEncode(_onlineCartList)}');

      _cartList.addAll(CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList));
      calculationCart();
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> addMultipleCartItemOnline(List<OnlineCart> cartList) async {
    _isLoading = true;
    update();
    Response response = await cartRepo.addMultipleCartItemOnline(cartList);
    if(response.statusCode == 200) {
      _onlineCartList = [];
      _cartList = [];
      response.body.forEach((cart) => _onlineCartList.add(OnlineCartModel.fromJson(cart)));

      print('-------multiple cart---check : ${jsonEncode(_onlineCartList)}');

      _cartList.addAll(CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList));
      calculationCart();
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateCartOnline(OnlineCart cart) async {
    _isLoading = true;
    update();
    Response response = await cartRepo.updateCartOnline(cart, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if(response.statusCode == 200) {
      _onlineCartList = [];
      _cartList = [];
      response.body.forEach((cart) => _onlineCartList.add(OnlineCartModel.fromJson(cart)));

      _cartList.addAll(CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList));
      calculationCart();


    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateCartQuantityOnline(int cartId, double price, int quantity) async {
    _isLoading = true;
    update();
    Response response = await cartRepo.updateCartQuantityOnline(cartId, price, quantity, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if(response.statusCode == 200) {
      getCartDataOnline();
      calculationCart();

    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> getCartDataOnline() async {
    _isLoading = true;
    Response response = await cartRepo.getCartDataOnline(Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if(response.statusCode == 200) {
      _onlineCartList = [];
      _cartList = [];
      response.body.forEach((cart) => _onlineCartList.add(OnlineCartModel.fromJson(cart)));

      _cartList.addAll(CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList));
      calculationCart();

    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<bool> removeCartItemOnline(int cartId) async {
    _isLoading = true;
    bool isSuccess = false;
    update();
    Response response = await cartRepo.removeCartItemOnline(cartId, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if(response.statusCode == 200) {
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
    }
    getCartDataOnline();
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<bool> clearCartOnline() async {
    _isLoading = true;
    bool isSuccess = false;
    update();
    Response response = await cartRepo.clearCartOnline(Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if(response.statusCode == 200) {
      isSuccess = true;
      getCartDataOnline();
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return isSuccess;
  }

}
