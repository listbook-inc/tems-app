import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/auth/signin_google.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/login/login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double? _containerHeight;
  late SignInGoogle _signInGoogle;

  logoutAllAccount() async {
    await _signInGoogle.signOut();
  }

  @override
  void initState() {
    _signInGoogle = SignInGoogle(context);
    logoutAllAccount();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _containerHeight = MediaQuery.of(context).size.height / 2;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: CustomColors.black,
      body: Stack(
        children: [
          Container(
            width: deviceWidth,
            padding: EdgeInsets.only(left: 18, right: 18, top: deviceHeight / 2 + 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          "Welcome to your\npersonal items\norganizer, Tems!",
                          textStyle: TextStyle(
                            color: CustomColors.grey3,
                            fontSize: 29,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            height: 1.2,
                          ),
                          cursor: "|",
                          speed: const Duration(
                            milliseconds: 80,
                          ),
                        ),
                      ],
                      isRepeatingAnimation: false,
                      pause: const Duration(milliseconds: 1000),
                      onTap: () {
                        print("Tab");
                      },
                    )
                  ],
                ),
                Column(
                  children: [
                    LoginButton(
                      assetsName: "assets/google.svg",
                      buttonText: "Google",
                      onClickButton: () async {
                        await _signInGoogle.signInWithGoogle(
                          context,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    LoginButton(
                      assetsName: "assets/apple_white.svg",
                      buttonText: "Apple",
                      onClickButton: () {},
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "CONSENT TO USE THE SERVICE",
                        style: TextStyle(
                          fontFamily: "NeueMontreal",
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.accentGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: AnimatedContainer(
              height: _containerHeight ?? deviceHeight,
              width: deviceWidth,
              decoration: BoxDecoration(
                color: CustomColors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: SvgPicture.asset('assets/tems_black.svg'),
            ),
          )
        ],
      ),
    );
  }
}
