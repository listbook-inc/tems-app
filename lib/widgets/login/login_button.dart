import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/utils/colors.dart';

class LoginButton extends StatefulWidget {
  final String assetsName;
  final String buttonText;
  final Function() onClickButton;

  const LoginButton({
    super.key,
    required this.assetsName,
    required this.buttonText,
    required this.onClickButton,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Material(
      borderRadius: BorderRadius.circular(28),
      color: CustomColors.darkGrey,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          widget.onClickButton();
        },
        child: Container(
          width: deviceWidth - 36,
          height: 53,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(widget.assetsName),
              const SizedBox(width: 10),
              Text(
                widget.buttonText,
                style: TextStyle(
                  fontFamily: "NeueMontreal",
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: CustomColors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
