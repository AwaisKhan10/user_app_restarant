import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/helper/price_converter.dart';

class ProductHelper {

  static double getVariationPriceWithDiscount(Product product, ProductController productController, double? discount, String? discountType) {
    double variationPrice = 0;
    if(product.variations != null){
      for(int index = 0; index< product.variations!.length; index++) {
        for(int i=0; i<product.variations![index].variationValues!.length; i++) {
          if(productController.selectedVariations[index].isNotEmpty && productController.selectedVariations[index][i]!) {
            variationPrice += PriceConverter.convertWithDiscount(product.variations![index].variationValues![i].optionPrice!, discount, discountType)!;
          }
        }
      }
    }
    return variationPrice;
  }

  static double getVariationPrice(Product product, ProductController productController) {
    double variationPrice = 0;
    if(product.variations != null){
      for(int index = 0; index< product.variations!.length; index++) {
        for(int i=0; i<product.variations![index].variationValues!.length; i++) {
          if(productController.selectedVariations[index].isNotEmpty && productController.selectedVariations[index][i]!) {
            variationPrice += PriceConverter.convertWithDiscount(product.variations![index].variationValues![i].optionPrice!, 0, 'none')!;
          }
        }
      }
    }
    return variationPrice;
  }

  static double getAddonCost(Product product, ProductController productController) {
    double addonsCost = 0;

    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addonsCost = addonsCost + (product.addOns![index].price! * productController.addOnQtyList[index]!);
      }
    }

    return addonsCost;
  }

  static List<AddOn> getAddonIdList(Product product, ProductController productController) {
    List<AddOn> addOnIdList = [];
    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addOnIdList.add(AddOn(id: product.addOns![index].id, quantity: productController.addOnQtyList[index]));
      }
    }

    return addOnIdList;
  }

  static List<AddOns> getAddonList(Product product, ProductController productController) {
    List<AddOns> addOnsList = [];
    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addOnsList.add(product.addOns![index]);
      }
    }

    return addOnsList;
  }
}