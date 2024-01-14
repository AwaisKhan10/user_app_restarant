import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class BadWeatherWidget extends StatefulWidget {
  const BadWeatherWidget({Key? key}) : super(key: key);

  @override
  State<BadWeatherWidget> createState() => _BadWeatherWidgetState();
}

class _BadWeatherWidgetState extends State<BadWeatherWidget> {
  bool _showAlert = true;
  String? _message;
  @override
  void initState() {
    super.initState();

    ZoneData? zoneData;
    for (var data in Get.find<LocationController>().getUserAddress()!.zoneData!) {
      if(data.id == Get.find<LocationController>().getUserAddress()!.zoneId){
        if(data.increasedDeliveryFeeStatus == 1 && data.increaseDeliveryFeeMessage != null){
          zoneData = data;
        }
      }
    }

    if(zoneData != null){
      _showAlert = zoneData.increasedDeliveryFeeStatus == 1;
      _message = zoneData.increaseDeliveryFeeMessage;
    }else{
      _showAlert = false;
    }

  }

  @override
  Widget build(BuildContext context) {

    return _showAlert && _message != null && _message!.isNotEmpty ? Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).primaryColor.withOpacity(0.7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          Image.asset(Images.weather, height: 50, width: 50),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Text(
              _message!,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white),
          )),
        ],
      ),
    ) : const SizedBox();
  }
}
