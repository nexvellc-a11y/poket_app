import 'package:dio/dio.dart';
import 'package:poketstore/model/order_model/order_list_model.dart';
import 'package:poketstore/model/order_model/order_details_model.dart';

class OrderListService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.poketstor.com/api/order';

  Future<List<OrderSummary>> fetchOrders(String userId) async {
    final response = await _dio.get('$baseUrl/user-orders-summary/$userId');
    final data = response.data['orders'] as List;
    return data.map((json) => OrderSummary.fromJson(json)).toList();
  }

  Future<OrderDetail> fetchOrderDetails(String orderId) async {
    final response = await _dio.get('$baseUrl/order-products-details/$orderId');
    return OrderDetail.fromJson(response.data);
  }
}
