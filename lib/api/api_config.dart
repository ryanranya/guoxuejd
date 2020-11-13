
import 'package:dio/dio.dart';

class ApiConfig{
   static const basURL = 'http://172.16.2.23:8090/api';
   //  设置请求超时时间
   static const CONNECT_TIMEOUT = 30000;
   static const RECEIVE_TIMEOUT = 30000;
  //  设置请求方式
  static const String GET = 'get';
  static const String POST = 'post';

//  设置请求头
static const Map<String, dynamic> header = {"Content-Type":"application/json"};
}

class HeaderInterceptor extends InterceptorsWrapper{


}

