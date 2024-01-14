import 'dart:io';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/extensions.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdditionalDataSection extends StatelessWidget {
  final AuthController authController;
  final ScrollController scrollController;
  const AdditionalDataSection({Key? key, required this.authController, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: authController.dataList!.length,
      itemBuilder: (context, index) {
        bool showTextField = authController.dataList![index].fieldType == 'text' || authController.dataList![index].fieldType == 'number' || authController.dataList![index].fieldType == 'email' || authController.dataList![index].fieldType == 'phone';
        bool showDate = authController.dataList![index].fieldType == 'date';
        bool showCheckBox = authController.dataList![index].fieldType == 'check_box';
        bool showFile = authController.dataList![index].fieldType == 'file';
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
          child: showTextField ? CustomTextField(
            hintText: authController.dataList![index].placeholderData ?? '',
            controller: authController.additionalList![index],
            inputType: authController.dataList![index].fieldType == 'number' ? TextInputType.number
                : authController.dataList![index].fieldType == 'phone' ? TextInputType.phone
                : authController.dataList![index].fieldType == 'email' ? TextInputType.emailAddress
                : TextInputType.text,
            isRequired: authController.dataList![index].isRequired == 1,
            capitalization: TextCapitalization.words,
          ) : showDate ? Container(
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.3)
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(children: [
              Expanded(child: Text(
                authController.additionalList![index] ?? 'not_set_yet'.tr,
                style: robotoMedium,
              )),

              IconButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateConverter.dateTimeForCoupon(pickedDate);
                    authController.setAdditionalDate(index, formattedDate);
                  }
                },
                icon: const Icon(Icons.date_range_sharp),
              )
            ]),
          ) : showCheckBox ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              authController.dataList![index].inputData?.replaceAll('_', ' ').toTitleCase() ?? '',
              style: robotoMedium,
            ),
            ListView.builder(
              itemCount: authController.dataList![index].checkData!.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, i) {
                return Row(children: [
                  Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: authController.additionalList![index][i] == authController.dataList![index].checkData![i],
                      onChanged: (bool? isChecked) {
                        authController.setAdditionalCheckData(index, i, authController.dataList![index].checkData![i]);
                      }
                  ),
                  Text(
                    authController.dataList![index].checkData![i],
                    style: robotoRegular,
                  ),
                ]);
              },
            )

          ]) : showFile ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              authController.dataList![index].inputData?.replaceAll('_', ' ').toTitleCase() ?? '',
              style: robotoMedium,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: authController.additionalList![index].length + 1,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                FilePickerResult? file = i == authController.additionalList![index].length ? null : authController.additionalList![index][i];
                bool isImage = false;
                String fileName = '';
                bool canAddMultipleImage = authController.dataList![index].mediaData!.uploadMultipleFiles == 1;
                if(file != null) {
                  if(!GetPlatform.isWeb) {
                    fileName = file.files.single.path!.split('/').last;
                    isImage = file.files.single.path!.contains('jpg') || file.files.single.path!.contains('jpeg') || file.files.single.path!.contains('png');
                  } else {
                    fileName = file.files.first.name;
                    isImage = file.files.first.name.contains('jpg') || file.files.first.name.contains('jpeg') || file.files.first.name.contains('png');
                  }

                }
                if(i == authController.additionalList![index].length && (authController.additionalList![index].length < (canAddMultipleImage ? 6 : 1))) {
                  return InkWell(
                    onTap: () async {
                      await authController.pickFile(index, authController.dataList![index].mediaData!);
                    },
                    child: Container(
                      height: 100, width: 500,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Icon(Icons.add, size: 50, color: Theme.of(context).disabledColor),
                    ),
                  );
                }
                return file != null ? Stack(
                  children: [
                    Container(
                      height: 100, width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: isImage && !GetPlatform.isWeb ? ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: GetPlatform.isWeb ? Image.network(
                            file.files.single.path!, width: 100, height: 100, fit: BoxFit.cover,
                          ) : Image.file(
                            File(file.files.single.path!), width: 500, height: 100, fit: BoxFit.cover,
                          ),
                        ) : Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Image.asset(fileName.contains('doc') ? Images.documentIcon : Images.pdfIcon, height: 20, width: 20, fit: BoxFit.contain),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(
                                fileName,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: (){
                          authController.removeAdditionalFile(index, i);
                        },
                        icon: const Icon(CupertinoIcons.delete_simple, color: Colors.red),
                      ),
                    )
                  ],
                ) : const SizedBox();
              },
            )
          ])
              : const SizedBox(),
        );
      },
    );
  }
}
