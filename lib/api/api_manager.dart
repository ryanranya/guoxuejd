import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../untils/log_until.dart';
import '../api/api_error.dart';
import 'api_config.dart';

/// http 请求成功回调
typedef HttpSuccessCallback<T> = void Function(dynamic data);

/// http 请求失败回调
typedef HttpFailureCallback = void Function(HttpError data);

/// 数据解析回调
typedef T JsonParse<T>(dynamic data);

class ApiManager {
  Map<String, CancelToken> _cancelTokens = Map<String, CancelToken>();

  Dio _client;
  static final ApiManager _instance = ApiManager._internal();

  factory ApiManager() => _instance;

  Dio get client => _client;

  /// 创建 dio 实例对象
  ApiManager._internal() {
    if (_client == null) {
      /// 全局属性：请求前缀、连接超时时间、响应超时时间
      BaseOptions options = BaseOptions(
        connectTimeout: ApiConfig.CONNECT_TIMEOUT,
        receiveTimeout: ApiConfig.RECEIVE_TIMEOUT,
      );
      _client = Dio(options);
//        ..httpClientAdapter = Http2Adapter(
//          ConnectionManager(idleTimeout: CONNECT_TIMEOUT),
//        );

//      _client.interceptors..add(LcfarmLogInterceptor());
    }
  }

//   初始化需要用到的
  /// [baseUrl] 地址前缀
  /// [connectTimeout] 连接超时赶时间
  /// [receiveTimeout] 接收超时赶时间
  /// [interceptors] 基础拦截器
  void init(
      {String baseUrl,
      int connectTimeout,
      int receiveTimeout,
      List<Interceptor> interceptors}) {
    _client.options = _client.options.merge(
      baseUrl: ApiConfig.basURL,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
    if (interceptors != null && interceptors.isNotEmpty) {
      _client.interceptors..addAll(interceptors);
    }
  }

//  GET 网络请求
  void get({
    @required String url,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
    _request(
        url: url,
        params: params,
        method: ApiConfig.GET,
        successCallback: successCallback,
        errorCallback: errorCallback,
        tag: tag);
  }

//  POST 网络请求
  void post({
    @required String url,
    data,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
    _request(
      url: url,
      data: data,
      method: ApiConfig.POST,
      params: params,
      successCallback: successCallback,
      errorCallback: errorCallback,
      tag: tag,
    );
  }

//  统一处理网络请求
  void _request({
    @required String url,
    String method,
    data,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
//   首先检查网络是否连接
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.NETWORK_ERROR, '网络异常，请重试！'));
      }
      LogUtil.v("请求网络异常，请稍后重试！");
      return;
    }

    //设置默认值
    params = params ?? {};
    method = method ?? 'GET';
    print('请求的 method 中是 ${method}');
    options?.method = method;

    options = options ??
        Options(
          method: method,
        );

    url = _restfulUrl(url, params);

    try {
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
            _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }

      Response<Map<String, dynamic>> response = await _client.request(url,
          data: data,
          queryParameters: params,
          options: options,
          cancelToken: cancelToken);
      int statusCode = response.data["code"];
//      print('当前的 statusCode 是：${statusCode}');
      if (statusCode == 0) {
        //成功
        if (successCallback != null) {
//          print('请求成功之后返回的值${response.data['data']}');
          successCallback(response.data);
        }
      } else {
        //失败
        String message = response.data["message"];
        LogUtil.v("请求服务器出错：$message");
        if (errorCallback != null) {
          errorCallback(HttpError(statusCode.toString(), message));
        }
      }
    } on DioError catch (e, s) {
      LogUtil.v("请求出错：$e\n$s");
      if (errorCallback != null && e.type != DioErrorType.CANCEL) {
        errorCallback(HttpError.dioError(e));
      }
    } catch (e, s) {
      LogUtil.v("未知异常出错：$e\n$s");
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.UNKNOWN, "网络异常，请稍后重试！"));
      }
    }
  }

//  下载文件
  void download({
    @required String url,
    @required savePath,
    ProgressCallback onReceiveProgress,
    Map<String, dynamic> params,
    data,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
    //检查网络是否连接
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.NETWORK_ERROR, "网络异常，请稍后重试！"));
      }
      LogUtil.v("请求网络异常，请稍后重试！");
      return;
    }

    ////0代表不设置超时
    int receiveTimeout = 0;
    options ??= options == null
        ? Options(receiveTimeout: receiveTimeout)
        : options.merge(receiveTimeout: receiveTimeout);
    //设置默认值
    params = params ?? {};
    url = _restfulUrl(url, params);

    try {
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
            _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }

      Response response = await _client.download(url, savePath,
          onReceiveProgress: onReceiveProgress,
          queryParameters: params,
          data: data,
          options: options,
          cancelToken: cancelToken);
      //成功
      if (successCallback != null) {
        successCallback(response.data);
      }
    } on DioError catch (e, s) {
      LogUtil.v("请求出错：$e\n$s");
      if (errorCallback != null && e.type != DioErrorType.CANCEL) {
        errorCallback(HttpError.dioError(e));
      }
    } catch (error, s) {
      LogUtil.v('未知异常错误：$error\n $s');
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.UNKNOWN, '网络异常，请稍后重试！！！'));
      }
    }
  }

//  上传文件
  void upload({
    @required String url,
    FormData data,
    ProgressCallback onSendProgress,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
    //检查网络是否连接
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.NETWORK_ERROR, "网络异常，请稍后重试！"));
      }
      LogUtil.v("请求网络异常，请稍后重试！");
      return;
    }
//    设置默认参数
    params = params ?? {};
    options?.method = ApiConfig.POST;
    options = options ??
        Options(
          method: ApiConfig.POST,
        );

    try {
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
            _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }
      Response<Map<String, dynamic>> response = await _client.request(url,
          onSendProgress: onSendProgress,
          data: data,
          queryParameters: params,
          options: options,
          cancelToken: cancelToken);
      String statusCode = response.data["statusCode"];
      if (statusCode == "0") {
        //成功
        if (successCallback != null) {
          successCallback(response.data["data"]);
        }
      } else {
        //失败
        String message = response.data["statusDesc"];
        LogUtil.v("请求服务器出错：$message");
        if (errorCallback != null) {
          errorCallback(HttpError(statusCode, message));
        }
      }
    } on DioError catch (e, s) {
      LogUtil.v("请求出错：$e\n$s");
      if (errorCallback != null && e.type != DioErrorType.CANCEL) {
        errorCallback(HttpError.dioError(e));
      }
    } catch (error, s) {
      LogUtil.v("未知异常出错：$error\n$s");
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.UNKNOWN, "网络异常，请稍后重试！"));
      }
    }
  }

//  GET 异步网络请求
  Future<T> getAsync<T>({
    @required String url,
    Map<String, dynamic> params,
    Options options,
    JsonParse<T> jsonParse,
    @required String tag,
  }) async {
    return _requestAsync(
      url: url,
      method: ApiConfig.GET,
      params: params,
      options: options,
      jsonParse: jsonParse,
      tag: tag,
    );
  }

//  POST 异步网络请求
  Future<T> postAsync<T>({
    @required String url,
    data,
    Map<String, dynamic> params,
    Options options,
    JsonParse<T> jsonParse,
    @required String tag,
  }) async {
    return _requestAsync(
      url: url,
      method: ApiConfig.POST,
      data: data,
      params: params,
      options: options,
      jsonParse: jsonParse,
      tag: tag,
    );
  }

  Future<T> _requestAsync<T>({
    @required String url,
    String method,
    data,
    Map<String, dynamic> params,
    Options options,
    JsonParse<T> jsonParse,
    @required String tag,
  }) async {
    //检查网络是否连接
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      LogUtil.v("请求网络异常，请稍后重试！");
      throw (HttpError(HttpError.NETWORK_ERROR, "网络异常，请稍后重试！"));
    }

    //设置默认值
    params = params ?? {};
    method = method ?? 'GET';

    options?.method = method;

    options = options ??
        Options(
          method: method,
        );

    url = _restfulUrl(url, params);

    try {
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
            _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }

      Response<Map<String, dynamic>> response = await _client.request(url,
          queryParameters: params,
          data: data,
          options: options,
          cancelToken: cancelToken);
//      更加后台返回的自行判断 这里要自己注意
      String statusCode = response.data["statusCode"];
      if (statusCode == "0") {
        //成功
        if (jsonParse != null) {
          return jsonParse(response.data["data"]);
        } else {
          return response.data["data"];
        }
      } else {
        //失败
        String message = response.data["statusDesc"];
        LogUtil.v("请求服务器出错：$message");
        //只能用 Future，外层有 try catch
        return Future.error((HttpError(statusCode, message)));
      }
    } on DioError catch (e, s) {
      LogUtil.v("请求出错：$e\n$s");
      throw (HttpError.dioError(e));
    } catch (e, s) {
      LogUtil.v("未知异常出错：$e\n$s");
      throw (HttpError(HttpError.UNKNOWN, "网络异常，请稍后重试！"));
    }
  }

  Future<Response> downloadAsync({
    @required String url,
    @required savePath,
    ProgressCallback onReceiveProgress,
    Map<String, dynamic> params,
    data,
    Options options,
    @required String tag,
  }) async {
    //检查网络是否连接
    ConnectivityResult connectivityResult =
    await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      LogUtil.v("请求网络异常，请稍后重试！");
      throw (HttpError(HttpError.NETWORK_ERROR, "网络异常，请稍后重试！"));
    }
    //设置下载不超时
    int receiveTimeout = 0;
    options ??= options == null
        ? Options(receiveTimeout: receiveTimeout)
        : options.merge(receiveTimeout: receiveTimeout);

    //设置默认值
    params = params ?? {};

    url = _restfulUrl(url, params);

    try {
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
        _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }

      return _client.download(url, savePath,
          onReceiveProgress: onReceiveProgress,
          queryParameters: params,
          data: data,
          options: options,
          cancelToken: cancelToken);
    } on DioError catch (e, s) {
      LogUtil.v("请求出错：$e\n$s");
      throw (HttpError.dioError(e));
    } catch (e, s) {
      LogUtil.v("未知异常出错：$e\n$s");
      throw (HttpError(HttpError.UNKNOWN, "网络异常，请稍后重试！"));
    }
  }

  Future<T> uploadAsync<T>({
    @required String url,
    FormData data,
    ProgressCallback onSendProgress,
    Map<String, dynamic> params,
    Options options,
    JsonParse<T> jsonParse,
    @required String tag,
  }) async {
    //检查网络是否连接
    ConnectivityResult connectivityResult =
    await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      LogUtil.v("请求网络异常，请稍后重试！");
      throw (HttpError(HttpError.NETWORK_ERROR, "网络异常，请稍后重试！"));
    }

    //设置默认值
    params = params ?? {};

    //强制 POST 请求
    options?.method = ApiConfig.POST;

    options = options ??
        Options(
          method: ApiConfig.POST,
        );

    url = _restfulUrl(url, params);

    try {
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
        _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }

      Response<Map<String, dynamic>> response = await _client.request(url,
          onSendProgress: onSendProgress,
          data: data,
          queryParameters: params,
          options: options,
          cancelToken: cancelToken);

      String statusCode = response.data["statusCode"];
      if (statusCode == "0") {
        //成功
        if (jsonParse != null) {
          return jsonParse(response.data["data"]);
        } else {
          return response.data["data"];
        }
      } else {
        //失败
        String message = response.data["statusDesc"];
        LogUtil.v("请求服务器出错：$message");
        return Future.error((HttpError(statusCode, message)));
      }
    } on DioError catch (e, s) {
      LogUtil.v("请求出错：$e\n$s");
      throw (HttpError.dioError(e));
    } catch (e, s) {
      LogUtil.v("未知异常出错：$e\n$s");
      throw (HttpError(HttpError.UNKNOWN, "网络异常，请稍后重试！"));
    }
  }

  ///取消网络请求
  void cancel(String tag) {
    if (_cancelTokens.containsKey(tag)) {
      if (!_cancelTokens[tag].isCancelled) {
        _cancelTokens[tag].cancel();
      }
      _cancelTokens.remove(tag);
    }
  }

  ///restful处理
  String _restfulUrl(String url, Map<String, dynamic> params) {
    // restful 请求处理
    // /gysw/search/hist/:user_id        user_id=27
    // 最终生成 url 为     /gysw/search/hist/27
    params.forEach((key, value) {
      if (url.indexOf(key) != -1) {
        url = url.replaceAll(':$key', value.toString());
      }
    });
    return url;
  }
}
