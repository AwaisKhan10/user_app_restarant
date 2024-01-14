import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/response/cuisine_model.dart';
import 'package:efood_multivendor/data/model/response/cuisine_restaurants_model.dart';
import 'package:efood_multivendor/data/repository/cuisine_repo.dart';
import 'package:get/get.dart';

class CuisineController extends GetxController implements GetxService {
  final CuisineRepo cuisineRepo;
  CuisineController({required this.cuisineRepo});

  CuisineModel? _cuisineModel;
  CuisineRestaurantModel? _cuisineRestaurantsModel;
  bool _isLoading = false;
  List<int>? _selectedCuisines;
  int _currentIndex = 0;

  CuisineModel? get cuisineModel => _cuisineModel;
  CuisineRestaurantModel?  get cuisineRestaurantsModel => _cuisineRestaurantsModel;
  bool get isLoading => _isLoading;
  List<int>? get selectedCuisines => _selectedCuisines;
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void initialize(){
    _cuisineRestaurantsModel = null;
  }

  Future<List<int?>> getCuisineList() async {
    _selectedCuisines = [];
    Response response = await cuisineRepo.getCuisineList();
    List<int?> cuisineIds = [];
    if (response.statusCode == 200) {
      cuisineIds.add(0);
      _cuisineModel = CuisineModel.fromJson(response.body);
      for (var cuisine in _cuisineModel!.cuisines!) {
        cuisineIds.add(cuisine.id);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return cuisineIds;
  }

  Future<void> getCuisineRestaurantList(int cuisineId, int offset, bool reload) async {
    if(reload) {
      _cuisineRestaurantsModel = null;
      update();
    }
    Response response = await cuisineRepo.getCuisineRestaurantList(offset, cuisineId);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _cuisineRestaurantsModel = CuisineRestaurantModel.fromJson(response.body);
      }else {
        _cuisineRestaurantsModel!.totalSize = CuisineRestaurantModel.fromJson(response.body).totalSize;
        _cuisineRestaurantsModel!.offset = CuisineRestaurantModel.fromJson(response.body).offset;
        _cuisineRestaurantsModel!.restaurants!.addAll(CuisineRestaurantModel.fromJson(response.body).restaurants!);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void setSelectedCuisineIndex(int index, bool notify) {
    if(!_selectedCuisines!.contains(index)) {
      _selectedCuisines!.add(index);
      if(notify) {
        update();
      }
    }
  }

  void removeCuisine(int index) {
    _selectedCuisines!.removeAt(index);
    update();
  }
}