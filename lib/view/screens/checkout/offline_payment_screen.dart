import 'dart:convert';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/offline_method_model.dart';
import 'package:efood_multivendor/data/model/response/pricing_view_model.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/web_header_skeleton.dart';
import 'package:efood_multivendor/view/base/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfflinePaymentScreen extends StatefulWidget {
  final PlaceOrderBody placeOrderBody;
  final int zoneId;
  final double total;
  final double? maxCodOrderAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;
  final PricingViewModel pricingView;

  const OfflinePaymentScreen({
    Key? key, required this.placeOrderBody, required this.zoneId, required this.total, required this.maxCodOrderAmount,
    required this.fromCart, required this.isCashOnDeliveryActive, required this.pricingView}) : super(key: key);

  @override
  State<OfflinePaymentScreen> createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  //PageController pageController = PageController(viewportFraction: 0.85, initialPage: Get.find<OrderController>().selectedOfflineBankIndex);
  final TextEditingController _customerNoteController = TextEditingController();
  final FocusNode _customerNoteNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    if(Get.find<OrderController>().offlineMethodList == null){
      await Get.find<OrderController>().getOfflineMethodList();
    }
    Get.find<OrderController>().informationControllerList = [];
    Get.find<OrderController>().informationFocusList = [];
    if(Get.find<OrderController>().offlineMethodList != null && Get.find<OrderController>().offlineMethodList!.isNotEmpty) {
      for(int index=0; index<Get.find<OrderController>().offlineMethodList![Get.find<OrderController>().selectedOfflineBankIndex].methodInformations!.length; index++) {
        Get.find<OrderController>().informationControllerList.add(TextEditingController());
        Get.find<OrderController>().informationFocusList.add(FocusNode());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'offline_payment'.tr),
      body: GetBuilder<OrderController>(builder: (orderController) {
        List<MethodInformations>? methodInformation;
        List<MethodFields>? methodFields;
        if(orderController.offlineMethodList != null){
          methodInformation = orderController.offlineMethodList![orderController.selectedOfflineBankIndex].methodInformations;
          methodFields = orderController.offlineMethodList![orderController.selectedOfflineBankIndex].methodFields;
        }

        return methodFields != null ? Column(children: [
          WebScreenTitleWidget(title: 'offline_payment'.tr),

          Expanded(child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: FooterView(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: /*ResponsiveHelper.isMobile(context) ?*/ Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1)],
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          trailing: Icon(Icons.arrow_drop_down_sharp, size: 35 , color: Theme.of(context).textTheme.bodyMedium!.color),
                          title: Text('select_payment_information'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyMedium!.color)),
                          children: [
                            Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 2),
                                  ),
                                  child: Column(children: [

                                    Row(children: [

                                      Image.asset(Images.bankInfoIcon, width: 25, height: 25, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      Text('${'bank_information'.tr} (${orderController.offlineMethodList![orderController.selectedOfflineBankIndex].methodName})', style: robotoMedium),

                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),

                                    ListView.builder(
                                      itemCount: methodFields!.length,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                                          child: InfoTextRowWidget(
                                            title: methodFields![index].inputName!.toString().replaceAll('_', ' '),
                                            value: methodFields[index].inputData!,
                                          ),
                                        );
                                      },
                                    ),

                                  ]),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text(
                      '${'amount'.tr} '' ${PriceConverter.convertPrice(widget.total)}',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'payment_info'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          ),
                        ),

                        ListView.builder(
                          itemCount: orderController.informationControllerList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              child: CustomTextField(
                                titleText: methodInformation![i].customerPlaceholder!,
                                controller: orderController.informationControllerList[i],
                                focusNode: orderController.informationFocusList[i],
                                nextFocus: i != orderController.informationControllerList.length-1 ? orderController.informationFocusList[i+1] : _customerNoteNode,
                              ),
                            );
                          },
                        ),

                        CustomTextField(
                          titleText: 'note'.tr,
                          controller: _customerNoteController,
                          focusNode: _customerNoteNode,
                          inputAction: TextInputAction.done,
                          maxLines: 3,
                        ),

                      ]),
                    ),

                    ResponsiveHelper.isDesktop(context) ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                          margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                          /*decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10)],
                            ),*/
                          child: CustomButton(
                            width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                            buttonText: 'complete'.tr,
                            isLoading: orderController.isLoading,
                            onPressed: () async {
                              bool complete = false;
                              String text = '';
                              for(int i = 0; i<methodInformation!.length; i++){
                                if(methodInformation[i].isRequired!) {
                                  if(orderController.informationControllerList[i].text.isEmpty){
                                    complete = false;
                                    text = methodInformation[i].customerPlaceholder!;
                                    break;
                                  } else {
                                    complete = true;
                                  }
                                } else {
                                  complete = true;
                                }
                              }

                              if(complete) {
                                String methodId = orderController.offlineMethodList![orderController.selectedOfflineBankIndex].id.toString();

                                String? orderId = await orderController.placeOrder(widget.placeOrderBody, widget.zoneId, widget.total, widget.maxCodOrderAmount, widget.fromCart, widget.isCashOnDeliveryActive, isOfflinePay: true);

                                print('-------order id---------- $orderId');
                                print('-------method id---------- $methodId');

                                if(orderId.isNotEmpty) {
                                  Map<String, String> data = {
                                    "_method": "put",
                                    "order_id": orderId,
                                    "method_id": methodId,
                                    "customer_note": _customerNoteController.text,
                                  };

                                  for(int i = 0; i<methodInformation.length; i++){
                                    data.addAll({
                                      methodInformation[i].customerInput! : orderController.informationControllerList[i].text,
                                    });
                                  }

                                  orderController.saveOfflineInfo(jsonEncode(data)).then((success) {
                                    if(success){
                                      Get.offAllNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderId), fromOffline: true, contactNumber: widget.placeOrderBody.contactPersonNumber));
                                    }
                                  });
                                }
                              } else {
                                showCustomSnackBar(text);
                              }
                            },
                          ),
                        ),
                      ],
                    ) : const SizedBox(),

                  ]),
                  // : Row(
                  //         crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Expanded(
                  //             flex: 6,
                  //             child: Column(mainAxisSize: MainAxisSize.min, children: [
                  //               const SizedBox(height: Dimensions.paddingSizeLarge),
                  //
                  //               Theme(
                  //                 data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  //                 child: Container(
                  //                   margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                  //                   decoration: BoxDecoration(
                  //                     color: Theme.of(context).cardColor,
                  //                     borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  //                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1)],
                  //                   ),
                  //                   child: ExpansionTile(
                  //                     initiallyExpanded: true,
                  //                     trailing: Icon(Icons.arrow_drop_down_sharp, size: 35 , color: Theme.of(context).textTheme.bodyMedium!.color),
                  //                     title: Text('select_payment_information'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyMedium!.color)),
                  //                     children: [
                  //                       Builder(
                  //                         builder: (BuildContext context) {
                  //                           return Container(
                  //                             width: double.infinity,
                  //                             padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  //                             margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                  //                             decoration: BoxDecoration(
                  //                               color: Theme.of(context).primaryColor.withOpacity(0.05),
                  //                               borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  //                               border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 2),
                  //                             ),
                  //                             child: Column(children: [
                  //
                  //                               Row(children: [
                  //
                  //                                 Image.asset(Images.bankInfoIcon, width: 25, height: 25, color: Theme.of(context).primaryColor),
                  //                                 const SizedBox(width: Dimensions.paddingSizeSmall),
                  //
                  //                                 Text('bank_information'.tr, style: robotoMedium),
                  //
                  //                               ]),
                  //                               const SizedBox(height: Dimensions.paddingSizeDefault),
                  //
                  //                               ListView.builder(
                  //                                 itemCount: methodFields!.length,
                  //                                 shrinkWrap: true,
                  //                                 physics: const NeverScrollableScrollPhysics(),
                  //                                 itemBuilder: (context, index) {
                  //                                   return Padding(
                  //                                     padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  //                                     child: InfoTextRowWidget(
                  //                                       title: methodFields[index].inputName!.toString().replaceAll('_', ' '),
                  //                                       value: methodFields[index].inputData!,
                  //                                     ),
                  //                                   );
                  //                                 },
                  //                               ),
                  //
                  //                             ]),
                  //                           );
                  //                         },
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ),
                  //               const SizedBox(height: Dimensions.paddingSizeLarge),
                  //
                  //               Text(
                  //                 '${'amount'.tr} '' ${PriceConverter.convertPrice(widget.total)}',
                  //                 style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  //               ),
                  //               const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  //
                  //               Padding(
                  //                 padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                  //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //                   Align(
                  //                     alignment: Alignment.centerLeft,
                  //                     child: Text(
                  //                       'payment_info'.tr,
                  //                       style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  //                     ),
                  //                   ),
                  //
                  //                   ListView.builder(
                  //                     itemCount: orderController.informationControllerList.length,
                  //                     shrinkWrap: true,
                  //                     physics: const NeverScrollableScrollPhysics(),
                  //                     padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  //                     itemBuilder: (context, i) {
                  //                       return Padding(
                  //                         padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  //                         child: CustomTextField(
                  //                           titleText: methodInformation![i].customerPlaceholder!,
                  //                           controller: orderController.informationControllerList[i],
                  //                           focusNode: orderController.informationFocusList[i],
                  //                           nextFocus: i != orderController.informationControllerList.length-1 ? orderController.informationFocusList[i+1] : _customerNoteNode,
                  //                         ),
                  //                       );
                  //                     },
                  //                   ),
                  //
                  //                   CustomTextField(
                  //                     titleText: 'note'.tr,
                  //                     controller: _customerNoteController,
                  //                     focusNode: _customerNoteNode,
                  //                     inputAction: TextInputAction.done,
                  //                     maxLines: 3,
                  //                   ),
                  //
                  //                 ]),
                  //               ),
                  //
                  //             ]),
                  //           ),
                  //
                  //           Expanded(
                  //             flex: 4,
                  //             child: Column(mainAxisSize: MainAxisSize.min, children: [
                  //               const SizedBox(height: Dimensions.paddingSizeLarge),
                  //
                  //               GetBuilder<OrderController>(builder: (orderController) {
                  //                 return GetBuilder<CouponController>(builder: (couponController) {
                  //                   return Container(
                  //                     decoration: BoxDecoration(
                  //                       color: Theme.of(context).cardColor,
                  //                       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  //                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1, offset: const Offset(1, 2))],
                  //                     ),
                  //                     padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  //                     margin: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                  //                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //
                  //                       Text('order_summary'.tr, style: robotoMedium),
                  //                       const SizedBox(height:Dimensions.paddingSizeOverLarge),
                  //
                  //                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                         Text(!orderController.subscriptionOrder ? 'subtotal'.tr : 'item_price'.tr, style: robotoRegular),
                  //                         Text(PriceConverter.convertPrice(widget.pricingView.subTotal), style: robotoRegular, textDirection: TextDirection.ltr),
                  //                       ]),
                  //                       const SizedBox(height: Dimensions.paddingSizeSmall),
                  //
                  //                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                         Text('discount'.tr, style: robotoRegular),
                  //                         Row(children: [
                  //                           Text('(-) ', style: robotoRegular),
                  //                           PriceConverter.convertAnimationPrice(widget.pricingView.discount, textStyle: robotoRegular)
                  //                         ]),
                  //                         // Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  //                       ]),
                  //                       const SizedBox(height: Dimensions.paddingSizeSmall),
                  //
                  //                       (couponController.discount! > 0 || couponController.freeDelivery) ? Column(children: [
                  //                         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                           Text('coupon_discount'.tr, style: robotoRegular),
                  //                           (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? Text(
                  //                             'free_delivery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                  //                           ) : Row(children: [
                  //                             Text('(-) ', style: robotoRegular),
                  //                             Text(
                  //                               PriceConverter.convertPrice(couponController.discount),
                  //                               style: robotoRegular, textDirection: TextDirection.ltr,
                  //                             )
                  //                           ]),
                  //                         ]),
                  //                         const SizedBox(height: Dimensions.paddingSizeSmall),
                  //                       ]) : const SizedBox(),
                  //                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                         Row(children: [
                  //                           Text('${'vat_tax'.tr} ${widget.pricingView.taxIncluded! ? 'tax_included'.tr : ''}', style: robotoRegular),
                  //                           Text('(${widget.pricingView.taxPercent}%)', style: robotoRegular, textDirection: TextDirection.ltr),
                  //                         ]),
                  //                         Row(children: [
                  //                           Text('(+) ', style: robotoRegular),
                  //                           Text(PriceConverter.convertPrice(widget.pricingView.tax), style: robotoRegular, textDirection: TextDirection.ltr),
                  //                         ]),
                  //                       ]),
                  //                       const SizedBox(height: Dimensions.paddingSizeSmall),
                  //
                  //                       (orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !orderController.subscriptionOrder) ? Row(
                  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           Text('delivery_man_tips'.tr, style: robotoRegular),
                  //                           Row(children: [
                  //                             Text('(+) ', style: robotoRegular),
                  //                             PriceConverter.convertAnimationPrice(orderController.tips, textStyle: robotoRegular)
                  //                           ]),
                  //                           // Text('(+) ${PriceConverter.convertPrice(orderController.tips)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  //                         ],
                  //                       ) : const SizedBox.shrink(),
                  //                       SizedBox(height: orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !orderController.subscriptionOrder ? Dimensions.paddingSizeSmall : 0.0),
                  //
                  //                       orderController.orderType != 'take_away' ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                         Text('delivery_fee'.tr, style: robotoRegular),
                  //                         orderController.distance == -1 ? Text(
                  //                           'calculating'.tr, style: robotoRegular.copyWith(color: Colors.red),
                  //                         ) : (widget.pricingView.deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery')) ? Text(
                  //                           'free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                  //                         ) : Row(children: [
                  //                           Text('(+) ', style: robotoRegular),
                  //                           Text(
                  //                             PriceConverter.convertPrice(widget.pricingView.deliveryCharge), style: robotoRegular, textDirection: TextDirection.ltr,
                  //                           )
                  //                         ]),
                  //                       ]) : const SizedBox(),
                  //                       SizedBox(height: Get.find<SplashController>().configModel!.additionalChargeStatus! ? Dimensions.paddingSizeSmall : 0),
                  //
                  //                       Get.find<SplashController>().configModel!.additionalChargeStatus! ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                         Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: robotoRegular),
                  //                         Text(
                  //                           '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
                  //                           style: robotoRegular, textDirection: TextDirection.ltr,
                  //                         ),
                  //                       ]) : const SizedBox(),
                  //
                  //                       (ResponsiveHelper.isDesktop(context) || orderController.isPartialPay) ? Column(
                  //                         children: [
                  //                           Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                  //
                  //                           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                             Text(
                  //                               orderController.subscriptionOrder ? 'subtotal'.tr : 'total_amount'.tr,
                  //                               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: orderController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
                  //                             ),
                  //                             PriceConverter.convertAnimationPrice(
                  //                               widget.pricingView.total,
                  //                               textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: orderController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
                  //                             ),
                  //                           ]),
                  //                         ],
                  //                       ) : const SizedBox(),
                  //
                  //                       orderController.subscriptionOrder ? Column(children: [
                  //                         const SizedBox(height: Dimensions.paddingSizeSmall),
                  //                         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                           Text('subscription_order_count'.tr, style: robotoMedium),
                  //                           Text(/*subscriptionQty > 0 ? */widget.pricingView.subscriptionQty.toString()/* : 'calculating'.tr*/, style: robotoMedium),
                  //                         ]),
                  //                         Padding(
                  //                           padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  //                           child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                  //                         ),
                  //                         // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                         //   Text(
                  //                         //     'total_amount'.tr,
                  //                         //     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  //                         //   ),
                  //                         //   Text(
                  //                         //     /*subscriptionQty > 0 ?*/ PriceConverter.convertPrice(total * (subscriptionQty == 0 ? 1 : subscriptionQty))/* : 'calculating'.tr*/,
                  //                         //     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  //                         //   ),
                  //                         // ]),
                  //
                  //
                  //                       ]) : const SizedBox(),
                  //                       SizedBox(height: orderController.isPartialPay ? Dimensions.paddingSizeSmall : 0),
                  //
                  //                       orderController.isPartialPay && !orderController.subscriptionOrder ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                         Text('paid_by_wallet'.tr, style: robotoRegular),
                  //                         Text('(-) ${PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance!)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  //                       ]) : const SizedBox(),
                  //                       SizedBox(height: orderController.isPartialPay ? Dimensions.paddingSizeSmall : 0),
                  //
                  //                       orderController.isPartialPay && !orderController.subscriptionOrder ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  //                         Text(
                  //                           'due_payment'.tr,
                  //                           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
                  //                         ),
                  //                         PriceConverter.convertAnimationPrice(
                  //                           orderController.viewTotalPrice,
                  //                           textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
                  //                         )
                  //                       ]) : const SizedBox(),
                  //
                  //                       /*ResponsiveHelper.isDesktop(context) ? Padding(
                  //                         padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  //                         child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                  //                       ) : const SizedBox(),*/
                  //
                  //                       Padding(
                  //                         padding: const EdgeInsets.only(top: Dimensions.paddingSizeOverLarge),
                  //                         child: CustomButton(
                  //                           buttonText: 'complete'.tr,
                  //                           isLoading: orderController.isLoading,
                  //                           onPressed: () async {
                  //                             bool complete = false;
                  //                             String text = '';
                  //                             for(int i = 0; i<methodInformation!.length; i++){
                  //                               if(methodInformation[i].isRequired!) {
                  //                                 if(orderController.informationControllerList[i].text.isEmpty){
                  //                                   complete = false;
                  //                                   text = methodInformation[i].customerPlaceholder!;
                  //                                   break;
                  //                                 } else {
                  //                                   complete = true;
                  //                                 }
                  //                               } else {
                  //                                 complete = true;
                  //                               }
                  //                             }
                  //
                  //                             if(complete) {
                  //                               String methodId = orderController.offlineMethodList![orderController.selectedOfflineBankIndex].id.toString();
                  //
                  //                               String? orderId = await orderController.placeOrder(widget.placeOrderBody, widget.zoneId, widget.total, widget.maxCodOrderAmount, widget.fromCart, widget.isCashOnDeliveryActive, isOfflinePay: true);
                  //
                  //                               print('-------order id---------- $orderId');
                  //                               print('-------method id---------- $methodId');
                  //
                  //                               if(orderId.isNotEmpty) {
                  //                                 Map<String, String> data = {
                  //                                   "_method": "put",
                  //                                   "order_id": orderId,
                  //                                   "method_id": methodId,
                  //                                   "customer_note": _customerNoteController.text,
                  //                                 };
                  //
                  //                                 for(int i = 0; i<methodInformation.length; i++){
                  //                                   data.addAll({
                  //                                     methodInformation[i].customerInput! : orderController.informationControllerList[i].text,
                  //                                   });
                  //                                 }
                  //
                  //                                 orderController.saveOfflineInfo(jsonEncode(data)).then((success) {
                  //                                   print('Route order detail page $success');
                  //                                   if(success){
                  //                                     Get.offAllNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderId), fromOffline: true,));
                  //                                   }
                  //                                 });
                  //                               }
                  //                             } else {
                  //                               showCustomSnackBar(text);
                  //                             }
                  //                           },
                  //                         ),
                  //                       ),
                  //                     ]),
                  //                   );
                  //                 });
                  //               }),
                  //
                  //             ]),
                  //           ),
                  //         ],
                  //       ),
                ),
              ),
            ),
          )),

          ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10)],
            ),
            child: CustomButton(
              buttonText: 'complete'.tr,
              isLoading: orderController.isLoading,
              onPressed: () async {
                bool complete = false;
                String text = '';
                for(int i = 0; i<methodInformation!.length; i++){
                  if(methodInformation[i].isRequired!) {
                    if(orderController.informationControllerList[i].text.isEmpty){
                      complete = false;
                      text = methodInformation[i].customerPlaceholder!;
                      break;
                    } else {
                      complete = true;
                    }
                  } else {
                    complete = true;
                  }
                }

                if(complete) {
                  String methodId = orderController.offlineMethodList![orderController.selectedOfflineBankIndex].id.toString();

                  String? orderId = await orderController.placeOrder(widget.placeOrderBody, widget.zoneId, widget.total, widget.maxCodOrderAmount, widget.fromCart, widget.isCashOnDeliveryActive, isOfflinePay: true);

                  print('-------order id---------- $orderId');
                  print('-------method id---------- $methodId');

                  if(orderId.isNotEmpty) {
                    Map<String, String> data = {
                      "_method": "put",
                      "order_id": orderId,
                      "method_id": methodId,
                      "customer_note": _customerNoteController.text,
                    };

                    for(int i = 0; i<methodInformation.length; i++){
                      data.addAll({
                        methodInformation[i].customerInput! : orderController.informationControllerList[i].text,
                      });
                    }

                    orderController.saveOfflineInfo(jsonEncode(data)).then((success) {
                      print('Route order detail page $success');
                      if(success){
                        Get.offAllNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderId), fromOffline: true, contactNumber: widget.placeOrderBody.contactPersonNumber));
                      }
                    });
                  }
                } else {
                  showCustomSnackBar(text);
                }
              },
            ),
          ),

        ]) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}

class InfoTextRowWidget extends StatelessWidget {
  final String title;
  final String value;
  const InfoTextRowWidget({Key? key, required this.title, required this.value,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      
      Expanded(
        flex: ResponsiveHelper.isDesktop(context) ? 1 : 1,
        child: Text(title, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
      ),

      Text(':', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      
      Expanded(
        flex: ResponsiveHelper.isDesktop(context) ? 4 : 1,
        child: Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
      ),
      
    ]);
  }
}
