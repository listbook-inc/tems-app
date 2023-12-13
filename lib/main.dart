import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/bucket_page.dart';
import 'package:listbook/screen/home_page.dart';
import 'package:listbook/screen/login_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/translations_delegate.dart';
import 'package:listbook/utils/instance.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

clearSecureStorageOnReinstall() async {
  String key = 'hasRunBefore';
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final runBefore = prefs.getBool(key);

  print(prefs.getBool(key));
  if (runBefore != null) {
    print(!runBefore);
  }

  if (runBefore == null || !runBefore) {
    print("삭제!");
    FlutterSecureStorage storage = Instance.getInstanceStorage();
    final all = storage.readAll();
    print(all);

    await storage.deleteAll();
    prefs.setBool(key, true);
  } else {
    print("삭제 안함!");
  }
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.high,
  );

  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/launcher_icon');

  var initializationSettingsIos = const DarwinInitializationSettings();

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIos,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  print('Handling a background message: ${message.messageId}');
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
bool isFlutterLocalNotificationsInitialized = false;
AndroidNotificationChannel? channel;

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Firebase.initializeApp();

  await clearSecureStorageOnReinstall();

  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance.idTokenChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, sound: true);
  FirebaseMessaging.onMessage.listen((message) async {
    print(message.data);
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
          subtitle: 'the subtitle',
          sound: 'slow_spring_board.aiff',
        ),
      ),
    );
  });
  print(await FirebaseMessaging.instance.getToken());

  final storage = Instance.getInstanceStorage();
  final accessToken = await storage.read(key: accessTokenKey);
  print(accessToken);

  // await storage.deleteAll();
  String route = "/login";
  if (accessToken == null) {
    route = "/login";
  } else {
    route = "/home";
  }

  print(route);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomePageProvider()),
      ],
      child: MyApp(
        initialRoute: route,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late Server _server;
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("pendding! ${purchaseDetails.status}");
        // setState(() {
        //   _isLoading = true;
        // });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("error! ${purchaseDetails.error}");
          // setState(() {
          //   _isLoading = false;
          // });
          showOkAlertDialog(
            context: context,
            title: "결제 실패",
            message: purchaseDetails.error?.message ?? "일시적으로 결제에 실패했습니다.",
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          print("purchased! ${purchaseDetails.status}");
          print("purchased! ${purchaseDetails.productID}");
          print("purchased! ${purchaseDetails.purchaseID}");
          print("purchased! ${purchaseDetails.transactionDate}");
          // print("purchased! ${purchaseDetails.verificationData.serverVerificationData}");

          if (Platform.isIOS) {
            await _server
                .verifyReceipts(purchaseDetails.verificationData.serverVerificationData, true)
                .then((value) async {
              // if (widget.redirect == 'BUCKET') {
              //   Navigator.pop(context);
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => NewBucketPage(refresh: widget.refresh),
              //     ),
              //   );
              // } else {
              //   Navigator.pop(context);
              //   await widget.redirectMethod!();
              // }
            }).catchError((err) {
              if (err is DioException) {
                final e = err;
                showOkAlertDialog(
                  context: context,
                  title: "Faild subscript",
                  message: "Faild to subscription, reason : [${e.response?.data['message']}]",
                );

                return;
              } else {
                showOkAlertDialog(
                  context: context,
                  title: "Faild subscript",
                  message: "Faild to subscription, try again",
                );
                return;
              }
            });
          } else {
            final String? purchaseToken = purchaseDetails.purchaseID;
            final String productID = purchaseDetails.productID;
            final String packageName = purchaseDetails.verificationData.serverVerificationData;
            print("Purchase Information : $purchaseToken, $productID, $packageName");
          }
        }
        // if (Platform.isAndroid) {
        //   if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
        //     final InAppPurchaseAndroidPlatformAddition androidAddition =
        //         _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        //     await androidAddition.consumePurchase(purchaseDetails);
        //   }
        // }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails).catchError((err) {
            print(err);
            // showOkAlertDialog(context: context, title: "결제 실패");
          });
        }
      }
    }
  }

  @override
  void initState() {
    _server = Server(context);
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });

    FirebaseMessaging.onMessage.listen((message) async {
      await Firebase.initializeApp();
      await setupFlutterNotifications();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');
      if (message.data['type'] == "ITEM_NOT_USED") {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => BucketPage(
              bucket: message.data['bucket'],
              refresh: () async {},
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListBook',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: widget.initialRoute,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: Translations.of(context)?.trans("font") ?? "NeueMontreal",
      ),
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      localizationsDelegates: [
        TranslationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          debugPrint("*language locale is null!!!");
          return supportedLocales.first;
        }

        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            debugPrint("*language ok $supportedLocale");
            return supportedLocale;
          }
        }

        debugPrint("*language to fallback ${supportedLocales.first}");
        return supportedLocales.first;
      },
      routes: {
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginPage(),
      },
    );
  }
}
