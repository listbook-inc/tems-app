import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:listbook/screen/login_page.dart';

const s3URL = "https://tems-image-bucket.s3.ap-northeast-2.amazonaws.com/";
// const _baseUrl = "http://localhost:8040";
const _baseUrl = "http://192.168.0.5:8040";
const accessTokenKey = "ACCESS_TOKEN";
const refreshTokenKey = "REFRESH_TOKEN";
const expireKey = "EXPIRE_DATE";

class TemsInterceptor extends Interceptor {
  final Function() onFailedRefresh;

  const TemsInterceptor({required this.onFailedRefresh});

  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // options.headers = {
    //   "Authorization": pref.getString(accessTokenKey),
    // };
    print(options.headers);

    final expiredAt = await storage.read(key: expireKey);
    print(expiredAt);
    if (expiredAt != null) {
      final expiredByNum = int.tryParse(expiredAt);
      print(expiredByNum);
      if (expiredByNum != null) {
        final expiredDate = DateTime.fromMillisecondsSinceEpoch(expiredByNum);
        print(expiredDate);

        if (DateTime.now().isAfter(expiredDate)) {
          final refreshToken = await storage.read(key: refreshTokenKey);

          Dio()
              .put(
            "$_baseUrl/auth/refreshtoken",
            options: Options(
              headers: {
                "X-Refresh-Token": "Bearer $refreshToken",
              },
            ),
          )
              .then((value) async {
            await storage.write(key: accessTokenKey, value: value.data['accessToken']);
            await storage.write(key: refreshTokenKey, value: value.data['refreshToken']);
            await storage.write(key: expireKey, value: value.data['expiredAt'].toString());
          }).catchError((err) async {
            print(err);
            await storage.deleteAll();
            onFailedRefresh();
          });
        }
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print("==========");
    // print(response.data);
    // print("==========");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("==========");
    print(err.response?.data);
    print("==========");
    super.onError(err, handler);
  }
}

class Server {
  late Dio _authDio;
  late Dio _noneAuthDio;
  final _photoRoomApiKey = "93a5232956dbb076b68f6237f1ccd009680e71f1";

  Server(BuildContext context) {
    _authDio = Dio(BaseOptions(
      baseUrl: _baseUrl,
    ));
    _authDio.interceptors.add(
      TemsInterceptor(onFailedRefresh: () {
        showOkAlertDialog(
          context: context,
          title: "Logout!",
          message: "You have been logged out because you have not logged in for a long time.",
        ).then(
          (value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          ),
        );
      }),
    );

    _noneAuthDio = Dio(BaseOptions(
      baseUrl: _baseUrl,
    ));
  }

  Future<String?> getToken() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    return "Bearer ${await storage.read(key: accessTokenKey)}";
  }

  Future<Response> checkSignup(String? idToken) async {
    return await _noneAuthDio.get(
      "/auth/check",
      options: Options(
        headers: {"X-ID-TOKEN": idToken},
      ),
    );
  }

  Future<Response> signUp(String? idToken, FormData formData) async {
    return await _noneAuthDio.post(
      "/auth/signup",
      data: formData,
      options: Options(
        headers: {
          "X-ID-TOKEN": idToken,
        },
      ),
    );
  }

  Future<Response> signIn(String? idToken) async {
    return await _noneAuthDio.post(
      '/auth/signin',
      options: Options(
        headers: {"X-ID-TOKEN": idToken},
      ),
    );
  }

  Future<Response> getDefaultCategories() async {
    return await _noneAuthDio.get(
      "/bucket/default",
    );
  }

  Future<Response> makeBucket(String name) async {
    return await _noneAuthDio.get(
      "/bucket/random",
      queryParameters: {
        "bucketName": name,
      },
    );
  }

  Future<Response> getMyProfile() async {
    return await _authDio.get(
      "/user/myinfo",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> getMyMainBucket() async {
    return await _authDio.get(
      "/bucket/main",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> updateBuckets(Map data) async {
    return await _authDio.put(
      "/bucket/change",
      data: data,
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> updateUserInfo(Map data) async {
    return await _authDio.put(
      "/user/info",
      data: data,
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> updateProfile(FormData formData) async {
    return await _authDio.put(
      "/user/image",
      data: formData,
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> getManageItems() async {
    return await _authDio.get(
      "/bucket/allitems",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> removeBackground(FormData formData, String saveUrl) async {
    return await Dio().post(
      "https://sdk.photoroom.com/v1/segment",
      data: formData,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          "x-api-key": _photoRoomApiKey,
        },
      ),
    );
  }

  Future<Response> uploadItem(FormData formData, int bucketId) async {
    return await _authDio.post(
      "/bucket/item/upload/$bucketId",
      data: formData,
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> signOut() async {
    return await _authDio.delete(
      "/auth/signout",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> getHistories() async {
    return await _authDio.get(
      "/bucket/histories",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }
}
