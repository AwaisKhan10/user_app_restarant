import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/review_body.dart';
import 'package:efood_multivendor/data/model/response/order_details_model.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductReviewWidget extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  const ProductReviewWidget({Key? key, required this.orderDetailsList}) : super(key: key);

  @override
  State<ProductReviewWidget> createState() => _ProductReviewWidgetState();
}

class _ProductReviewWidgetState extends State<ProductReviewWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (productController) {
      return Scrollbar(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: ListView.builder(
          itemCount: widget.orderDetailsList.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))],
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              ),
              child: Column(children: [

                // Product details
                Row(
                  children: [
                    (widget.orderDetailsList[index].foodDetails!.image != null && widget.orderDetailsList[index].foodDetails!.image!.isNotEmpty) ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(
                        height: 70, width: 85, fit: BoxFit.cover,
                        image: '${Get.find<SplashController>().configModel!.baseUrls!.productImageUrl}'
                            '/${widget.orderDetailsList[index].foodDetails!.image}',
                      ),
                    ) : const SizedBox(),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.orderDetailsList[index].foodDetails!.name!, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 10),

                        Text(PriceConverter.convertPrice(widget.orderDetailsList[index].foodDetails!.price), style: robotoBold),
                      ],
                    )),
                    Row(children: [
                      Text(
                        '${'quantity'.tr}: ',
                        style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.orderDetailsList[index].quantity.toString(),
                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ],
                ),
                const Divider(height: 20),

                // Rate
                Text(
                  'rate_the_food'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      return InkWell(
                        child: Icon(
                          productController.ratingList[index] < (i + 1) ? Icons.star_border : Icons.star,
                          size: 25,
                          color: productController.ratingList[index] < (i + 1) ? Theme.of(context).disabledColor
                              : Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          if(!productController.submitList[index]) {
                            productController.setRating(index, i + 1);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Text(
                  'share_your_opinion'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                MyTextField(
                  maxLines: 3,
                  capitalization: TextCapitalization.sentences,
                  isEnabled: !productController.submitList[index],
                  hintText: 'write_your_review_here'.tr,
                  fillColor: Theme.of(context).disabledColor.withOpacity(0.05),
                  onChanged: (text) => productController.setReview(index, text),
                ),
                const SizedBox(height: 20),

                // Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: !productController.loadingList[index] ? CustomButton(
                    buttonText: productController.submitList[index] ? 'submitted'.tr : 'submit'.tr,
                    onPressed: productController.submitList[index] ? null : () {
                      if(!productController.submitList[index]) {
                        if (productController.ratingList[index] == 0) {
                          showCustomSnackBar('give_a_rating'.tr);
                        } else if (productController.reviewList[index].isEmpty) {
                          showCustomSnackBar('write_a_review'.tr);
                        } else {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          ReviewBody reviewBody = ReviewBody(
                            productId: widget.orderDetailsList[index].foodDetails!.id.toString(),
                            rating: productController.ratingList[index].toString(),
                            comment: productController.reviewList[index],
                            orderId: widget.orderDetailsList[index].orderId.toString(),
                          );
                          productController.submitReview(index, reviewBody).then((value) {
                            if (value.isSuccess) {
                              showCustomSnackBar(value.message, isError: false);
                              productController.setReview(index, '');
                            } else {
                              showCustomSnackBar(value.message);
                            }
                          });
                        }
                      }
                    },
                  ) : const Center(child: CircularProgressIndicator()),
                ),

              ]),
            );
          },
        ))),
      ));
    });
  }
}
