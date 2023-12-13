import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/tems_black.svg"),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: CustomColors.black,
              strokeWidth: 2,
            ),
            const SizedBox(height: 20),
            Text(
              "Processing Login",
              style: TextStyle(
                fontFamily: Translations.of(context)?.trans("font") ?? "NeueMontreal",
                fontSize: 16,
                color: CustomColors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
