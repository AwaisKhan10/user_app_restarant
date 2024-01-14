import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

class AllPopularRestaurantsFilterButton extends StatelessWidget {
  const AllPopularRestaurantsFilterButton({Key? key, this.isSelected, this.onTap, required this.buttonText}) : super(key: key);

  final bool? isSelected;
  final void Function()? onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: isSelected == true ? Theme.of(context).primaryColor.withOpacity(0.3) : Theme.of(context).disabledColor.withOpacity(0.3)),
        ),
        child:  Center(child: Text(buttonText, style: robotoRegular.copyWith( fontSize: Dimensions.fontSizeSmall,
            fontWeight: isSelected == true ? FontWeight.w500 : FontWeight.w400,
            color: isSelected == true ? Theme.of(context).primaryColor : Theme.of(context).disabledColor))),
      ),
    );
  }
}
