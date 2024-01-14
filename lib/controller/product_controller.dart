import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/body/review_body.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/order_details_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/response_model.dart';
import 'package:efood_multivendor/data/repository/product_repo.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/view/base/cart_snackbar.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductController extends GetxController implements GetxService {
  final ProductRepo productRepo;
  ProductController({required this.productRepo});

  // Latest products
  List<Product>? _popularProductList;
  List<Product>? _reviewedProductList;
  bool _isLoading = false;
  List<List<bool?>> _selectedVariations = [];
  int? _quantity = 1;
  List<bool> _addOnActiveList = [];
  List<int?> _addOnQtyList = [];
  String _popularType = 'all';
  String _reviewedType = 'all';
  static final List<String> _productTypeList = ['all', 'veg', 'non_veg'];
  int _cartIndex = -1;
  int _imageIndex = 0;
  List<bool> _collapsVariation = [];

  List<Product>? get popularProductList => _popularProductList;
  List<Product>? get reviewedProductList => _reviewedProductList;
  bool get isLoading => _isLoading;
  List<List<bool?>> get selectedVariations => _selectedVariations;
  int? get quantity => _quantity;
  List<bool> get addOnActiveList => _addOnActiveList;
  List<int?> get addOnQtyList => _addOnQtyList;
  String get popularType => _popularType;
  String get reviewType => _reviewedType;
  List<String> get productTypeList => _productTypeList;
  int get cartIndex => _cartIndex;
  int get imageIndex => _imageIndex;
  List<bool> get collapsVariation => _collapsVariation;

  Future<void> getPopularProductList(bool reload, String type, bool notify) async {
    _popularType = type;
    if(reload) {
      _popularProductList = null;
    }
    if(notify) {
      update();
    }
    if(_popularProductList == null || reload) {
      Response response = await productRepo.getPopularProductList(type);
      if (response.statusCode == 200) {
        _popularProductList = [];
        _popularProductList!.addAll(ProductModel.fromJson(response.body).products!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getReviewedProductList(bool reload, String type, bool notify) async {
    _reviewedType = type;
    if(reload) {
      _reviewedProductList = null;
    }
    if(notify) {
      update();
    }
    if(_reviewedProductList == null || reload) {
      Response response = await productRepo.getReviewedProductList(type);
      if (response.statusCode == 200) {
        _reviewedProductList = [];
        _reviewedProductList!.addAll(ProductModel.fromJson(response.body).products!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setImageIndex(int index, bool notify) {
    _imageIndex = index;
    if(notify) {
      update();
    }
  }

  void initData(Product? product, CartModel? cart) {
    _selectedVariations = [];
    _addOnQtyList = [];
    _addOnActiveList = [];
    _collapsVariation = [];
    if(cart != null) {
      _quantity = cart.quantity;
      _selectedVariations.addAll(cart.variations!);
      List<int?> addOnIdList = [];
      for (var addOnId in cart.addOnIds!) {
        addOnIdList.add(addOnId.id);
      }
      for (var addOn in product!.addOns!) {
        if(addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList.add(cart.addOnIds![addOnIdList.indexOf(addOn.id)].quantity);
        }else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      }
      if(product.variations != null){
        for(int index=0; index<product.variations!.length; index++){
          _collapsVariation.add(true);
        }
      }
    }else {
      _quantity = 1;
      if(product!.variations != null){
        for(int index=0; index<product.variations!.length; index++) {
          _selectedVariations.add([]);
          _collapsVariation.add(true);
          for(int i=0; i < product.variations![index].variationValues!.length; i++) {
            _selectedVariations[index].add(false);
          }
        }
      }

      for (var addOn in product.addOns!) {
        debugPrint('$addOn');
        _addOnActiveList.add(false);
        _addOnQtyList.add(1);
      }

    }
    setExistInCartForBottomSheet(product, selectedVariations);
  }

  int selectedVariationLength(List<List<bool?>> selectedVariations, int index) {
    int length = 0;
    for(bool? isSelected in selectedVariations[index]) {
      if(isSelected!) {
        length++;
      }
    }
    return length;
  }

  int setExistInCart(Product product, {bool notify = true}) {
    // List<String> _variationList = [];
    // for (int index = 0; index < product.choiceOptions.length; index++) {
    //   // _variationList.add(product.choiceOptions[index].options[_variationIndex[index]].replaceAll(' ', ''));
    // }
    // String variationType = '';
    // bool isFirst = true;
    // _variationList.forEach((variation) {
    //   if (isFirst) {
    //     variationType = '$variationType$variation';
    //     isFirst = false;
    //   } else {
    //     variationType = '$variationType-$variation';
    //   }
    // });
    _cartIndex = Get.find<CartController>().isExistInCart(product.id, null);
    if(_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartList[_cartIndex].quantity;
      _addOnActiveList = [];
      _addOnQtyList = [];
      List<int?> addOnIdList = [];
      for (var addOnId in Get.find<CartController>().cartList[_cartIndex].addOnIds!) {
        addOnIdList.add(addOnId.id);
      }
      for (var addOn in product.addOns!) {
        if(addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList.add(Get.find<CartController>().cartList[_cartIndex].addOnIds![addOnIdList.indexOf(addOn.id)].quantity);
        }else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      }
    }
    return _cartIndex;
  }

  int setExistInCartForBottomSheet(Product product, List<List<bool?>>? selectedVariations, {bool notify = true}) {

    _cartIndex = Get.find<CartController>().isExistInCartForBottomSheet(product.id, null, selectedVariations);
    if(_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartList[_cartIndex].quantity;
      _addOnActiveList = [];
      _addOnQtyList = [];
      List<int?> addOnIdList = [];
      for (var addOnId in Get.find<CartController>().cartList[_cartIndex].addOnIds!) {
        addOnIdList.add(addOnId.id);
      }
      for (var addOn in product.addOns!) {
        if(addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList.add(Get.find<CartController>().cartList[_cartIndex].addOnIds![addOnIdList.indexOf(addOn.id)].quantity);
        }else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      }
    } else {
      _quantity = 1;
    }
    return _cartIndex;
  }

  void setAddOnQuantity(bool isIncrement, int index) {
    if (isIncrement) {
      _addOnQtyList[index] = _addOnQtyList[index]! + 1;
    } else {
      _addOnQtyList[index] = _addOnQtyList[index]! - 1;
    }
    update();
  }

  void setQuantity(bool isIncrement, int? quantityLimit) {
    if (isIncrement) {
      if(quantityLimit != null ){
        if(_quantity! >= quantityLimit && quantityLimit != 0) {
          showCustomSnackBar('${'maximum_quantity_limit'.tr} $quantityLimit', showToaster: true);
        } else {
          _quantity = _quantity! + 1;
        }
      }else {
        _quantity = _quantity! + 1;
      }
    } else {
      _quantity = _quantity! - 1;
    }
    update();
  }

  void setCartVariationIndex(int index, int i, Product? product, bool isMultiSelect) {
    if(!isMultiSelect) {
      for(int j = 0; j < _selectedVariations[index].length; j++) {
        if(product!.variations![index].required!){
          _selectedVariations[index][j] = j == i;
        }else{
          if(_selectedVariations[index][j]!){
            _selectedVariations[index][j] = false;
          }else{
            _selectedVariations[index][j] = j == i;
          }
        }
      }
    } else {
      if(!_selectedVariations[index][i]! && selectedVariationLength(_selectedVariations, index) >= product!.variations![index].max!) {
        _showUpperCartSnackBar('${'maximum_variation_for'.tr} ${product.variations![index].name} ${'is'.tr} ${product.variations![index].max}');
      }else {
        _selectedVariations[index][i] = !_selectedVariations[index][i]!;
      }
    }
    update();
  }

  void _showUpperCartSnackBar(String message) {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: Colors.red,
      message: message,
      duration: const Duration(seconds: 3),
      maxWidth: Dimensions.webMaxWidth,
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      borderRadius: 10,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    ));
  }

  void addAddOn(bool isAdd, int index) {
    _addOnActiveList[index] = isAdd;
    update();
  }

  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  int _deliveryManRating = 0;

  List<int> get ratingList => _ratingList;
  List<String> get reviewList => _reviewList;
  List<bool> get loadingList => _loadingList;
  List<bool> get submitList => _submitList;
  int get deliveryManRating => _deliveryManRating;

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    for (var orderDetails in orderDetailsList) {
      debugPrint('$orderDetails');
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    update();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    update();
  }

  Future<ResponseModel> submitReview(int index, ReviewBody reviewBody) async {
    _loadingList[index] = true;
    update();

    Response response = await productRepo.submitReview(reviewBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      update();
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _loadingList[index] = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBody reviewBody) async {
    _isLoading = true;
    update();
    Response response = await productRepo.submitDeliveryManReview(reviewBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _deliveryManRating = 0;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      update();
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  // double getStartingPrice(Product product) {
  //   double _startingPrice = 0;
  //   if (product.choiceOptions.length != 0) {
  //     List<double> _priceList = [];
  //     product.variations.forEach((variation) => _priceList.add(variation.price));
  //     _priceList.sort((a, b) => a.compareTo(b));
  //     _startingPrice = _priceList[0];
  //   } else {
  //     _startingPrice = product.price;
  //   }
  //   return _startingPrice;
  // }

  bool isAvailable(Product product) {
    return DateConverter.isAvailable(product.availableTimeStarts, product.availableTimeEnds);
  }

  void showMoreSpecificSection(int index){
    _collapsVariation[index] = !_collapsVariation[index];
    update();
  }

  double? getDiscount(Product product) => product.restaurantDiscount == 0 ? product.discount : product.restaurantDiscount;

  String? getDiscountType(Product product) => product.restaurantDiscount == 0 ? product.discountType : 'percent';

  void productDirectlyAddToCart(Product? product, BuildContext context, {bool inStore = false, bool isCampaign = false}) {

    print('------check : ${product!.variations == null || (product.variations != null && product.variations!.isEmpty)}');
    print('------check item : ${product.toJson()}');
    if (product.variations == null || (product.variations != null && product.variations!.isEmpty)) {
      double price = product.price!;
      double discount = product.discount!;
      double discountPrice = PriceConverter.convertWithDiscount(price, discount, product.discountType)!;

      // CartModel cartModel = CartModel(
      //   null, price, discount, [], [], (price - discountPrice), 1, [], [], isCampaign,
      //   product.stock, product, product.quantityLimit != null ? product.quantityLimit! : null,
      // );

      CartModel cartModel = CartModel(
        null, price, discountPrice, (price - discountPrice),
        1, [], [], false, product, [], product.quantityLimit,
      );

      // OnlineCart onlineCart = OnlineCart(
      //   null, isCampaign ? null : product.id, isCampaign ? product.id : null, price.toString(),
      //   '', null, Get.find<SplashController>().getModuleConfig(product.moduleType).newVariation! ? [] : null,
      //   1, [], [], [], 'Item',
      // );

      OnlineCart onlineCart = OnlineCart(
        null, isCampaign ? null : product.id, isCampaign ? product.id : null,
        discountPrice.toString(), [], 1, [], [], [], 'Food',
      );

      Get.find<ProductController>().setExistInCart(product);

      if (Get.find<CartController>().existAnotherRestaurantProduct(cartModel.product!.restaurantId)) {
        Get.dialog(ConfirmationDialog(
          icon: Images.warning,
          title: 'are_you_sure_to_reset'.tr,
          description: 'if_you_continue'.tr,
          onYesPressed: () {
            Get.find<CartController>().clearCartOnline().then((success) async {
              if (success) {
                await Get.find<CartController>().addToCartOnline(onlineCart);
                Get.back();
                showCartSnackBar();
              }
            });
          },
        ), barrierDismissible: false);
      } else {
        Get.find<CartController>().addToCartOnline(onlineCart);
        showCartSnackBar();
      }
    } else {
      ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
        ProductBottomSheet(product: product, isCampaign: false),
        backgroundColor: Colors.transparent, isScrollControlled: true,
      ) : Get.dialog(
        Dialog(child: ProductBottomSheet(product: product, isCampaign: false)),
      );
    }
  }

}
