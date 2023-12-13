import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:listbook/screen/login_page.dart';
import 'package:listbook/translation.dart';

const s3URL = "https://tems-image-bucket.s3.ap-northeast-2.amazonaws.com/";
// const _baseUrl = "http://localhost:8040";
// const _baseUrl = "http://192.168.0.5:8040";
// const _baseUrl = "http://172.20.10.9:8040";
const _baseUrl = "https://tems.listbook.com:8040";
const accessTokenKey = "ACCESS_TOKEN";
const refreshTokenKey = "REFRESH_TOKEN";
const expireKey = "EXPIRE_DATE";

class TemsInterceptor extends Interceptor {
  final Function() onFailedRefresh;
  final Dio dio = Dio();

  TemsInterceptor({required this.onFailedRefresh});

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

    // final expiredAt = await storage.read(key: expireKey);
    // print(expiredAt);
    // if (expiredAt != null) {
    //   final expiredByNum = int.tryParse(expiredAt);
    //   print(expiredByNum);
    //   if (expiredByNum != null) {
    //     final expiredDate = DateTime.fromMillisecondsSinceEpoch(expiredByNum);
    //     print(expiredDate);

    //     if (DateTime.now().isAfter(expiredDate)) {
    //       final refreshToken = await storage.read(key: refreshTokenKey);

    //       await dio
    //           .put(
    //         "$_baseUrl/auth/refreshtoken",
    //         options: Options(
    //           headers: {
    //             "X-Refresh-Token": "Bearer $refreshToken",
    //           },
    //         ),
    //       )
    //           .then((value) async {
    //         await storage.deleteAll();
    //         await storage.write(key: accessTokenKey, value: value.data['accessToken']);
    //         await storage.write(key: refreshTokenKey, value: value.data['refreshToken']);
    //         await storage.write(key: expireKey, value: value.data['expiredAt'].toString());
    //       }).catchError((err) async {
    //         print(err);
    //         await storage.deleteAll();
    //         onFailedRefresh();
    //       });
    //     }
    //   }
    // }

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
  final _photoRoomApiKey = "b786b0325af0eaf1ca18cf10a764168d6bf17f31";

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

  Future<Response> signUp(String? idToken, FormData formData, BuildContext context) async {
    final deviceToken = await FirebaseMessaging.instance.getToken();

    String? locale = Translations.of(context)?.getLocale();
    print("======LOCALE======");
    print(locale);
    print("======LOCALE======");

    return await _noneAuthDio.post(
      "/auth/signup",
      data: formData,
      options: Options(
        headers: {
          "X-ID-TOKEN": idToken,
          "X-DEVICE-TOKEN": deviceToken,
          "X-LOCALE": locale,
        },
      ),
    );
  }

  Future<Response> signIn(String? idToken, BuildContext context) async {
    final deviceToken = await FirebaseMessaging.instance.getToken();

    String? locale = Translations.of(context)?.getLocale();

    print("======LOCALE======");
    print(locale);
    print("======LOCALE======");

    return await _noneAuthDio.post(
      '/auth/signin',
      options: Options(
        headers: {
          "X-ID-TOKEN": idToken,
          "X-DEVICE-TOKEN": deviceToken,
          "X-LOCALE": locale,
        },
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

  Future<Response> updateSecurity(bool isSecurity, int bucketId) async {
    return await _authDio.put(
      "/bucket/item/security/$bucketId",
      data: {
        "isSecurity": isSecurity,
      },
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

  Future<Response> getBucketHistories(int bucketId) async {
    return await _authDio.get(
      "/bucket/bucket-histories/$bucketId",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> searchItemByName(String searchText) async {
    return await _authDio.get(
      "/bucket/search",
      queryParameters: {
        "searchText": searchText,
      },
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> editBucket(FormData formData, int bucketId) async {
    return await _authDio.put(
      "/bucket/edit/$bucketId",
      data: formData,
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> deleteBucket(int bucketId) async {
    return await _authDio.delete(
      "/bucket/$bucketId",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> uploadBucket(String name, String type, bool isSecurityFolder) async {
    return await _authDio.post(
      "/bucket/upload",
      data: {
        "bucketName": name,
        "bucketType": type,
        "isSecurityFolder": isSecurityFolder,
      },
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> updateItem(FormData formData, int itemId) async {
    return await _authDio.put(
      "/bucket/item/edit/$itemId",
      data: formData,
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> deleteItem(int itemId) async {
    return await _authDio.delete(
      "/bucket/item/$itemId",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> getRegisterLog() async {
    return await _authDio.get(
      "/bucket/item/register",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> useItem(int itemId) async {
    return await _authDio.put(
      "/bucket/item/use/$itemId",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> useDailyItem(int itemId) async {
    return await _authDio.put(
      "/bucket/item/use-daily/$itemId",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> getWelcomeMessage() async {
    return await _authDio.get(
      "/user/welcome",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> deleteAccount() async {
    return await _authDio.delete(
      "/user/account",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> verifyReceipts(String? receiptsData, bool isSandbox) async {
    return await _noneAuthDio.post(
      "/payment/verifyReceipt/apple",
      data: {
        "receipt-data": receiptsData,
      },
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> checkTrial() async {
    return await _noneAuthDio.get(
      "/user/check-trial",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> okFailRenew() async {
    return await _authDio.put(
      "/user/ok/fail",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> androidVerifyReceipt(Map<String, dynamic> query) async {
    return await _authDio.post(
      "/payment/android/subscription",
      queryParameters: query,
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }

  Future<Response> getAlarms() async {
    return await _authDio.get(
      "/user/alarm",
      options: Options(
        headers: {
          "Authorization": await getToken(),
        },
      ),
    );
  }
}
