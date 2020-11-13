import 'package:dio/dio.dart';

class HttpError {
//  状态码
  static const UNAUTHORIZED = 401;
  static const FORBIDDEN = 403;
  static const NOT_FOUND = 404;
  static const REQUEST_TIMEOUT = 408;
  static const INTERNAL_SERVER_ERROR = 500;
  static const BAD_GATEWAY = 502;
  static const SERVICE_UNAVAILABLE = 503;
  static const GATEWAY_TIMEOUT = 504;

  ///未知错误
  static const UNKNOWN = "UNKNOWN";

  ///解析错误
  static const PARSE_ERROR = "PARSE_ERROR";

  ///网络错误
  static const NETWORK_ERROR = "NETWORK_ERROR";

  ///协议错误
  static const HTTP_ERROR = "HTTP_ERROR";

  ///证书错误
  static const SSL_ERROR = "SSL_ERROR";

  ///连接超时
  static const CONNECT_TIMEOUT = "CONNECT_TIMEOUT";

  ///响应超时
  static const RECEIVE_TIMEOUT = "RECEIVE_TIMEOUT";

  ///发送超时
  static const SEND_TIMEOUT = "SEND_TIMEOUT";

  ///网络请求取消
  static const CANCEL = "CANCEL";

  String code, message;
//  初始化
  HttpError(this.code, this.message);

  HttpError.dioError(DioError error) {
    message = error.message;
    switch (error.type) {
      case DioErrorType.CONNECT_TIMEOUT:
        code = CONNECT_TIMEOUT;
        message = '网络连接超时，请检查网络设置';
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        code = RECEIVE_TIMEOUT;
        message = '服务器异常，请稍后重试';
        break;
      case DioErrorType.SEND_TIMEOUT:
        code = SEND_TIMEOUT;
        message = "网络连接超时，请检查网络设置";
        break;
      case DioErrorType.RESPONSE:
        code = HTTP_ERROR;
        message = "服务器异常，请稍后重试！";
        break;
      case DioErrorType.CANCEL:
        code = CANCEL;
        message = "请求已被取消，请重新请求";
        break;
      case DioErrorType.DEFAULT:
        code = UNKNOWN;
        message = "网络异常，请稍后重试！";
        break;
    }
  }

  String toString() {
    return 'HttpError{code:$code,message:$message}';
  }
}
