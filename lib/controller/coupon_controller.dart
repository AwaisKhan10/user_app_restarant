import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/response/coupon_model.dart';
import 'package:efood_multivendor/data/repository/coupon_repo.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class CouponController extends GetxController implements GetxService {
  final CouponRepo couponRepo;
  CouponController({required this.couponRepo});

  List<CouponModel>? _couponList;
  CouponModel? _coupon;
  double? _discount = 0.0;
  bool _isLoading = false;
  bool _freeDelivery = false;
  String? _checkoutCouponCode = '';
  List<JustTheController>? _toolTipController;
  int _currentIndex = 0;

  CouponModel? get coupon => _coupon;
  double? get discount => _discount;
  bool get isLoading => _isLoading;
  bool get freeDelivery => _freeDelivery;
  List<CouponModel>? get couponList => _couponList;
  String? get checkoutCouponCode => _checkoutCouponCode;
  List<JustTheController>? get toolTipController => _toolTipController;
  int get currentIndex => _currentIndex;

  Future<void> getCouponList({int? restaurantId}) async {
    if(Get.find<UserController>().userInfoModel == null){
      await Get.find<UserController>().getUserInfo();
    }
    Response response = await couponRepo.getCouponList(Get.find<UserController>().userInfoModel!.id, restaurantId);
    if (response.statusCode == 200) {
      _couponList = [];
      _toolTipController = [];
      response.body.forEach((category) {
        _couponList!.add(CouponModel.fromJson(category));
        _toolTipController!.add(JustTheController());
      });
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getRestaurantCouponList({required int restaurantId}) async {
    _couponList = [];
    _toolTipController = [];
    Response response = await couponRepo.getRestaurantCouponList(restaurantId);
    if (response.statusCode == 200) {
      response.body.forEach((category) {
        _couponList!.add(CouponModel.fromJson(category));
        _toolTipController!.add(JustTheController());
      });
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<double?> applyCoupon(String coupon, double order, double deliveryCharge, double charge, double total, int? restaurantID, {bool hideBottomSheet = false}) async {
    _isLoading = true;
    _discount = 0;
    update();
    Response response = await couponRepo.applyCoupon(coupon, restaurantID);
    if (response.statusCode == 200) {
      _coupon = CouponModel.fromJson(response.body);
      if(_coupon!.couponType == 'free_delivery') {
        if(deliveryCharge > 0) {
          if (_coupon!.minPurchase! < order) {
            _discount = 0;
            _freeDelivery = true;
          } else {
            // Get.back();
            showCustomSnackBar('${'the_minimum_item_purchase_amount_for_this_coupon_is'.tr} '
                '${PriceConverter.convertPrice(_coupon!.minPurchase)} '
                '${'but_you_have'.tr} ${PriceConverter.convertPrice(order)}', showToaster: true,
            );
            _coupon = null;
            _discount = 0;
          }
        }else {
          showCustomSnackBar('invalid_code_or'.tr, showToaster: true);
        }

      }else {
        if (_coupon!.minPurchase != null && _coupon!.minPurchase! < order) {
          if (_coupon!.discountType == 'percent') {
            if (_coupon!.maxDiscount != null && _coupon!.maxDiscount! > 0) {
              _discount = (_coupon!.discount! * order / 100) < _coupon!.maxDiscount! ? (_coupon!.discount! * order / 100) : _coupon!.maxDiscount;
            } else {
              _discount = _coupon!.discount! * order / 100;
            }
          } else {
            if(_coupon!.discount! > order) {
              _discount = order;
            } else {
              _discount = _coupon!.discount;
            }
          }
        } else {
          _discount = 0.0;
          // Get.back();
          showCustomSnackBar('${'the_minimum_item_purchase_amount_for_this_coupon_is'.tr} '
              '${PriceConverter.convertPrice(_coupon!.minPurchase)} '
              '${'but_you_have'.tr} ${PriceConverter.convertPrice(order)}', showToaster: true,
          );
        }
      }
    } else {
      _discount = 0.0;
      if(Get.find<OrderController>().isPartialPay || Get.find<OrderController>().paymentMethodIndex == 1) {
        Get.find<OrderController>().checkBalanceStatus(total);
      }
      ApiChecker.checkApi(response, showToaster: true);
    }
    if((Get.isBottomSheetOpen! || Get.isDialogOpen!) && hideBottomSheet) {
      Get.back();
    }
    _isLoading = false;
    update();
    return _discount;
  }

  void removeCouponData(bool notify) {
    _coupon = null;
    _isLoading = false;
    _discount = 0.0;
    _freeDelivery = false;
    if(notify) {
      update();
    }
  }

  void setCoupon(String? code, {isUpdate = true}){
    _checkoutCouponCode = code;
    if(isUpdate) {
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }
}