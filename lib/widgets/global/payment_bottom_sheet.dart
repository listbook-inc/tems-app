import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/utils/colors.dart';

class PaymentBottomSheet extends StatefulWidget {
  const PaymentBottomSheet({super.key});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String _trial = "yearly";

  void selectTrial(String trial) {
    setState(() {
      _trial = trial;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.only(left: 18.78, right: 18.78, top: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  "assets/tems_white.svg",
                  width: 103,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "지금 무료 체험을 시작하면 ㅇㅇㅇ\n혜택을 이용하실 수 있습니다.",
                  style: TextStyle(
                    fontFamily: "NeueMontreal",
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.white,
                  ),
                )
              ],
            ),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.91),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            selectTrial("yearly");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Yearly",
                              style: TextStyle(
                                color: _trial == "yearly" ? CustomColors.white : CustomColors.grey3,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            selectTrial("monthly");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Monthly",
                              style: TextStyle(
                                color: _trial == "monthly" ? CustomColors.white : CustomColors.grey3,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (_trial == "yearly")
                    Container(
                      width: deviceWidth,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CustomColors.white,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "\$29 / only \$2.4 a month",
                            style: TextStyle(
                              color: CustomColors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                color: CustomColors.white,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                "추가 아이템 기록 가능",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: CustomColors.white,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                color: CustomColors.white,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                "카테고리 버킷 무한 생성",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: CustomColors.white,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  if (_trial == "monthly")
                    Container(
                      width: deviceWidth,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CustomColors.white,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "\$2.9 / Monthly",
                            style: TextStyle(
                              color: CustomColors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                color: CustomColors.white,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                "추가 아이템 기록 가능",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: CustomColors.white,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                color: CustomColors.white,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                "카테고리 버킷 무한 생성",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: CustomColors.white,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 70),
            Material(
              borderRadius: BorderRadius.circular(30),
              color: CustomColors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {},
                child: Container(
                  height: 53,
                  width: deviceWidth,
                  alignment: Alignment.center,
                  child: Text(
                    "Go to pro",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
