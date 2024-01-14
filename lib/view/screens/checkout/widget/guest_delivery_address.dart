
import 'package:country_code_picker/country_code_picker.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/data/model/response/address_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GuestDeliveryAddress extends StatelessWidget {
  final OrderController orderController;
  final RestaurantController restController;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;

  const GuestDeliveryAddress({Key? key,
    required this.orderController, required this.restController,
    required this.guestNameTextEditingController, required this.guestNumberTextEditingController,
    required this.guestNumberNode, required this.guestEmailController, required this.guestEmailNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool takeAway = (orderController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    AddressModel address = Get.find<LocationController>().getUserAddress()!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1, offset: const Offset(1, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(takeAway ? 'contact_information'.tr : 'deliver_to'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          child: takeAway ? Column(children: [

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(children: [
                CustomTextField(
                  showTitle: true,
                  titleText: 'contact_person_name'.tr,
                  hintText: ' ',
                  inputType: TextInputType.name,
                  controller: guestNameTextEditingController,
                  nextFocus: guestNumberNode,
                  capitalization: TextCapitalization.words,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  showTitle: true,
                  titleText: 'contact_person_number'.tr,
                  hintText: ' ',
                  controller: guestNumberTextEditingController,
                  focusNode: guestNumberNode,
                  nextFocus: guestEmailNode,
                  inputType: TextInputType.phone,
                  isPhone: true,
                  onCountryChanged: (CountryCode countryCode) {
                    orderController.countryDialCode = countryCode.dialCode;
                  },
                  countryDialCode: orderController.countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  showTitle: true,
                  titleText: 'email'.tr,
                  hintText: ' ',
                  controller: guestEmailController,
                  focusNode: guestEmailNode,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.emailAddress,
                ),

              ]),
            ),
          ]) : Column(crossAxisAlignment: CrossAxisAlignment.start,  children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(children: [
                orderController.guestAddress == null ? Flexible(
                  child: Row(
                    children: [
                      Text(
                        "no_contact_information_added".tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error)
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      InkWell(
                        onTap: () async {},
                        child: Icon(Icons.info_outlined, color: Theme.of(context).colorScheme.error, size: 15),
                      ),

                      const Spacer(),
                    ],
                  ),
                ) : Flexible(
                  child: Row(children: [

                    Flexible(
                      flex: 4,
                      child: Row(children: [
                        Icon(Icons.person, color: Theme.of(context).disabledColor, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Flexible(
                          child: Text(
                            orderController.guestAddress!.contactPersonName!,
                            style: robotoBold,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Flexible(
                      flex: 6,
                      child: Row(children: [
                        Icon(Icons.phone, color: Theme.of(context).disabledColor, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Flexible(
                          child: Text(
                            orderController.guestAddress!.contactPersonNumber!,
                            style: robotoBold,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                  ]),
                ),

                takeAway ? const SizedBox() : InkWell(
                  onTap: () async {
                    var address = await Get.toNamed(RouteHelper.getEditAddressRoute(orderController.guestAddress, fromGuest: true));
                    if(address != null) {
                      orderController.setGuestAddress(address);
                      orderController.getDistanceInKM(
                        LatLng(double.parse(address.latitude), double.parse(address.longitude)),
                        LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                      );
                    }
                  },
                  child: Image.asset(Images.editDelivery, height: 20, width: 20, color: Theme.of(context).primaryColor),
                ),
              ]),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  orderController.guestAddress == null ? address.address! : orderController.guestAddress!.address!,
                  style: robotoRegular,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                orderController.guestAddress == null ? const SizedBox() : const SizedBox(height: Dimensions.paddingSizeSmall),

                (orderController.guestAddress != null && orderController.guestAddress!.email != null) ? Row(children: [
                  Text('${'email'.tr} - ', style: robotoRegular.copyWith(color: Theme.of(Get.context!).disabledColor)),
                  Flexible(child: Text(orderController.guestAddress!.email ?? '', style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                
                orderController.guestAddress == null ? const SizedBox() : Row(children: [
                  orderController.guestAddress!.house != null ? Flexible(
                    child: Row(children: [
                      Text('${'house'.tr} - ', style: robotoRegular.copyWith(color: Theme.of(Get.context!).disabledColor)),
                      Flexible(child: Text(orderController.guestAddress!.house ?? '', style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ) : const SizedBox(),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  orderController.guestAddress!.floor != null ? Flexible(
                    child: Row(children: [
                      Text('${'floor'.tr} - ', style: robotoRegular.copyWith(color: Theme.of(Get.context!).disabledColor)),
                      Flexible(child: Text(orderController.guestAddress!.floor ?? '', style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ) : const SizedBox(),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                ]),
              ]),
            ),
          ]),
        ),

      ]),
    );
  }
}
