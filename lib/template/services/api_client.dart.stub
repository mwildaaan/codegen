import 'dart:convert';
import 'dart:io';

import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:appName/constants/K.dart';
import 'package:appName/constants/canoncial_path.dart';
import 'package:appName/constants/env.dart';
import 'package:appName/constants/error_message.dart';
import 'package:appName/app/app.dart';

class ApiClient {
  Dio _dio = Dio();
  bool isAuth;

  ApiClient({this.isAuth = false}) {
    Alice alice = Alice(navigatorKey: navigatorKey);

    _dio = Dio(
      BaseOptions(
        baseUrl: isAuth ? K.baseUrlUser : K.baseUrlCore,
        connectTimeout: 5000,
        receiveTimeout: 3000,
      ),
    )..interceptors.add(
        PrettyDioLogger(
          error: true,
          request: true,
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
          compact: true,
          maxWidth: 500,
        ),
      );

    if (EnvValue.staging.config.label == "staging"){
      _dio.interceptors.add(alice.getDioInterceptor());
    }
  }

  Future<Response?> getData(
    String endpoint, {
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      String token = prefs.read("auth_token") ?? "";

      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['authorization'] = token;

      final response = await _dio.get(
        Uri.encodeFull(endpoint),
        options: Options(headers: headers),
        cancelToken: cancelToken,
        queryParameters: queryParameters,
      );
      return response;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        throw ('Connection Time Out');
      }
      throw (await _handleError(e));
    } catch (e) {
      print("ERROR getData $e");
      throw Exception(e);
    }
  }

  Future<Response?> postData(String endpoint, dynamic data,
      {Map<String, dynamic>? headers}) async {
    try {
      String token = prefs.read("auth_token") ?? "";

      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['authorization'] = token;
      final response = await _dio.post(
        Uri.encodeFull(endpoint),
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        throw ('Connection Time Out');
      }
      throw (await _handleError(e));
    } catch (e) {
      print("ERROR postData $e");
      throw Exception(e);
    }
  }

  Future<Response?> patchData(String endpoint, dynamic data,
      {Map<String, dynamic>? headers}) async {
    try {
      String token = prefs.read("auth_token") ?? "";

      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['authorization'] = token;
      final response = await _dio.patch(
        Uri.encodeFull(endpoint),
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        throw ('Connection Time Out');
      }
      throw (await _handleError(e));
    } catch (e) {
      print("ERROR postData $e");
      throw Exception(e);
    }
  }

  Future<Response?> putData(String endpoint, dynamic data,
      {Map<String, dynamic>? headers}) async {
    try {
      String token = prefs.read("auth_token") ?? "";

      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['authorization'] = token;
      final response = await _dio.put(
        Uri.encodeFull(endpoint),
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        throw ('Connection Time Out');
      }
      throw (await _handleError(e));
    } catch (e) {
      print("ERROR postData $e");
      throw Exception(e);
    }
  }

  Future<Response> deleteData(String endpoint,
      {Map<String, dynamic>? headers}) async {
    try {
      String token = prefs.read("auth_token") ?? "";

      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['authorization'] = token;
      final response = await _dio.get(
        Uri.encodeFull(endpoint),
        options: Options(headers: headers),
      );
      return response;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        throw ('Connection Time Out');
      }
      throw (await _handleError(e));
    } catch (e) {
      print("ERROR postData $e");
      throw Exception(e);
    }
  }

  Future<Response?> postMultipartData(String endpoint,
      {Map<String, dynamic>? headers,
      required File file,
      required String paramName,
      required String filename,
      required String fileType,
      required String type}) async {
    final multipartData = FormData.fromMap({
      "fileType": fileType,
      "type": type,
      paramName:
      await MultipartFile.fromFile(file.path, filename: filename),
    });
    final formData = multipartData;
    return postData(endpoint, formData, headers: headers);
  }

  Future<String> _handleError(DioError e) async {
    String errorConnection = "Failed host lookup";
    String unreachable = "Network is unreachable";
    if (e.error.toString().contains(errorConnection) ||
        e.error.toString().contains(unreachable)) {
      // Navigator.of(navigatorKey.currentContext).pushNamed(
      //   Routes.noInternet,
      //   arguments: NoInternetArguments(""),
      // );
      return "No internet connection";
    }
    Map<String, dynamic> err = jsonDecode(e.response.toString());
    String msg = "Unknown Error";
    print('error message : ${err["message"]}');

    if (err == null) {
      if (e.response == null) {
        msg = "Unknown Error";
        if (e.requestOptions.path.contains(CanonicalPath.LOGIN)) {
          return CustomErrorMessage.CODE_NOT_200_LOGIN;
        }
        return msg;
      }
      if (e.response?.statusCode == 500) {
        return CustomErrorMessage.CODE_500;
      }
      return e.response?.statusMessage ?? "";
    }
    if (err.containsKey("code")) {
      if (err["code"] == 500) {
        if (err["message"] == "Invalid or Expired OTP Number") {
          return CustomErrorMessage.CODE_404_OTP_NOTVALID;
        } else if (err["message"] == "email Already Registered") {
          return CustomErrorMessage.CODE_500_ALREADY_REGISTERED;
        } else {
          return CustomErrorMessage.CODE_500;
        }
      }
      if (err["code"] == 401) {
        try {
          prefs.remove("auth_token");
        } catch (error) {
          // case data storage from empty
        }
        if (e.requestOptions.path.contains(CanonicalPath.LOGIN)) {
          return CustomErrorMessage.CODE_401_LOGIN;
        }
        return CustomErrorMessage.CODE_401;
      }
      if (e.requestOptions.path.contains(CanonicalPath.LOGIN)) {
        return CustomErrorMessage.CODE_NOT_200_LOGIN;
      }
    }
    if (err.containsKey("errors")) {
      var mErr = err["errors"][0];
      if (mErr["status"] == "401") {
        try {
          prefs.remove("auth_token");
        } catch (error) {
          // case data storage from empty
        }
        if (e.requestOptions.path.contains(CanonicalPath.LOGIN)) {
          return CustomErrorMessage.CODE_401_LOGIN;
        }
        return CustomErrorMessage.CODE_401;
      }
      if (mErr["status"] == "422") {
        return mErr['detail'];
      }
    }
    if (err.containsKey("message")) msg = err["message"];
    if (err.containsKey("description")) msg = err["description"];
    if (err.containsKey("meta")) msg = err["meta"]["message"];
    if (msg == "OTP Number Not Valid") {
      return CustomErrorMessage.CODE_404_OTP_NOTVALID;
    }
    if (msg.contains("SQLSTATE")) {
      // debugLog(msg);
      return "Unknown Error";
    }
    if (msg.contains("invalid_credential")) {
      // debugLog(msg);
      return "Email atau password salah";
    }
    if (msg.contains("Unexpected end of input")) {
      // debugLog(msg);
      return CustomErrorMessage.SERVER_ERROR;
    }
    return msg;
  }
}
