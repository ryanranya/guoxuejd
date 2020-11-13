import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guoxuejd/api/api_config.dart';
import 'package:guoxuejd/api/api_manager.dart';
import 'package:guoxuejd/tabbar/bottom_tabbar.dart';

void main() {
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //     初始化网络请求
    ApiManager().init(
        baseUrl: ApiConfig.basURL,
        connectTimeout: ApiConfig.CONNECT_TIMEOUT,
        receiveTimeout: ApiConfig.RECEIVE_TIMEOUT,
        interceptors: [
//          HeaderInterceptor(),
          LogInterceptor()
        ]
    );

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 18, 150, 219),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: WBMainTabBarPage(),
    );
  }
}