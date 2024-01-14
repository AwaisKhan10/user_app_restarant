import 'dart:async';

import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/data/model/body/business_plan_body.dart';
import 'package:efood_multivendor/data/model/body/signup_body.dart';
import 'package:efood_multivendor/data/model/body/social_log_in_body.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/data/model/response/order_model.dart';
import 'package:efood_multivendor/data/model/response/package_model.dart';
import 'package:efood_multivendor/data/model/response/response_model.dart';
import 'package:efood_multivendor/data/model/response/vehicle_model.dart';
import 'package:efood_multivendor/data/model/response/zone_model.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/data/repository/auth_repo.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_method_bottom_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo}) {
    _notification = authRepo.isNotificationActive();
  }

  bool _isLoading = false;
  bool _guestLoading = false;
  bool _notification = true;
  bool _acceptTerms = true;
  XFile? _pickedLogo;
  XFile? _pickedCover;
  List<ZoneModel>? _zoneList;
  int? _selectedZoneIndex = 0;
  LatLng? _restaurantLocation;
  List<int>? _zoneIds;
  XFile? _pickedImage;
  List<XFile> _pickedIdentities = [];
  final List<String> _identityTypeList = ['select_identity_type', 'passport', 'driving_license', 'nid'];
  int _identityTypeIndex = 0;
  final List<String?> _dmTypeList = ['select_dm_type', 'freelancer', 'salary_based'];
  int _dmTypeIndex = 0;
  int _businessIndex = 0;
  List<String> subscriptionImages = [Images.subscription1, Images.subscription2, Images.subscription3];
  PackageModel? _packageModel;
  int _activeSubscriptionIndex = 0;
  String _businessPlanStatus = 'business';
  int _paymentIndex = 0;
  // int _restaurantId;
  bool isFirstTime = true;
  List<VehicleModel>? _vehicles;
  List<int?>? _vehicleIds;
  int? _vehicleIndex = 0;
  double _dmStatus = 0.4;
  bool _lengthCheck = false;
  bool _numberCheck = false;
  bool _uppercaseCheck = false;
  bool _lowercaseCheck = false;
  bool _spatialCheck = false;
  double _storeStatus = 0.4;
  String _storeMinTime = '--';
  String _storeMaxTime = '--';
  String _storeTimeUnit = 'minute';
  bool _showPassView = false;
  String? _restaurantAddress;
  String? _digitalPaymentName;
  List<DataModel>? _dataList;
  List<dynamic>? _additionalList;

  bool get isLoading => _isLoading;
  bool get guestLoading => _guestLoading;
  bool get notification => _notification;
  bool get acceptTerms => _acceptTerms;
  XFile? get pickedLogo => _pickedLogo;
  XFile? get pickedCover => _pickedCover;
  List<ZoneModel>? get zoneList => _zoneList;
  int? get selectedZoneIndex => _selectedZoneIndex;
  LatLng? get restaurantLocation => _restaurantLocation;
  List<int>? get zoneIds => _zoneIds;
  XFile? get pickedImage => _pickedImage;
  List<XFile> get pickedIdentities => _pickedIdentities;
  List<String> get identityTypeList => _identityTypeList;
  int get identityTypeIndex => _identityTypeIndex;
  List<String?> get dmTypeList => _dmTypeList;
  int get dmTypeIndex => _dmTypeIndex;
  int get businessIndex => _businessIndex;
  int get activeSubscriptionIndex => _activeSubscriptionIndex;
  String get businessPlanStatus => _businessPlanStatus;
  int get paymentIndex => _paymentIndex;
  PackageModel? get packageModel => _packageModel;
  List<VehicleModel>? get vehicles => _vehicles;
  List<int?>? get vehicleIds => _vehicleIds;
  int? get vehicleIndex => _vehicleIndex;
  double get dmStatus => _dmStatus;
  bool get lengthCheck => _lengthCheck;
  bool get numberCheck => _numberCheck;
  bool get uppercaseCheck => _uppercaseCheck;
  bool get lowercaseCheck => _lowercaseCheck;
  bool get spatialCheck => _spatialCheck;
  double get storeStatus => _storeStatus;
  String get storeMinTime => _storeMinTime;
  String get storeMaxTime => _storeMaxTime;
  String get storeTimeUnit => _storeTimeUnit;
  bool get showPassView => _showPassView;
  String? get restaurantAddress => _restaurantAddress;
  String? get digitalPaymentName => _digitalPaymentName;
  List<DataModel>? get dataList => _dataList;
  List<dynamic>? get additionalList => _additionalList;


  void setRestaurantAdditionalJoinUsPageData({bool isUpdate = true}){
    _dataList = [];
    _additionalList = [];
    if(Get.find<SplashController>().configModel!.restaurantAdditionalJoinUsPageData != null) {
      for (var data in Get.find<SplashController>().configModel!.restaurantAdditionalJoinUsPageData!.data!) {
        int index = Get.find<SplashController>().configModel!.restaurantAdditionalJoinUsPageData!.data!.indexOf(data);
        _dataList!.add(data);
        if(data.fieldType == 'text' || data.fieldType == 'number' || data.fieldType == 'email' || data.fieldType == 'phone'){
          _additionalList!.add(TextEditingController());
        } else if(data.fieldType == 'date') {
          _additionalList!.add(null);
        } else if(data.fieldType == 'check_box') {
          _additionalList!.add([]);
          if(data.checkData != null) {
            for (var element in data.checkData!) {
              _additionalList![index].add(0);
            }
          }
        } else if(data.fieldType == 'file') {
          _additionalList!.add([]);
        }

      }
    }

    if(isUpdate) {
      update();
    }
  }

  void setDeliverymanAdditionalJoinUsPageData({bool isUpdate = true}){
    _dataList = [];
    _additionalList = [];
    if(Get.find<SplashController>().configModel!.deliverymanAdditionalJoinUsPageData != null) {
      for (var data in Get.find<SplashController>().configModel!.deliverymanAdditionalJoinUsPageData!.data!) {
        int index = Get.find<SplashController>().configModel!.deliverymanAdditionalJoinUsPageData!.data!.indexOf(data);
        _dataList!.add(data);
        if(data.fieldType == 'text' || data.fieldType == 'number' || data.fieldType == 'email' || data.fieldType == 'phone'){
          _additionalList!.add(TextEditingController());
        } else if(data.fieldType == 'date') {
          _additionalList!.add(null);
        } else if(data.fieldType == 'check_box') {
          _additionalList!.add([]);
          if(data.checkData != null) {
            for (var element in data.checkData!) {
              _additionalList![index].add(0);
            }
          }
        } else if(data.fieldType == 'file') {
          _additionalList!.add([]);
        }
      }
    }

    if(isUpdate) {
      update();
    }
  }

  void setAdditionalDate(int index, String date) {
    _additionalList![index] = date;
    update();
  }

  void setAdditionalCheckData(int index, int i, String date) {
    if(_additionalList![index][i] == date){
      _additionalList![index][i] = 0;
    } else {
      _additionalList![index][i] = date;
    }
    update();
  }

  Future<void> pickFile(int index, MediaData mediaData) async {

    List<String> permission = [];
    if(mediaData.image == 1) {
      permission.add('jpg');
    }
    if(mediaData.pdf == 1) {
      permission.add('pdf');
    }
    if(mediaData.docs == 1) {
      permission.add('doc');
    }

    FilePickerResult? result;

    if(GetPlatform.isWeb){
      result = await FilePicker.platform.pickFiles(
        // type:  FileType.any,
        // allowMultiple: false,
        withReadStream: true,
      );
    }else{
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: permission,
        allowMultiple: false,
      );
    }
    if(result != null && result.files.isNotEmpty) {
      if(result.files.single.size > 2000000) {
        showCustomSnackBar('please_upload_lower_size_file'.tr);
      } else {
        _additionalList![index].add(result);
      }
    }
    update();
  }

  void removeAdditionalFile(int index, int subIndex) {
    _additionalList![index].removeAt(subIndex);
    update();
  }

  Future<ResponseModel> guestLogin() async {
    _guestLoading = true;
    update();
    Response response = await authRepo.guestLogin();
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveGuestId(response.body['guest_id'].toString());

      responseModel = ResponseModel(true, '${response.body['guest_id']}');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _guestLoading = false;
    update();
    return responseModel;
  }

  void changeDigitalPaymentName(String? name, {bool canUpdate = true}){
    _digitalPaymentName = name;
    if(canUpdate) {
      update();
    }
  }

  void showHidePass({bool isUpdate = true}){
    _showPassView = ! _showPassView;
    if(isUpdate) {
      update();
    }
  }

  void minTimeChange(String time){
    _storeMinTime = time;
    update();
  }

  void maxTimeChange(String time){
    _storeMaxTime = time;
    update();
  }

  void timeUnitChange(String unit){
    _storeTimeUnit = unit;
    update();
  }

  void resetBusiness(){
    _businessIndex = Get.find<SplashController>().configModel!.businessPlan!.commission == 0 ? 1 : 0;
    _activeSubscriptionIndex = 0;
    _businessPlanStatus = 'business';
    isFirstTime = true;
    _paymentIndex = Get.find<SplashController>().configModel!.freeTrialPeriodStatus == 0 ? 1 : 0;
  }

  void setPaymentIndex(int index){
    _paymentIndex = index;
    update();
  }

  void setBusiness(int business){
    _activeSubscriptionIndex = 0;
    _businessIndex = business;
    update();
  }

  void setBusinessStatus(String status){
    _businessPlanStatus = status;
    update();
  }

  void selectSubscriptionCard(int index){
    _activeSubscriptionIndex = index;
    update();
  }

  void showBackPressedDialogue(String title){
    Get.dialog(ConfirmationDialog(icon: Images.support,
      title: title,
      description: 'are_you_sure_to_go_back'.tr, isLogOut: true,
      onYesPressed: () {
      if(Get.isDialogOpen!){
        Get.back();
      }
      Get.back();
      },
    ), useSafeArea: false);
  }

  Future<void> getPackageList({bool isUpdate = true}) async {
      Response response = await authRepo.getPackageList();
      if (response.statusCode == 200) {
        _packageModel = null;
        _packageModel = PackageModel.fromJson(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
      if(isUpdate) {
        update();
      }
  }

  Future<void> submitBusinessPlan({required int restaurantId})async {
    String businessPlan;
    if(businessIndex == 0){
      businessPlan = 'commission';
      setUpBusinessPlan(BusinessPlanBody(businessPlan: businessPlan, restaurantId: restaurantId.toString()));

    }else{
      _businessPlanStatus = 'payment';
      if(!isFirstTime) {
        if (_businessPlanStatus == 'payment' && _packageModel!.packages!.isNotEmpty) {

          businessPlan = 'subscription';
          int? packageId = _packageModel!.packages![_activeSubscriptionIndex].id;
          String payment = _paymentIndex == 0 ? 'free_trial' : 'paying_now';

          if(_paymentIndex == 1 && digitalPaymentName == null) {
            if(ResponsiveHelper.isDesktop(Get.context)) {
              Get.dialog(const Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
                isCashOnDeliveryActive: false, isWalletActive: false, isDigitalPaymentActive: true,
                isSubscriptionPackage: true, totalPrice: 0, isOfflinePaymentActive: false,
              )));
            } else {
              showModalBottomSheet(
                context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
                builder: (con) => const PaymentMethodBottomSheet(
                  isCashOnDeliveryActive: false, isWalletActive: false, isDigitalPaymentActive: true,
                  isSubscriptionPackage: true, totalPrice: 0, isOfflinePaymentActive: false,
                ),
              );
            }
          } else {
            setUpBusinessPlan(BusinessPlanBody(businessPlan: businessPlan,
                packageId: packageId.toString(),
                restaurantId: restaurantId.toString(),
                payment: payment),
            );
          }

        } else if(_packageModel!.packages!.isEmpty && _packageModel!.packages!.isEmpty){
          showCustomSnackBar('no_package_found'.tr);
        } else {
          showCustomSnackBar('please Select Any Process');
        }
      }else{
        isFirstTime = false;
      }
    }

    update();
  }

  Future<ResponseModel> setUpBusinessPlan(BusinessPlanBody businessPlanBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.setUpBusinessPlan(businessPlanBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if(response.body['id'] != null) {
        _subscriptionPayment(response.body['id']);
      }else {
        _businessPlanStatus = 'complete';
        Future.delayed(const Duration(seconds: 2),()=> Get.offAllNamed(RouteHelper.getInitialRoute()));
      }
      responseModel = ResponseModel(true, response.body.toString());
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> _subscriptionPayment(String id) async {
    _isLoading = true;
    update();
    Response response = await authRepo.subscriptionPayment(id, digitalPaymentName!);
    ResponseModel responseModel;
    if (response.statusCode == 200) {

      String redirectUrl = response.body['redirect_link'];
      Get.back();
      if(GetPlatform.isWeb) {
        // String? hostname = html.window.location.hostname;
        // String protocol = html.window.location.protocol;
        // redirectUrl = '$redirectUrl&&callback=$protocol//$hostname${RouteHelper.orderSuccess}';
        // print('-link : $redirectUrl');
        html.window.open(redirectUrl,"_self");

      } else{
        Get.toNamed(RouteHelper.getPaymentRoute(OrderModel(), digitalPaymentName, subscriptionUrl: redirectUrl, guestId: Get.find<AuthController>().getGuestId(),));
      }
      responseModel = ResponseModel(true, response.body.toString());
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> getVehicleList() async {
    Response response = await authRepo.getVehicleList();
    if (response.statusCode == 200) {
      _vehicles = [];
      _vehicleIds = [];
      _vehicles!.add(VehicleModel(id: 0, type: 'select_vehicle_type'));
      _vehicleIds!.add(0);
      response.body.forEach((vehicle) => _vehicles!.add(VehicleModel.fromJson(vehicle)));
      response.body.forEach((vehicle) => _vehicleIds!.add(VehicleModel.fromJson(vehicle).id));

    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setVehicleIndex(int? index, bool notify) {
    _vehicleIndex = index;
    if(notify) {
      update();
    }
  }

  Future<ResponseModel> registration(SignUpBody signUpBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registration(signUpBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if(!Get.find<SplashController>().configModel!.customerVerification!) {
        authRepo.saveUserToken(response.body["token"]);
        await authRepo.updateToken();
        authRepo.clearGuestId();
        Get.find<UserController>().getUserInfo();
      }
      responseModel = ResponseModel(true, response.body["token"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> login(String? phone, String password, {bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    Response response = await authRepo.login(phone: phone, password: password);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if(Get.find<SplashController>().configModel!.customerVerification! && response.body['is_phone_verified'] == 0) {

      }else {
        authRepo.saveUserToken(response.body['token'], alreadyInApp: alreadyInApp);
        await authRepo.updateToken();
        authRepo.clearGuestId();
        Get.find<UserController>().getUserInfo();
        Get.find<CartController>().getCartDataOnline();
      }
      responseModel = ResponseModel(true, '${response.body['is_phone_verified']}${response.body['token']}');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> loginWithSocialMedia(SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.loginWithSocialMedia(socialLogInBody);
    if (response.statusCode == 200) {
      String? token = response.body['token'];
      if(token != null && token.isNotEmpty) {
        if(Get.find<SplashController>().configModel!.customerVerification! && response.body['is_phone_verified'] == 0) {
          Get.toNamed(RouteHelper.getVerificationRoute(response.body['phone'] ?? socialLogInBody.email, token, RouteHelper.signUp, ''));
        }else {
          authRepo.saveUserToken(response.body['token']);
          await authRepo.updateToken();
          authRepo.clearGuestId();
          Get.toNamed(RouteHelper.getAccessLocationRoute('sign-in'));
        }
      }else {
        Get.toNamed(RouteHelper.getForgotPassRoute(true, socialLogInBody));
      }
    } else if(response.statusCode == 403 && response.body['errors'][0]['code'] == 'email'){
        Get.toNamed(RouteHelper.getForgotPassRoute(true, socialLogInBody));
    } else {
      showCustomSnackBar(response.statusText);
    }
    _isLoading = false;
    update();
  }

  Future<void> registerWithSocialMedia(SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerWithSocialMedia(socialLogInBody);
    if (response.statusCode == 200) {
      String? token = response.body['token'];
      if(Get.find<SplashController>().configModel!.customerVerification! && response.body['is_phone_verified'] == 0) {
        Get.toNamed(RouteHelper.getVerificationRoute(socialLogInBody.phone, token, RouteHelper.signUp, ''));
      }else {
        authRepo.saveUserToken(response.body['token']);
        await authRepo.updateToken();
        authRepo.clearGuestId();
        Get.toNamed(RouteHelper.getAccessLocationRoute('sign-in'));
      }
    } else {
      showCustomSnackBar(response.statusText);
    }
    _isLoading = false;
    update();
  }

  Future<ResponseModel> forgetPassword(String? email) async {
    _isLoading = true;
    update();
    Response response = await authRepo.forgetPassword(email);

    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  Future<ResponseModel> verifyToken(String? email) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyToken(email, _verificationCode);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> resetPassword(String? resetToken, String number, String password, String confirmPassword) async {
    _isLoading = true;
    update();
    Response response = await authRepo.resetPassword(resetToken, number, password, confirmPassword);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> checkEmail(String email) async {
    _isLoading = true;
    update();
    Response response = await authRepo.checkEmail(email);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["token"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyEmail(String email, String token) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyEmail(email, _verificationCode);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveUserToken(token);
      await authRepo.updateToken();
      authRepo.clearGuestId();
      Get.find<UserController>().getUserInfo();
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyPhone(String? phone, String? token) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyPhone(phone, _verificationCode);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveUserToken(token!);
      await authRepo.updateToken();
      authRepo.clearGuestId();
      Get.find<UserController>().getUserInfo();
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateZone() async {
    Response response = await authRepo.updateZone();
    if (response.statusCode == 200) {
      // Nothing to do
    } else {
      ApiChecker.checkApi(response);
    }
  }

  String _verificationCode = '';

  String get verificationCode => _verificationCode;

  void updateVerificationCode(String query, {bool canUpdate = true}) {
    _verificationCode = query;
    if(canUpdate){
      update();
    }
  }


  bool _isActiveRememberMe = false;

  bool get isActiveRememberMe => _isActiveRememberMe;

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  bool isGuestLoggedIn() {
    return authRepo.isGuestLoggedIn();
  }

  String getGuestId() {
    return authRepo.getGuestId();
  }

  bool clearSharedData() {
    return authRepo.clearSharedData();
  }

  Future<void> socialLogout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    await FacebookAuth.instance.logOut();
  }

  void saveUserNumberAndPassword(String number, String password, String countryCode) {
    authRepo.saveUserNumberAndPassword(number, password, countryCode);
  }

  String getUserNumber() {
    return authRepo.getUserNumber();
  }

  String getUserCountryCode() {
    return authRepo.getUserCountryCode();
  }

  String getUserPassword() {
    return authRepo.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authRepo.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authRepo.getUserToken();
  }

  void saveEarningPoint(String point){
    authRepo.saveEarningPoint(point);
  }

  String getEarningPint() {
    return authRepo.getEarningPint();
  }

  bool setNotificationActive(bool isActive) {
    _notification = isActive;
    authRepo.setNotificationActive(isActive);
    update();
    return _notification;
  }

  bool clearSharedAddress() {
    return authRepo.clearSharedAddress();
  }

  void pickImage(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedLogo = null;
      _pickedCover = null;
    }else {
      if (isLogo) {
        XFile? pickLogo = await ImagePicker().pickImage(source: ImageSource.gallery);
        if(pickLogo != null) {
          pickLogo.length().then((value) {
            if (value > 2000000) {
              showCustomSnackBar('please_upload_lower_size_file'.tr);
            } else {
              _pickedLogo = pickLogo;
            }
          });
        }
      } else {
        XFile? pickCover = await ImagePicker().pickImage(source: ImageSource.gallery);
        if(pickCover != null) {
          pickCover.length().then((value) {
            if (value > 2000000) {
              showCustomSnackBar('please_upload_lower_size_file'.tr);
            } else {
              _pickedCover = pickCover;
            }
          });
        }
      }
      update();
    }
  }

  void removeDmImage(){
    _pickedImage = null;
    update();
  }

  Future<void> getZoneList() async {
    _pickedLogo = null;
    _pickedCover = null;
    _selectedZoneIndex = 0;
    _restaurantLocation = null;
    _zoneIds = null;
    Response response = await authRepo.getZoneList();
    if (response.statusCode == 200) {
      _zoneList = [];
      _zoneList!.add(ZoneModel(id: 0, name: 'select_zone'));
      response.body.forEach((zone) => _zoneList!.add(ZoneModel.fromJson(zone)));
      setLocation(LatLng(
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
      ));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setZoneIndex(int? index) {
    _selectedZoneIndex = index;
    update();
  }

  void setLocation(LatLng location) async {
    ZoneResponseModel response = await Get.find<LocationController>().getZone(
      location.latitude.toString(), location.longitude.toString(), false,
    );
    _restaurantAddress = await Get.find<LocationController>().getAddressFromGeocode(LatLng(location.latitude, location.longitude));
    if(response.isSuccess && response.zoneIds.isNotEmpty) {
      _restaurantLocation = location;
      _zoneIds = response.zoneIds;
      for(int index=0; index<_zoneList!.length; index++) {
        if(_zoneIds!.contains(_zoneList![index].id)) {
          _selectedZoneIndex = 0;
          break;
        }
      }
    }else {
      _restaurantLocation = null;
      _zoneIds = null;
    }
    update();
  }

  Future<void> registerRestaurant(Map<String, String> data, List<FilePickerResult> additionalDocuments, List<String> inputTypeList) async {
    _isLoading = true;
    update();
    List<MultipartDocument> multiPartsDocuments = [];
    List<String> dataName = [];
    for(String data in inputTypeList) {
      dataName.add('additional_documents[$data]');
    }
    for(FilePickerResult file in additionalDocuments) {
      int index = additionalDocuments.indexOf(file);
      multiPartsDocuments.add(MultipartDocument('${dataName[index]}[]', file));
    }
    Response response = await authRepo.registerRestaurant(data, _pickedLogo, _pickedCover, multiPartsDocuments);
    if(response.statusCode == 200) {
      int? restaurantId = response.body['restaurant_id'];
      Get.offAllNamed(RouteHelper.getBusinessPlanRoute(restaurantId));
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  // bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
  //   int intersectCount = 0;
  //   for (int j = 0; j < vertices.length - 1; j++) {
  //     if (_rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
  //       intersectCount++;
  //     }
  //   }
  //
  //   return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  // }

  // bool _rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
  //   double aY = vertA.latitude;
  //   double bY = vertB.latitude;
  //   double aX = vertA.longitude;
  //   double bX = vertB.longitude;
  //   double pY = tap.latitude;
  //   double pX = tap.longitude;
  //
  //   if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
  //     return false; // a and b can't both be above or below pt.y, and a or
  //     // b must be east of pt.x
  //   }
  //
  //   double m = (aY - bY) / (aX - bX); // Rise over run
  //   double bee = (-aX) * m + aY; // y = mx + b
  //   double x = (pY - bee) / m; // algebra is neat!
  //
  //   return x > pX;
  // }

  void setIdentityTypeIndex(String? identityType, bool notify) {
    int index0 = 0;
    for(int index=0; index<_identityTypeList.length; index++) {
      if(_identityTypeList[index] == identityType) {
        index0 = index;
        break;
      }
    }
    _identityTypeIndex = index0;
    if(notify) {
      update();
    }
  }

  void initIdentityTypeIndex() {
    _identityTypeIndex = 0;
  }

  void setDMTypeIndex(int dmType, bool notify) {
    _dmTypeIndex = dmType;
    if(notify) {
      update();
    }
  }

  void pickDmImage(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    }else {
      if (isLogo) {
        XFile? pickLogo = await ImagePicker().pickImage(source: ImageSource.gallery);
        if(pickLogo != null) {
          pickLogo.length().then((value) {
            if(value > 2000000) {
              showCustomSnackBar('please_upload_lower_size_file'.tr);
            }else {
              _pickedImage = pickLogo;
            }
          });
        }
      } else {
        XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if(xFile != null) {
          xFile.length().then((value) {
            if(value > 2000000) {
              showCustomSnackBar('please_upload_lower_size_file'.tr);
            } else {
              _pickedIdentities.add(xFile);
            }
          });
        }
      }
      update();
    }
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }

  Future<void> registerDeliveryMan(Map<String, String> data, List<FilePickerResult> additionalDocuments, List<String> inputTypeList) async {
    _isLoading = true;
    update();
    List<MultipartBody> multiParts = [];
    multiParts.add(MultipartBody('image', _pickedImage));
    for(XFile file in _pickedIdentities) {
      multiParts.add(MultipartBody('identity_image[]', file));
    }

    List<MultipartDocument> multiPartsDocuments = [];
    List<String> dataName = [];
    for(String data in inputTypeList) {
      dataName.add('additional_documents[$data]');
    }
    for(FilePickerResult file in additionalDocuments) {
      int index = additionalDocuments.indexOf(file);
      multiPartsDocuments.add(MultipartDocument('${dataName[index]}[]', file));
    }

    Response response = await authRepo.registerDeliveryMan(data, multiParts, multiPartsDocuments);
    if (response.statusCode == 200) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar('delivery_man_registration_successful'.tr, isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }


  void dmStatusChange(double value, {bool isUpdate = true}){
    _dmStatus = value;
    if(isUpdate) {
      update();
    }
  }

  void saveDmTipIndex(String i){
    authRepo.saveDmTipIndex(i);
  }

  String getDmTipIndex() {
    return authRepo.getDmTipIndex();
  }


  void storeStatusChange(double value, {bool isUpdate = true}){
    _storeStatus = value;
    if(isUpdate) {
      update();
    }
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if(pass.length > 7){
      _lengthCheck = true;
    }
    if(pass.contains(RegExp(r'[a-z]'))){
      _lowercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[A-Z]'))){
      _uppercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[ .!@#$&*~^%]'))){
      _spatialCheck = true;
    }
    if(pass.contains(RegExp(r'[\d+]'))){
      _numberCheck = true;
    }
    if(isUpdate) {
      update();
    }
  }

  void resetDeliveryRegistration(){
    _identityTypeIndex = 0;
    _dmTypeIndex = 0;
    _selectedZoneIndex = 0;
    _pickedImage = null;
    _pickedIdentities = [];
    update();
  }


  void resetRestaurantRegistration() {
    _pickedLogo = null;
    _pickedCover = null;
    _storeMinTime = '--';
    _storeMaxTime = '--';
    _storeTimeUnit = 'minute';
    update();
  }

  Future<void> saveGuestNumber(String number) async {
    authRepo.saveGuestContactNumber(number);
  }

  String getGuestNumber() {
    return authRepo.getGuestContactNumber();
  }


}