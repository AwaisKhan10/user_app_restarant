import 'dart:convert';

import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepo{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CartRepo({required this.apiClient, required this.sharedPreferences});

  List<CartModel> getCartList() {
    List<String>? carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList);
    }
    List<CartModel> cartList = [];
    for (var cart in carts!) {
      cartList.add(CartModel.fromJson(jsonDecode(cart)));
    }
    return cartList;
  }

  void addToCartList(List<CartModel> cartProductList) {
    List<String> carts = [];
    for (var cartModel in cartProductList) {
      carts.add(jsonEncode(cartModel));
    }
    sharedPreferences.setStringList(AppConstants.cartList, carts);
  }

  Future<Response> addToCartOnline(OnlineCart cart, String? guestId) async {
    return apiClient.postData('${AppConstants.addCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', cart.toJson());
  }

  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts) async {
    List<Map<String, dynamic>> cartList = [];
    for (var cart in carts) {
      cartList.add(cart.toJson());
    }
    return apiClient.postData(AppConstants.addMultipleItemCartUri, {'item_list': cartList});
  }

  Future<Response> updateCartOnline(OnlineCart cart, String? guestId) async {
    return apiClient.postData('${AppConstants.updateCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', cart.toJson());
  }

  Future<Response> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId) async {
    Map<String, dynamic> data = {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
    };
    return apiClient.postData('${AppConstants.updateCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', data);
  }

  Future<Response> getCartDataOnline(String? guestId) async {
    // Map<String, String>? header ={
    //   'Content-Type': 'application/json; charset=UTF-8',
    //   AppConstants.localizationKey: AppConstants.languages[0].languageCode!,
    //   AppConstants.moduleId: '${Get.find<SplashController>().getCacheModule()}',
    //   'Authorization': 'Bearer ${sharedPreferences.getString(AppConstants.token)}'
    // };

    return apiClient.getData(
      '${AppConstants.getCartListUri}${guestId != null ? '?guest_id=$guestId' : ''}',
    );
  }

  Future<Response> removeCartItemOnline(int cartId, String? guestId) async {
    return apiClient.deleteData('${AppConstants.removeItemCartUri}?cart_id=$cartId${guestId != null ? '&guest_id=$guestId' : ''}');
  }

  Future<Response> clearCartOnline(String? guestId) async {
    return apiClient.deleteData('${AppConstants.removeAllCartUri}${guestId != null ? '?guest_id=$guestId' : ''}');
  }

}