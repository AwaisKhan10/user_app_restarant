import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CuisineRepo {
  final ApiClient apiClient;
  CuisineRepo({required this.apiClient});

  Future<Response> getCuisineList() async {
    return await apiClient.getData(AppConstants.cuisineUri);
  }

  Future<Response> getCuisineRestaurantList(int offset, int cuisineId) async {
    return await apiClient.getData('${AppConstants.cuisineRestaurantUri}?cuisine_id=$cuisineId&offset=$offset&limit=10');
  }

}