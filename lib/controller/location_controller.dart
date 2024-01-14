import 'dart:convert';
import 'dart:math';

import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/place_details_model.dart';
import 'package:efood_multivendor/data/model/response/prediction_model.dart';
import 'package:efood_multivendor/data/model/response/response_model.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/data/repository/location_repo.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_loader.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/home/home_screen.dart';
import 'package:efood_multivendor/view/screens/location/widget/permission_dialog.dart';
import 'package:efood_multivendor/view/screens/location/widget/pick_map_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController implements GetxService {
  final LocationRepo locationRepo;
  LocationController({required this.locationRepo});

  Position _position = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
  Position _pickPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
  bool _loading = false;
  String? _address = '';
  String? _pickAddress = '';
  final List<Marker> _markers = <Marker>[];
  List<AddressModel>? _addressList;
  late List<AddressModel> _allAddressList;
  int _addressTypeIndex = 0;
  final List<String?> _addressTypeList = ['home', 'office', 'others'];
  bool _isLoading = false;
  bool _inZone = false;
  int _zoneID = 0;
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  GoogleMapController? _mapController;
  List<PredictionModel> _predictionList = [];
  bool _updateAddAddressData = true;
  bool _showLocationSuggestion = true;

  List<PredictionModel> get predictionList => _predictionList;
  bool get isLoading => _isLoading;
  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  String? get address => _address;
  String? get pickAddress => _pickAddress;
  List<Marker> get markers => _markers;
  List<AddressModel>? get addressList => _addressList;
  List<String?> get addressTypeList => _addressTypeList;
  int get addressTypeIndex => _addressTypeIndex;
  bool get inZone => _inZone;
  int get zoneID => _zoneID;
  bool get buttonDisabled => _buttonDisabled;
  GoogleMapController? get mapController => _mapController;
  bool get showLocationSuggestion => _showLocationSuggestion;

  void hideSuggestedLocation(){
    _showLocationSuggestion = !_showLocationSuggestion;
  }

  double getRestaurantDistance(LatLng restaurantLatLng){
    double distance = 0;
    distance = Geolocator.distanceBetween(restaurantLatLng.latitude, restaurantLatLng.longitude,
        double.parse(getUserAddress()!.latitude!), double.parse(getUserAddress()!.longitude!)) / 1000;

    return distance;
  }

  Future<AddressModel> getCurrentLocation(bool fromAddress, {GoogleMapController? mapController, LatLng? defaultLatLng, bool notify = true, bool showSnackBar = false}) async {
    _loading = true;
    if(notify) {
      update();
    }
    AddressModel addressModel;
    Position myPosition;
    try {
      await Geolocator.requestPermission();
      Position newLocalData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      myPosition = newLocalData;
    }catch(e) {
      myPosition = Position(
        latitude: defaultLatLng != null ? defaultLatLng.latitude : double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
        longitude: defaultLatLng != null ? defaultLatLng.longitude : double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
        timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,

      );
    }
    if(fromAddress) {
      _position = myPosition;
    }else {
      _pickPosition = myPosition;
    }
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(myPosition.latitude, myPosition.longitude), zoom: 16),
      ));
    }
    String addressFromGeocode = await getAddressFromGeocode(LatLng(myPosition.latitude, myPosition.longitude));
    fromAddress ? _address = addressFromGeocode : _pickAddress = addressFromGeocode;
    ZoneResponseModel responseModel = await getZone(myPosition.latitude.toString(), myPosition.longitude.toString(), true, showSnackBar: showSnackBar);
    _buttonDisabled = !responseModel.isSuccess;
    addressModel = AddressModel(
      latitude: myPosition.latitude.toString(), longitude: myPosition.longitude.toString(), addressType: 'others',
      zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0, zoneIds: responseModel.zoneIds,
      address: addressFromGeocode, zoneData: responseModel.zoneData,
    );
    _loading = false;
    update();
    return addressModel;
  }

  Future<void> setStoreAddressToUserAddress(LatLng restaurantAddress) async {
    Position storePosition = Position(
      latitude: restaurantAddress.latitude, longitude: restaurantAddress.longitude,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
    );
    String addressFromGeocode = await getAddressFromGeocode(LatLng(restaurantAddress.latitude, restaurantAddress.longitude));
    ZoneResponseModel responseModel = await getZone(storePosition.latitude.toString(), storePosition.longitude.toString(), true);
    _buttonDisabled = !responseModel.isSuccess;
    AddressModel addressModel = AddressModel(
      latitude: storePosition.latitude.toString(), longitude: storePosition.longitude.toString(), addressType: 'others',
      zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0, zoneIds: responseModel.zoneIds,
      address: addressFromGeocode, zoneData: responseModel.zoneData,
    );
    await Get.find<LocationController>().saveUserAddress(addressModel);

  }

  Future<ZoneResponseModel> getZone(String? lat, String? long, bool markerLoad, {bool updateInAddress = false, bool showSnackBar = false}) async {
    if(markerLoad) {
      _loading = true;
    }else {
      _isLoading = true;
    }
    if(!updateInAddress){
      update();
    }
    ZoneResponseModel responseModel;
    Response response = await locationRepo.getZone(lat, long);
    if(response.statusCode == 200) {
      _inZone = true;
      _zoneID = int.parse(jsonDecode(response.body['zone_id'])[0].toString());
      List<int> zoneIds = [];
      jsonDecode(response.body['zone_id']).forEach((zoneId){
        zoneIds.add(int.parse(zoneId.toString()));
      });
      List<ZoneData> zoneData = [];
      response.body['zone_data'].forEach((data) => zoneData.add(ZoneData.fromJson(data)));
      responseModel = ZoneResponseModel(true, '' , zoneIds, zoneData);
      if(updateInAddress) {
        AddressModel address = getUserAddress()!;
        address.zoneData = zoneData;
        saveUserAddress(address);
      }
    }else {
      _inZone = false;
      responseModel = ZoneResponseModel(false, response.statusText, [], []);
      if(showSnackBar) {
        ApiChecker.checkApi(response);
      }
    }
    if(markerLoad) {
      _loading = false;
    }else {
      _isLoading = false;
    }
    update();
    return responseModel;
  }

  void updatePosition(CameraPosition? position, bool fromAddress) async {
    if(_updateAddAddressData) {
      _loading = true;
      update();
      try {
        if (fromAddress) {
          _position = Position(
            latitude: position!.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1, altitudeAccuracy: 1, headingAccuracy: 1,
          );
        } else {
          _pickPosition = Position(
            latitude: position!.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1, altitudeAccuracy: 1, headingAccuracy: 1,
          );
        }
        ZoneResponseModel responseModel = await getZone(position.target.latitude.toString(), position.target.longitude.toString(), true);
        _buttonDisabled = !responseModel.isSuccess;
        if (_changeAddress) {
          String addressFromGeocode = await getAddressFromGeocode(LatLng(position.target.latitude, position.target.longitude));
          fromAddress ? _address = addressFromGeocode : _pickAddress = addressFromGeocode;
        } else {
          _changeAddress = true;
        }
      } catch (_) {}
      _loading = false;
      update();
    }else {
      _updateAddAddressData = true;
    }
  }

  Future<ResponseModel> deleteUserAddressByID(int? id, int index) async {
    Response response = await locationRepo.removeAddressByID(id);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _addressList!.removeAt(index);
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    update();
    return responseModel;
  }

  Future<void> getAddressList({bool canInsertAddress = false}) async {
    Response response = await locationRepo.getAllAddress();
    if (response.statusCode == 200) {
      _addressList = [];
      _allAddressList = [];
      response.body['addresses'].forEach((address) {
        _addressList!.add(AddressModel.fromJson(address));
        _allAddressList.add(AddressModel.fromJson(address));
      });
      if(canInsertAddress) {
        Get.find<RestaurantController>().insertAddresses(Get.context!, null);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void filterAddresses(String queryText) {
    if(_addressList != null) {
      _addressList = [];
      if (queryText.isEmpty) {
        _addressList!.addAll(_allAddressList);
      } else {
        for (var address in _allAddressList) {
          if (address.address!.toLowerCase().contains(queryText.toLowerCase())) {
            _addressList!.add(address);
          }
        }
      }
      update();
    }
  }

  Future<ResponseModel> addAddress(AddressModel addressModel, bool fromCheckout, int? restaurantZoneId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.addAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if(fromCheckout && !response.body['zone_ids'].contains(restaurantZoneId)) {
        responseModel = ResponseModel(false, 'your_selected_location_is_from_different_zone'.tr);
      }else {
        getAddressList();
        Get.find<OrderController>().setAddressIndex(0);
        String? message = response.body["message"];
        responseModel = ResponseModel(true, message);
      }
    } else {
      responseModel = ResponseModel(false, response.statusText == 'Out of coverage!' ? 'service_not_available_in_this_area'.tr : response.statusText);
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> updateAddress(AddressModel addressModel, int? addressId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.updateAddress(addressModel, addressId);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      getAddressList();
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<bool> saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    return await locationRepo.saveUserAddress(userAddress, address.zoneIds, address.latitude, address.longitude);
  }

  AddressModel? getUserAddress() {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(jsonDecode(locationRepo.getUserAddress()!));
    }catch(_) {}
    return addressModel;
  }

  void setAddressTypeIndex(int index, {bool notify = true}) {
    _addressTypeIndex = index;
    if(notify) {
      update();
    }
  }

  void saveAddressAndNavigate(AddressModel address, bool fromSignUp, String? route, bool canRoute, bool isDesktop) {
    if(Get.find<CartController>().cartList.isNotEmpty) {
      Get.dialog(ConfirmationDialog(
        icon: Images.warning, title: 'are_you_sure_to_reset'.tr, description: 'if_you_change_location'.tr,
        onYesPressed: () {
          Get.back();
          _setZoneData(address, fromSignUp, route, canRoute, isDesktop);
        },
        onNoPressed: () {
          Get.back();
          Get.back();
        },
      ));
    }else {
      _setZoneData(address, fromSignUp, route, canRoute, isDesktop);
    }
  }

  void _setZoneData(AddressModel address, bool fromSignUp, String? route, bool canRoute, bool isDesktop) {
    Get.find<LocationController>().getZone(address.latitude, address.longitude, false).then((response) async {
      if (response.isSuccess) {
        Get.find<CartController>().clearCartList();
        address.zoneId = response.zoneIds[0];
        address.zoneIds = [];
        address.zoneIds!.addAll(response.zoneIds);
        address.zoneData = [];
        address.zoneData!.addAll(response.zoneData);
        autoNavigate(address, fromSignUp, route, canRoute, isDesktop);
      } else {
        Get.back();
        showCustomSnackBar(response.message);
      }
    });
  }

  void autoNavigate(AddressModel? address, bool fromSignUp, String? route, bool canRoute, bool isDesktop) async {
    if(!GetPlatform.isWeb) {
      if (Get.find<LocationController>().getUserAddress() != null) {
        if(Get.find<LocationController>().getUserAddress()!.zoneIds != null) {
          for(int zoneID in Get.find<LocationController>().getUserAddress()!.zoneIds!) {
            FirebaseMessaging.instance.unsubscribeFromTopic('zone_${zoneID}_customer');
          }
        }else {
          FirebaseMessaging.instance.unsubscribeFromTopic('zone_${Get.find<LocationController>().getUserAddress()!.zoneId}_customer');
        }
      } else {
        FirebaseMessaging.instance.subscribeToTopic('zone_${address!.zoneId}_customer');
      }
      if(address!.zoneIds != null) {
        for(int zoneID in address.zoneIds!) {
          FirebaseMessaging.instance.subscribeToTopic('zone_${zoneID}_customer');
        }
      }else {
        FirebaseMessaging.instance.subscribeToTopic('zone_${address.zoneId}_customer');
      }
    }
    await Get.find<LocationController>().saveUserAddress(address!);
    if(Get.find<AuthController>().isLoggedIn()) {
      await Get.find<WishListController>().getWishList();
      Get.find<AuthController>().updateZone();
    }
    HomeScreen.loadData(true);
    Get.find<OrderController>().clearPrevData();
    if(fromSignUp) {
      Get.offAllNamed(RouteHelper.getInterestRoute());
    }else {
      if(route != null && canRoute) {
        Get.offAllNamed(route);
      }else {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    }
  }

  Future<Position> setLocation(String? placeID, String? address, GoogleMapController? mapController) async {
    _loading = true;
    update();

    LatLng latLng = const LatLng(0, 0);
    Response response = await locationRepo.getPlaceDetails(placeID);
    if(response.statusCode == 200) {
      PlaceDetailsModel placeDetails = PlaceDetailsModel.fromJson(response.body);
      if(placeDetails.status == 'OK') {
        latLng = LatLng(placeDetails.result!.geometry!.location!.lat!, placeDetails.result!.geometry!.location!.lng!);
      }
    }

    _pickPosition = Position(
      latitude: latLng.latitude, longitude: latLng.longitude,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
    );

    _pickAddress = address;
    _changeAddress = false;

    if(mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)));
    }
    _loading = false;
    update();
    return _pickPosition;
  }

  void disableButton() {
    _buttonDisabled = true;
    _inZone = true;
    update();
  }

  void setAddAddressData() {
    _position = _pickPosition;
    _address = _pickAddress;
    _updateAddAddressData = false;
    update();
  }

  void setUpdateAddress(AddressModel address){
    _position = Position(
      latitude: double.parse(address.latitude!), longitude: double.parse(address.longitude!), timestamp: DateTime.now(),
      altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, floor: 1, accuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
    );
    _address = address.address;
    _addressTypeIndex = _addressTypeList.indexOf(address.addressType);
  }

  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }

  void setMapController(GoogleMapController mapController) {
    _mapController = mapController;
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response = await locationRepo.getAddressFromGeocode(latLng);
    String address = 'Unknown Location Found';
    if(response.statusCode == 200 && response.body['status'] == 'OK') {
      address = response.body['results'][0]['formatted_address'].toString();
    }else {
      showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
    }
    return address;
  }

  Future<List<PredictionModel>> searchLocation(BuildContext context, String text) async {
    if(text.isNotEmpty) {
      Response response = await locationRepo.searchLocation(text);
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _predictionList = [];
        response.body['predictions'].forEach((prediction) => _predictionList.add(PredictionModel.fromJson(prediction)));
      } else {
        showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
      }
    }
    return _predictionList;
  }

  void setPlaceMark(String address) {
    _address = address;
  }

  void checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    }else {
      onTap();
    }
  }


  Future<bool> checkLocationActive() async {
    bool isActiveLocation = await Geolocator.isLocationServiceEnabled();

    if(isActiveLocation) {
      AddressModel currentAddress = await getCurrentLocation(true);
      AddressModel? selectedAddress = getUserAddress();

      double? distance = await Get.find<OrderController>().getDistanceInKM(
        LatLng(double.parse(currentAddress.latitude!), double.parse(currentAddress.longitude!)),
        LatLng(double.parse(selectedAddress!.latitude!), double.parse(selectedAddress.longitude!)),
        fromDashboard: true,
      );
      // if (kDebugMode) {
      //   print('======== distance is : $distance');
      // }
      if(distance! > 1){
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
  }

  Future<void> zoomToFit(GoogleMapController controller, List<LatLng> list, {double padding = 0.5}) async {
    LatLngBounds bounds = _computeBounds(list);
    LatLng centerBounds = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude)/2,
      (bounds.northeast.longitude + bounds.southwest.longitude)/2,
    );

    controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 16)));

    bool keepZoomingOut = true;

    int count = 0;
    while(keepZoomingOut) {
      count++;
      final LatLngBounds screenBounds = await controller.getVisibleRegion();
      if(_fits(bounds, screenBounds) || count == 200) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool _fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  LatLngBounds _computeBounds(List<LatLng> list) {
    assert(list.isNotEmpty);
    var firstLatLng = list.first;
    var s = firstLatLng.latitude,
        n = firstLatLng.latitude,
        w = firstLatLng.longitude,
        e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      var latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }

  Future<void> navigateToLocationScreen(String page, {bool offNamed = false, bool offAll = false}) async {
    bool fromSignup = page == RouteHelper.signUp;
    bool fromHome = page == 'home';
    if(!fromHome && Get.find<LocationController>().getUserAddress() != null) {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      Get.find<LocationController>().autoNavigate(
        Get.find<LocationController>().getUserAddress(), fromSignup, null, false, ResponsiveHelper.isDesktop(Get.context)
      );
    }else if(Get.find<AuthController>().isLoggedIn()) {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      await Get.find<LocationController>().getAddressList();
      Get.back();
      if(Get.find<LocationController>().addressList != null && Get.find<LocationController>().addressList!.isEmpty) {
        if(ResponsiveHelper.isDesktop(Get.context)) {
          showGeneralDialog(context: Get.context!, pageBuilder: (_,__,___) {
            return SizedBox(
              height: 300, width: 300,
              child: PickMapDialog(
                  fromSignUp: (page == RouteHelper.signUp), canRoute: false, fromAddAddress: false, route: null),
            );
          });
        } else {
          Get.toNamed(RouteHelper.getPickMapRoute(page, false));
        }
      }else {
        if(offNamed) {
          Get.offNamed(RouteHelper.getAccessLocationRoute(page));
        }else if(offAll) {
          Get.offAllNamed(RouteHelper.getAccessLocationRoute(page));
        }else {
          Get.toNamed(RouteHelper.getAccessLocationRoute(page));
        }
      }
    }else {
      if(ResponsiveHelper.isDesktop(Get.context)) {
        showGeneralDialog(context: Get.context!, pageBuilder: (_,__,___) {
          return SizedBox(
            height: 300, width: 300,
            child: PickMapDialog(
              fromSignUp: (page == RouteHelper.signUp), canRoute: false, fromAddAddress: false, route: null),
          );
        });
      } else {
        Get.toNamed(RouteHelper.getPickMapRoute(page, false));
      }
    }
  }

}
