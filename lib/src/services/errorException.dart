import 'package:dio/dio.dart';

class ErrorExceptionHandler implements Exception {
  ErrorExceptionHandler.fromError(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        message = "Request to server was cancelled";
        break;
      // case DioErrorType.connectTimeout:
      //   message = "Connection timeout with server";
      //   break;  //Balu
      // case DioErrorType.other:
      //   message = "Connection to server failed due to internet connection";
      //   break;   //Balu
      case DioErrorType.receiveTimeout:
        message = "Receive timeout in connection with server";
        break;
      // case DioErrorType.response:
      //   message = _handleError(error.response!.statusCode);
      //   break; //Balu
      case DioErrorType.sendTimeout:
        message = "Send timeout in connection with server";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String? message;

  String _handleError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 404:
        return 'The requested resource was not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message!;
}
