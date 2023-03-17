// ignore_for_file: avoid_print
import 'package:flutter_real_app/common/secure_storage/secure_storage.dart';
import 'package:flutter_real_app/user/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_real_app/common/const/data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(storage: storage, ref: ref),
  );

  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({
    required this.storage,
    required this.ref,
  });

  // 1) 요청 보낼 때
  // 요청이 보내질 때마마
  // 요청의 Header에 accessToken: true라는 값이 있으면
  // 실제 토큰을 storage에서 가져와서 authorization: Bearer $token으로 헤더를 변경해 준다.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');
      final token = await storage.read(key: ACCESS_TOKEN_KEY);
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');
      final token = await storage.read(key: REFRESH_TOKEN_KEY);
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    print('[REQUEST]: [${options.method}] ${options.uri}');
    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을 때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RESPONSE] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을 때
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 에러의 요청방식과 경로를 확인해 본다.
    print('[Error]: [${err.requestOptions.method}] ${err.requestOptions.uri}');

    // 401에러가 났을 때(토큰에 문제가 있을 때 발생하는 에러)
    // 토큰을 재발급 받는 시도를 하고, 토큰이 재발급되면
    // 다시 새로운 토큰으로 요청을 보낸다.
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken이 없으면 에러를 발생시킨다.
    if (refreshToken == null) {
      // 에러를 발생시킬 때는 handler.reject 함수를 사용한다.
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    // 401에러가 났는데, 그것이 토큰을 재발급하는 경로인 auth/token이 아니라면
    // 토큰을 재발급 받을 수 있도록 auth/token으로 다시 요청을 보내
    // 새로운 토큰을 발급받도록 한다.
    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        final response = await dio.post(
          'http://$ip/auth/token',
          options: Options(headers: {
            'authorization': 'Bearer $refreshToken',
          }),
        );

        final accessToken = response.data['accessToken'];
        final options = err.requestOptions;
        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });
        // 다시 발급받은 accessToken을 storage에 저장해 둔다.
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
        // 요청 재전송
        final secondResponse = await dio.fetch(options);
        // 똑같은 요청에 대해 accessToken만 바꾸어
        // 재전송함으로써 에러가 발생하지 않은 것처럼 응답을 다시 보낼 수 있다.
        return handler.resolve(secondResponse);
      } on DioError catch (e) {
        // 아래와 같이 userMeProvider의 logout 함수를 통해
        // 로그아웃을 구현하려고 하면
        // 순환 반복 에러(circular dependency error)기 발생한다.
        // dio와 userMeProvider가 각작의 함수 안에서
        // 서로를 필수적으로 사용하도록 돼 있기 때문이다.
        // ref.read(userMeProvider.notifier).logout();

        // authProvider에 logout 함수를 넣어 두면 이 오류를 피할 수 있다.
        ref.read(authProvider.notifier).logout();
        return handler.reject(e);
      }
    }

    return super.onError(err, handler);
  }
}
