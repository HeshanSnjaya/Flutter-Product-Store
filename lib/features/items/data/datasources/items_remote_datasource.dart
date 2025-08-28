import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/item_model.dart';

abstract class ItemsRemoteDataSource {
  Future<List<ItemModel>> getAllItems();
  Future<List<ItemModel>> getFilteredItems({
    String? category,
    String? subCategory,
  });
  Future<bool> checkHealth();
}

class ItemsRemoteDataSourceImpl implements ItemsRemoteDataSource {
  final Dio dio;

  ItemsRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? DioClient.instance;

  @override
  Future<bool> checkHealth() async {
    try {
      final response = await dio.get(ApiConstants.healthEndpoint);
      
      return response.statusCode == 200 && 
             response.data is Map &&
             response.data['status'] == 'ok';
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<ItemModel>> getAllItems() async {
    try {
      final response = await dio.get(ApiConstants.itemsEndpoint);
      
      if (response.data is List) {
        final List<dynamic> itemsJson = response.data;
        return itemsJson
            .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format: Expected List but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch items: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<ItemModel>> getFilteredItems({
    String? category,
    String? subCategory,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (category != null && category.trim().isNotEmpty) {
        queryParams['category'] = category.trim();
      }
      
      if (subCategory != null && subCategory.trim().isNotEmpty) {
        queryParams['subCategory'] = subCategory.trim();
      }

      final response = await dio.get(
        ApiConstants.itemsFilterEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      
      if (response.data is List) {
        final List<dynamic> itemsJson = response.data;
        return itemsJson
            .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format: Expected List but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to filter items: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
