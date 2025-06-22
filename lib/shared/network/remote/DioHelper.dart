import 'package:dio/dio.dart';

class DioHelper {

  static Dio? dio;

  static void init() {

    dio = Dio(
      BaseOptions(
        // baseUrl: 'http://127.0.0.1:8000',
        baseUrl: 'http://192.168.80.75:8000',
        receiveDataWhenStatusError: true,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
      ),
    );
  }



  static Future<Response?> getData({
    required String pathUrl,
}) async {

    return dio?.get(pathUrl);

  }


  static Future<Response?> postData({
    required String pathUrl,
    required Map<String, dynamic> data,
  }) async {

    return dio?.post(pathUrl, data: data);

  }


  static Future<Response?> putData({
    required String pathUrl,
    required Map<String, dynamic> data,
  }) async {

    return dio?.put(pathUrl, data: data);

  }


  static Future<Response?> deleteData({
    required String pathUrl,
  }) async {

    return dio?.delete(pathUrl);

  }


}