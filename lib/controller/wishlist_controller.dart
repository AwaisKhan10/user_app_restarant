import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/data/repository/product_repo.dart';
import 'package:efood_multivendor/data/repository/wishlist_repo.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class WishListController extends GetxController implements GetxService {
  final WishListRepo wishListRepo;
  final ProductRepo productRepo;
  WishListController({required this.wishListRepo, required this.productRepo});

  List<Product?>? _wishProductList;
  List<Restaurant?>? _wishRestList;
  List<int?> _wishProductIdList = [];
  List<int?> _wishRestIdList = [];

  List<Product?>? get wishProductList => _wishProductList;
  List<Restaurant?>? get wishRestList => _wishRestList;
  List<int?> get wishProductIdList => _wishProductIdList;
  List<int?> get wishRestIdList => _wishRestIdList;

  void addToWishList(Product? product, Restaurant? restaurant, bool isRestaurant) async {
    Response response = await wishListRepo.addWishList(isRestaurant ? restaurant!.id : product!.id, isRestaurant);
    if (response.statusCode == 200) {
      if(isRestaurant) {
        _wishRestIdList.add(restaurant!.id);
        _wishRestList!.add(restaurant);
      }else {
        _wishProductList!.add(product);
        _wishProductIdList.add(product!.id);
      }
      showCustomSnackBar(response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void removeFromWishList(int? id, bool isRestaurant) async {
    Response response = await wishListRepo.removeWishList(id, isRestaurant);
    if (response.statusCode == 200) {
      int idIndex = -1;
      if(isRestaurant) {
        idIndex = _wishRestIdList.indexOf(id);
        _wishRestIdList.removeAt(idIndex);
        _wishRestList!.removeAt(idIndex);
      }else {
        idIndex = _wishProductIdList.indexOf(id);
        _wishProductIdList.removeAt(idIndex);
        _wishProductList!.removeAt(idIndex);
      }
      showCustomSnackBar(response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getWishList({bool fromFavScreen = false}) async {
    if(fromFavScreen){
      _wishProductList = null;
      _wishRestList = null;
      _wishRestIdList = [];
    }else {
      _wishProductList = [];
      _wishRestList = [];
      _wishRestIdList = [];
    }
    Response response = await wishListRepo.getWishList();
    if (response.statusCode == 200) {
      if(fromFavScreen){
        _wishProductList = [];
        _wishRestList = [];
        _wishRestIdList = [];
      }
      update();
      response.body['food'].forEach((food) async {
        Product product = Product.fromJson(food);
        _wishProductList!.add(product);
        _wishProductIdList.add(product.id);
      });
      response.body['restaurant'].forEach((res) async {
        Restaurant? restaurant;
        try{
          restaurant = Restaurant.fromJson(res);
        }catch(_){}
        _wishRestList!.add(restaurant);
        _wishRestIdList.add(restaurant!.id);
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void removeWishes() {
    _wishProductIdList = [];
    _wishRestIdList = [];
  }
}
