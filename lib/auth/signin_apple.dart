import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:listbook/screen/home_page.dart';
import 'package:listbook/screen/landing_page.dart';
import 'package:listbook/screen/login_page.dart';
import 'package:listbook/screen/signup_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/instance.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInApple {
  late Server _server;

  SignInApple(BuildContext context) {
    _server = Server(context);
  }

  final storage = Instance.getInstanceStorage();

  Future<UserCredential?> _signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LandingPage(),
          ),
        );
      });
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (e) {
      Future.delayed(Duration.zero, () {
        failedLogin(context, null);
      });
      return null;
    }
  }

  signInWithApple(BuildContext context) async {
    final credential = await _signInWithApple(context);

    final idToken = await credential?.user?.getIdToken();
    print(idToken);

    bool isSignUp = false;
    bool isFail = false;

    try {
      final response = await _server.checkSignup(idToken);
      print(response.statusCode);

      if (response.statusCode == 200) {
        isSignUp = true;
      } else {
        isSignUp = false;
        isFail = true;
      }
    } catch (e) {
      if (e.runtimeType == DioException) {
        final error = e as DioException;

        print(error);
        print(error.response?.data['status']);

        if (error.response?.data['status'] == 409) {
          isSignUp = false;
        }
      } else {
        isFail = true;
      }
    }

    print(isSignUp);

    if (isSignUp) {
      print(idToken);
      await _server.signIn(idToken, context).then((value) async {
        print(value.data);
        await storage.write(key: accessTokenKey, value: value.data['accessToken']);
        await storage.write(key: refreshTokenKey, value: value.data['refreshToken']);
        await storage.write(key: expireKey, value: value.data['expiredAt'].toString());

        Future.delayed(Duration.zero, () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        });
      }).catchError((err) {
        isFail = true;
        print(err);
      });
    } else {
      Future.delayed(Duration.zero, () async {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SignUpPage(
            idToken: idToken,
          ),
        ));
      });
    }

    if (isFail) {
      Future.delayed(Duration.zero, () {
        failedLogin(context, credential);
      });
      return;
    }
  }

  failedLogin(BuildContext context, dynamic credential) {
    showOkAlertDialog(
      context: context,
      title: "Failed To Login",
      message: "Sorry, Login failed try again",
    ).then(
      (value) {
        if (credential != null) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return FadeTransition(
                  opacity: animation.drive(tween),
                  child: child,
                );
              },
            ),
            (route) => false,
          );
        }
      },
    );
  }

  signOut() async {
    final account = await GoogleSignIn().signOut();
    print(account);
  }
}
