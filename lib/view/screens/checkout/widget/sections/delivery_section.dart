import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_dropdown.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/screens/address/widget/address_widget.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/guest_delivery_address.dart';
import 'package:efood_multivendor/view/screens/location/widget/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliverySection extends StatelessWidget {
  final OrderController orderController;
  final RestaurantController restController;
  final LocationController locationController;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  const DeliverySection({Key? key,
    required this.orderController, required this.restController,
    required this.locationController, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode, required this.guestEmailController, required this.guestEmailNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    bool takeAway = (orderController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    GlobalKey<CustomDropdownState> dropDownKey = GlobalKey<CustomDropdownState>();
    AddressModel addressModel;

    return Column(children: [
      isGuestLoggedIn  ? GuestDeliveryAddress(
        orderController: orderController, restController: restController,
        guestNumberNode: guestNumberNode,
        guestNameTextEditingController: guestNameTextEditingController,
        guestNumberTextEditingController: guestNumberTextEditingController,
        guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
      ) : !takeAway ? Container(
        margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1, offset: const Offset(1, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('deliver_to'.tr, style: robotoMedium),
            InkWell(
              onTap: () async{
                dropDownKey.currentState?.toggleDropdown();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                child: Icon(Icons.arrow_drop_down, size: 34, color: Theme.of(context).primaryColor),
              ),
            ),
          ]),


          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Colors.transparent,
                border: Border.all(color: Colors.transparent)
            ),
            child: CustomDropdown<int>(
              key: dropDownKey,
              hideIcon: true,
              onChange: (int? value, int index) async {

                if(value == -1) {
                  var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, restController.restaurant!.zoneId));
                  if(address != null) {

                    restController.insertAddresses(Get.context!, address, notify: true);

                    orderController.streetNumberController.text = address.road ?? '';
                    orderController.houseController.text = address.house ?? '';
                    orderController.floorController.text = address.floor ?? '';

                    orderController.getDistanceInMeter(
                      LatLng(double.parse(address.latitude), double.parse(address.longitude )),
                      LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                    );
                  }
                } else if(value == -2) {
                  _checkPermission(() async {
                    addressModel = await locationController.getCurrentLocation(true, mapController: null, showSnackBar: true);

                    if(addressModel.zoneIds!.isNotEmpty) {

                      restController.insertAddresses(Get.context!, addressModel, notify: true);

                      orderController.getDistanceInMeter(
                        LatLng(
                          locationController.position.latitude, locationController.position.longitude,
                        ),
                        LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                      );
                    }
                  });

                } else{
                  orderController.getDistanceInMeter(
                    LatLng(
                      double.parse(restController.address[value!].latitude!),
                      double.parse(restController.address[value].longitude!),
                    ),
                    LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                  );
                  orderController.setAddressIndex(value);

                  orderController.streetNumberController.text = restController.address[value].road ?? '';
                  orderController.houseController.text = restController.address[value].house ?? '';
                  orderController.floorController.text = restController.address[value].floor ?? '';
                }

              },
              dropdownButtonStyle: DropdownButtonStyle(
                height: 0, width: double.infinity,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              dropdownStyle: DropdownStyle(
                elevation: 10,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              ),
              items: restController.addressList,
              child: const SizedBox(),

            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(color: Theme.of(context).primaryColor)
            ),
            child: AddressWidget(
              address: (restController.address.length-1) >= orderController.addressIndex ? restController.address[orderController.addressIndex] : restController.address[0],
              fromAddress: false, fromCheckout: true,
            ),
          ),

          SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeDefault),

          !ResponsiveHelper.isDesktop(context) ? CustomTextField(
            titleText: 'street_number'.tr,
            inputType: TextInputType.streetAddress,
            focusNode: orderController.streetNode,
            nextFocus: orderController.houseNode,
            controller: orderController.streetNumberController,
          ) : const SizedBox(),
          SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

          Row(
            children: [
              ResponsiveHelper.isDesktop(context) ? Expanded(
                child: CustomTextField(
                  titleText: 'street_number'.tr,
                  inputType: TextInputType.streetAddress,
                  focusNode: orderController.streetNode,
                  nextFocus: orderController.houseNode,
                  controller: orderController.streetNumberController,
                  showTitle: ResponsiveHelper.isDesktop(context),
                ),
              ) : const SizedBox(),
              SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

              Expanded(
                child: CustomTextField(
                  titleText: 'house'.tr,
                  inputType: TextInputType.text,
                  focusNode: orderController.houseNode,
                  nextFocus: orderController.floorNode,
                  controller: orderController.houseController,
                  showTitle: ResponsiveHelper.isDesktop(context),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: CustomTextField(
                  titleText: 'floor'.tr,
                  inputType: TextInputType.text,
                  focusNode: orderController.floorNode,
                  inputAction: TextInputAction.done,
                  controller: orderController.floorController,
                  showTitle: ResponsiveHelper.isDesktop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        ]),
      ) : const SizedBox(),
    ]);
  }

  void _checkPermission(Function onTap) async {
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
}
