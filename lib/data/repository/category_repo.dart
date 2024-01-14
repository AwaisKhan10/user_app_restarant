import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CategoryRepo {
  final ApiClient apiClient;
  CategoryRepo({required this.apiClient});

  Future<Response> getCategoryList() async {
    return await apiClient.getData(AppConstants.categoryUri);
  }

  Future<Response> getSubCategoryList(String? parentID) async {
    return await apiClient.getData('${AppConstants.subCategoryUri}$parentID');
  }

  Future<Response> getCategoryProductList(String? categoryID, int offset, String type) async {
    return await apiClient.getData('${AppConstants.categoryProductUri}$categoryID?limit=10&offset=$offset&type=$type');
  }

  Future<Response> getCategoryRestaurantList(String? categoryID, int offset, String type) async {
    return await apiClient.getData('${AppConstants.categoryRestaurantUri}$categoryID?limit=10&offset=$offset&type=$type');
  }

  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, String type) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}${isRestaurant ? 'restaurants' : 'products'}/search?name=$query&category_id=$categoryID&type=$type&offset=1&limit=50',
    );
  }

  Future<Response> saveUserInterests(List<int?> interests) async {
    return await apiClient.postData(AppConstants.interestUri, {"interest": interests});
  }

}