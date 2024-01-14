import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_loader.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/no_data_screen.dart';
import 'package:efood_multivendor/view/base/web_header_skeleton.dart';
import 'package:efood_multivendor/view/screens/address/widget/address_widget.dart';
import 'package:efood_multivendor/view/screens/location/widget/permission_dialog.dart';
import 'package:efood_multivendor/view/screens/location/widget/pick_map_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class AccessLocationScreen extends StatelessWidget {
  final bool fromSignUp;
  final bool fromHome;
  final String? route;
  const AccessLocationScreen({Key? key, required this.fromSignUp, required this.fromHome, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(!fromHome && Get.find<LocationController>().getUserAddress() != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.dialog(const CustomLoader(), barrierDismissible: false);
        Get.find<LocationController>().autoNavigate(
          Get.find<LocationController>().getUserAddress()!, fromSignUp, route, route != null, ResponsiveHelper.isDesktop(Get.context),
        );
      });
    }
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(isLoggedIn) {
      Get.find<LocationController>().getAddressList();
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'set_location'.tr, isBackButtonExist: fromHome),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: Container(
        // margin: context.width > 700 ? const EdgeInsets.all(0) : const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: GetBuilder<LocationController>(builder: (locationController) {
          return isLoggedIn ? SingleChildScrollView(
            child: FooterView(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                locationController.addressList != null ? locationController.addressList!.isNotEmpty ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: locationController.addressList!.length,
                  padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall) : const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    return Center(child: SizedBox(width: 700, child: AddressWidget(
                      address: locationController.addressList![index],
                      fromAddress: false,
                      onTap: () {
                        Get.dialog(const CustomLoader(), barrierDismissible: false);
                        AddressModel address = locationController.addressList![index];
                        locationController.saveAddressAndNavigate(address, fromSignUp, route, route != null, ResponsiveHelper.isDesktop(Get.context));
                      },
                    )));
                  },
                ) : NoDataScreen(title: 'no_saved_address_found'.tr) : const Center(child: CircularProgressIndicator()),
                SizedBox(height: (locationController.addressList != null && locationController.addressList!.length < 4) ? 200 : Dimensions.paddingSizeLarge),

                ResponsiveHelper.isDesktop(context) ? BottomButton(locationController: locationController, fromSignUp: fromSignUp, route: route) : const SizedBox(),

              ]),
            ),
          ) : Center(child: SingleChildScrollView(
            child: FooterView(
              child: Center(child: Padding(
                padding: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
                child: SizedBox(width: 700, child: Column(children: [
                  Image.asset(Images.deliveryLocation, height: 220),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(
                    'find_restaurants_and_foods'.tr.toUpperCase(), textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Text(
                      'by_allowing_location_access'.tr, textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  BottomButton(locationController: locationController, fromSignUp: fromSignUp, route: route),
                ])),
              )),
            ),
          ));
        }),
      )),
      bottomNavigationBar: !ResponsiveHelper.isDesktop(context) && isLoggedIn ? GetBuilder<LocationController>(
        builder: (locationController) {
          return SizedBox(height: context.height * 0.24, child: BottomButton(locationController: locationController, fromSignUp: fromSignUp, route: route));
        }
      ) : const SizedBox(),
    );
  }
}

class BottomButton extends StatelessWidget {
  final LocationController locationController;
  final bool fromSignUp;
  final String? route;
  const BottomButton({Key? key, required this.locationController, required this.fromSignUp, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox(width: 700, child: Padding(
      padding: context.width > 700 ? const EdgeInsets.all(0) :  const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
      child: Column(children: [

        CustomButton(
          radius: Dimensions.radiusDefault,
          buttonText: 'user_current_location'.tr,
          onPressed: () async {
            _checkPermission(() async {
              Get.dialog(const CustomLoader(), barrierDismissible: false);
              AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
              ZoneResponseModel response = await locationController.getZone(address.latitude, address.longitude, false);
              if(response.isSuccess) {
                if(!Get.find<AuthController>().isGuestLoggedIn() || !Get.find<AuthController>().isLoggedIn()) {
                  Get.find<AuthController>().guestLogin().then((response) {
                    if(response.isSuccess) {
                      Get.find<UserController>().setForceFullyUserEmpty();
                      locationController.saveAddressAndNavigate(address, fromSignUp, route, route != null, ResponsiveHelper.isDesktop(Get.context));
                    }
                  });
                } else {
                  locationController.saveAddressAndNavigate(address, fromSignUp, route, route != null, ResponsiveHelper.isDesktop(Get.context));
                }
              }else {
                Get.back();
                Get.toNamed(RouteHelper.getPickMapRoute(route ?? RouteHelper.accessLocation, route != null));
                showCustomSnackBar('service_not_available_in_current_location'.tr);
              }
            });
          },
          icon: Icons.my_location,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            minimumSize: const Size(Dimensions.webMaxWidth, 50),
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            if(ResponsiveHelper.isDesktop(Get.context)) {
              showGeneralDialog(context: context, pageBuilder: (_,__,___) {
                return SizedBox(
                  height: 300, width: 300,
                  child: PickMapDialog(
                    fromSignUp: fromSignUp, canRoute: route != null, fromAddAddress: false, route: route
                      ?? (fromSignUp ? RouteHelper.signUp : RouteHelper.accessLocation),
                  ),
                );
              });
            }else {
              Get.toNamed(RouteHelper.getPickMapRoute(
                route ?? (fromSignUp ? RouteHelper.signUp : RouteHelper.accessLocation), route != null,
              ));
            }
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
              child: Icon(Icons.map, color: Theme.of(context).primaryColor),
            ),
            Text('set_from_map'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.fontSizeLarge,
            )),
          ]),
        ),

      ]),
    )));
  }

  void _checkPermission(Function onTap) async {
    await Geolocator.requestPermission();
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

