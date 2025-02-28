import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../models/product.dart';

class ProductsResponse {
  final List<Product> items;
  final String? nextCursor;

  ProductsResponse({
    required this.items,
    this.nextCursor,
  });
}

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: AppConfig.headers,
      ),
    );

    if (AppConfig.debugMode) {
      _dio.interceptors.add(_simpleLogInterceptor());
    }
  }

  InterceptorsWrapper _simpleLogInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print("📤 REQUEST [${options.method}] ${options.uri} ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            "📥 RESPONSE [${response.statusCode}] ${response.requestOptions.path}");
        return handler.next(response);
      },
      onError: (e, handler) {
        print("❌ ERROR [${e.response?.statusCode}] ${e.requestOptions.path}");
        return handler.next(e);
      },
    );
  }

  Future<List<Product>> getRecommendedProducts() async {
    try {
      print('eiei:2');
      final response = await _dio.get(AppConfig.recommendedProductsPath);
      print('eiei3:${response}');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }

      throw 'ไม่สามารถโหลดสินค้าได้: ${response.statusCode}';
    } catch (e) {
      print(e);
      throw e is DioException ? _getErrorMessage(e) : 'เกิดข้อผิดพลาด: $e';
    }
  }

  Future<ProductsResponse> getProducts({String? cursor, int limit = 20}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
      };

      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        final List<Product> items = (data['items'] as List)
            .map((json) => Product.fromJson(json))
            .toList();

        return ProductsResponse(
          items: items,
          nextCursor: data['nextCursor'] as String?,
        );
      }

      throw 'ไม่สามารถโหลดสินค้าล่าสุดได้: ${response.statusCode}';
    } catch (e) {
      print(e);
      throw e is DioException ? _getErrorMessage(e) : 'เกิดข้อผิดพลาด: $e';
    }
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'การเชื่อมต่อหมดเวลา';
      case DioExceptionType.badResponse:
        return 'เซิร์ฟเวอร์ตอบกลับผิดพลาด: ${e.response?.statusCode}';
      default:
        return 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
    }
  }
}
