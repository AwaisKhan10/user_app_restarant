import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DeliveryOptionButton extends StatelessWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final double total;
  const DeliveryOptionButton({Key? key, required this.value, required this.title, required this.charge, required this.isFree, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        bool select = orderController.orderType == value;
        return InkWell(
          onTap: () {
            orderController.setOrderType(value);
            orderController.setInstruction(-1);

            if(orderController.orderType == 'take_away') {
              orderController.addTips(0);
              if(orderController.isPartialPay || Get.find<OrderController>().paymentMethodIndex == 1) {
                double tips = 0;
                try{
                  tips = double.parse(orderController.tipController.text);
                } catch(_) {}
                orderController.checkBalanceStatus(total, discount: charge! + tips);
              }
            }else{
              orderController.updateTips(
                Get.find<AuthController>().getDmTipIndex().isNotEmpty ? int.parse(Get.find<AuthController>().getDmTipIndex()) : 0, notify: false,
              );

              if(orderController.isPartialPay){
                orderController.changePartialPayment();
              } else {
                orderController.setPaymentMethod(-1);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: select ? Theme.of(context).cardColor : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
            child: Row(
              children: [
                Radio(
                  value: value,
                  groupValue: orderController.orderType,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (String? value) {
                    orderController.setOrderType(value!);
                  },
                  activeColor: Theme.of(context).primaryColor,
                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(title, style: robotoMedium.copyWith(color: select ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color)),
                const SizedBox(width: 5),

                // Text(
                //   '(${(value == 'take_away' || isFree!) ? 'free'.tr : charge != -1 ? PriceConverter.convertPrice(charge) : 'calculating'.tr})',
                //   style: robotoMedium,
                // ),

              ],
            ),
          ),
        );
      },
    );
  }
}





















// class DeliveryOptionButton extends StatelessWidget {
//   final String value;
//   final String title;
//   final String image;
//   final double charge;
//   final bool? isFree;
//   final int index;
//   const DeliveryOptionButton({Key? key, required this.value, required this.title, required this.charge, required this.isFree, required this.image, required this.index}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<OrderController>(builder: (orderController) {
//       bool select = orderController.deliverySelectIndex == index;
//         return InkWell(
//           onTap: () {
//             orderController.setOrderType(value);
//             orderController.selectDelivery(index);
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
//             decoration: BoxDecoration(
//               color: select ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor,
//               borderRadius: BorderRadius.circular(Dimensions.radiusLarge)
//             ),
//             child: Row(
//               children: [
//                 // Radio(
//                 //   value: value,
//                 //   groupValue: orderController.orderType,
//                 //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 //   onChanged: (String value) => orderController.setOrderType(value),
//                 //   activeColor: Theme.of(context).primaryColor,
//                 // ),
//                 SizedBox(height: 16, width: 16, child: Image.asset(image, color: select ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)),
//                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                 Text(title, style: robotoRegular.copyWith(color: select ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)),
//                 const SizedBox(width: 5),
//
//                 // Text(
//                 //   '(${(value == 'take_away' || isFree) ? 'free'.tr : charge != -1 ? PriceConverter.convertPrice(charge) : 'calculating'.tr})',
//                 //   style: robotoMedium,
//                 // ),
//
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
