import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/tips_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final OrderController orderController;
  final double totalPrice;
  final Function(double x) onTotalChange;
  const DeliveryManTipsSection({Key? key, required this.takeAway, required this.tooltipController3, required this.orderController, required this.totalPrice, required this.onTotalChange}) : super(key: key);

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  bool canCheckSmall = false;

  @override
  Widget build(BuildContext context) {
    double total = widget.totalPrice;
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(
      children: [
        (!widget.orderController.subscriptionOrder && !widget.takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 1, offset: const Offset(1, 2))],
          ),
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
          padding: EdgeInsets.all(isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Text('delivery_man_tips'.tr, style: robotoMedium),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: widget.tooltipController3,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'.tr,style: robotoRegular.copyWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => widget.tooltipController3.showTooltip(),
                  child: const Icon(Icons.info_outline),
                ),
              ),

              const Expanded(child: SizedBox()),

              (widget.orderController.selectedTips == AppConstants.tips.length-1) ? const SizedBox() : SizedBox(
                width: ResponsiveHelper.isDesktop(context) ? 150 : 120,
                child: ListTile(
                  onTap: () => widget.orderController.toggleDmTipSave(),
                  trailing: Checkbox(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    activeColor: Theme.of(context).primaryColor,
                    value: widget.orderController.isDmTipSave,
                    onChanged: (bool? isChecked) => widget.orderController.toggleDmTipSave(),
                  ),
                  title: Text('save_for_later'.tr, style: robotoMedium.copyWith(color: isDesktop ? Theme.of(context).textTheme.bodyMedium!.color! : Theme.of(context).primaryColor)),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  dense: true,
                  horizontalTitleGap: 0,
                ),
              ),

            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SizedBox(
              height: (widget.orderController.selectedTips == AppConstants.tips.length-1) && widget.orderController.canShowTipsField
                  ? 0 : 60,
              child: (widget.orderController.selectedTips == AppConstants.tips.length-1) && widget.orderController.canShowTipsField
              ? const SizedBox() : ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: AppConstants.tips.length,
                itemBuilder: (context, index) {
                  return TipsWidget(
                    index: index,
                    title: AppConstants.tips[index] == '0' ? 'not_now'.tr : (index != AppConstants.tips.length -1) ? PriceConverter.convertPrice(double.parse(AppConstants.tips[index].toString()), forDM: true) : AppConstants.tips[index].tr,
                    isSelected: widget.orderController.selectedTips == index,
                    isSuggested: index != 0 && AppConstants.tips[index] == widget.orderController.mostDmTipAmount.toString(),
                    onTap: () {
                      total = total - widget.orderController.tips;
                      widget.orderController.updateTips(index);
                      if(widget.orderController.selectedTips != AppConstants.tips.length-1) {
                        widget.orderController.addTips(double.parse(AppConstants.tips[index]));
                      }
                      if(widget.orderController.selectedTips == AppConstants.tips.length-1) {
                        widget.orderController.showTipsField();
                      }
                      widget.orderController.tipController.text = widget.orderController.tips.toString();
                      if(widget.orderController.isPartialPay || widget.orderController.paymentMethodIndex == 1) {
                        widget.orderController.checkBalanceStatus(total, extraCharge: widget.orderController.tips);
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(height: (widget.orderController.selectedTips == AppConstants.tips.length-1) && widget.orderController.canShowTipsField ? Dimensions.paddingSizeExtraSmall : 0),

            widget.orderController.selectedTips == AppConstants.tips.length-1 ? Row(children: [
              Expanded(
                child: CustomTextField(
                  titleText: 'enter_amount'.tr,
                  controller: widget.orderController.tipController,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.number,
                  onSubmit: (value) async {
                    if(value.isNotEmpty){
                      try{
                        if(double.parse(value) >= 0){
                          if(Get.find<AuthController>().isLoggedIn()) {
                            total = total - widget.orderController.tips;
                            await widget.orderController.addTips(double.parse(value));
                            total = total + widget.orderController.tips;
                            widget.onTotalChange(total);
                            if(Get.find<UserController>().userInfoModel!.walletBalance! < total && widget.orderController.paymentMethodIndex == 1){
                              widget.orderController.checkBalanceStatus(total);
                              canCheckSmall = true;
                            } else if(Get.find<UserController>().userInfoModel!.walletBalance! > total && canCheckSmall && widget.orderController.isPartialPay){
                              widget.orderController.checkBalanceStatus(total);
                            }
                          } else {
                            widget.orderController.addTips(double.parse(value));
                          }

                        }else{
                          showCustomSnackBar('tips_can_not_be_negative'.tr);
                        }
                      } catch(e) {
                        showCustomSnackBar('invalid_input'.tr);
                        widget.orderController.addTips(0.0);
                        widget.orderController.tipController.text = widget.orderController.tipController.text.substring(0, widget.orderController.tipController.text.length-1);
                        widget.orderController.tipController.selection = TextSelection.collapsed(offset: widget.orderController.tipController.text.length);
                      }
                    }else{
                      widget.orderController.addTips(0.0);
                    }
                  },

                  onChanged: (String value) async {
                    if(value.isNotEmpty){
                      try{
                        if(double.parse(value) >= 0){
                          if(Get.find<AuthController>().isLoggedIn()) {
                            total = total - widget.orderController.tips;
                            await widget.orderController.addTips(double.parse(value));
                            total = total + widget.orderController.tips;
                            widget.onTotalChange(total);
                            if(Get.find<UserController>().userInfoModel!.walletBalance! < total && widget.orderController.paymentMethodIndex == 1){
                              widget.orderController.checkBalanceStatus(total);
                              canCheckSmall = true;
                            } else if(Get.find<UserController>().userInfoModel!.walletBalance! > total && canCheckSmall && widget.orderController.isPartialPay){
                              widget.orderController.checkBalanceStatus(total);
                            }
                          } else {
                            widget.orderController.addTips(double.parse(value));
                          }

                        }else{
                          showCustomSnackBar('tips_can_not_be_negative'.tr);
                        }
                      } catch(e){
                        showCustomSnackBar('invalid_input'.tr);
                        widget.orderController.addTips(0.0);
                        widget.orderController.tipController.text = widget.orderController.tipController.text.substring(0, widget.orderController.tipController.text.length-1);
                        widget.orderController.tipController.selection = TextSelection.collapsed(offset: widget.orderController.tipController.text.length);
                      }
                    }else{
                      widget.orderController.addTips(0.0);
                    }
                  },
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              InkWell(
                onTap: () {
                  widget.orderController.updateTips(0);
                  widget.orderController.showTipsField();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: const Icon(Icons.clear),
                ),
              ),

            ]) : const SizedBox(),

          ]),
        ) : const SizedBox.shrink(),

        SizedBox(height: (!widget.takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1)
            ? Dimensions.paddingSizeSmall : 0),
      ],
    );
  }
}
