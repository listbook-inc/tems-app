import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/bucket_page.dart';
import 'package:listbook/screen/new_bucket_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/global/payment_bottom_sheet.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class AnimatedCardView extends StatefulWidget {
  final int i;
  final Function() refresh;
  final ScrollController controller;
  final int selectIdx;
  final Function(int index) setSelectIdx;
  final double scrollHeight;
  final double safeAreaHeight;

  const AnimatedCardView({
    super.key,
    required this.i,
    required this.refresh,
    required this.controller,
    required this.selectIdx,
    required this.setSelectIdx,
    required this.scrollHeight,
    required this.safeAreaHeight,
  });

  @override
  State<AnimatedCardView> createState() => _AnimatedCardViewState();
}

class _AnimatedCardViewState extends State<AnimatedCardView> {
  double _height = 192;
  late Server _server;
  Offset? _dragStartOffset;
  final bool _ignore = false;
  bool isScroll = true;

  final localAuth = LocalAuthentication();

  onClick(bool isDown) {
    if (context.read<HomePageProvider>().mainPageBucket.length != widget.i) {
      if (bool.parse(context.read<HomePageProvider>().mainPageBucket[widget.i]['isDisabled'].toString())) {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: CustomColors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          context: context,
          builder: (context) {
            return PaymentBottomSheet(
              refresh: widget.refresh,
              redirect: "BUCKET",
              redirectMethod: null,
            );
          },
        );

        return;
      }
    }

    setState(() {
      if (!isDown) {
        setState(() {
          isScroll = false;
        });
        _height = 356.36;
      } else {
        _height = 192;
        setState(() {
          isScroll = true;
        });
      }
    });
  }

  onTap() async {
    if (bool.parse(
        (context.read<HomePageProvider>().mainPageBucket[widget.i]['isSecurityFolder'] ?? "false").toString())) {
      print(await localAuth.canCheckBiometrics);
      if (!await localAuth.canCheckBiometrics) {
        showOkAlertDialog(
          context: context,
          title: "Auth faild",
          message: "Not available biometric authentication",
        );
        return;
      }

      final authentication = await localAuth.authenticate(
        localizedReason: "Please authenticate to show account balance",
      );

      print(authentication);

      if (authentication) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BucketPage(
              bucket: context.watch<HomePageProvider>().mainPageBucket[widget.i],
              refresh: widget.refresh,
            ),
          ),
        );
      }

      return;
    }

    if (context.read<HomePageProvider>().mainPageBucket.length != widget.i) {
      if (bool.parse(context.read<HomePageProvider>().mainPageBucket[widget.i]['isDisabled'].toString())) {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: CustomColors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          context: context,
          builder: (context) {
            return PaymentBottomSheet(
              refresh: widget.refresh,
              redirect: "BUCKET",
              redirectMethod: null,
            );
          },
        );

        return;
      }
    }
    setState(() {
      print(widget.i);
      if (_height == 192) {
        setState(() {
          isScroll = false;
        });
        widget.setSelectIdx(widget.i);
        // widget.controller.jumpTo(widget.controller.offset);
        // print(widget.i);

        // print("widget.controller.offset");
        // print((widget.scrollHeight - widget.safeAreaHeight) / 2);

        var scrollTo = (192 * 0.58) +
            15 +
            (192 * 0.42) * ((context.read<HomePageProvider>().mainPageBucket.length - 3) - widget.i);

        if (scrollTo < 0) {
          scrollTo = 0;
        } else if ((widget.scrollHeight - widget.safeAreaHeight - 1) < scrollTo) {
          scrollTo = widget.scrollHeight - widget.safeAreaHeight - 1;
        }

        if (context.read<HomePageProvider>().mainPageBucket[widget.i]['allItems'].length > 0) {
          _height = 356.36;
        } else {
          _height = 244;
        }

        print("=========SCROLL_TO=========");
        print(widget.controller.offset);
        print(scrollTo);
        print(widget.scrollHeight - widget.safeAreaHeight);
        print("=========SCROLL_TO=========");

        widget.controller.animateTo(
          scrollTo,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        widget.setSelectIdx(-1);
        _height = 192;
        setState(() {
          isScroll = true;
        });
      }
    });
  }

  @override
  void initState() {
    _server = Server(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    if (widget.i != widget.selectIdx) {
      setState(() {
        _height = 192;
      });
    }

    return IgnorePointer(
      ignoring: _ignore,
      child: GestureDetector(
        onTap: () {
          if (context.read<HomePageProvider>().mainPageBucket.length != widget.i) {
            widget.setSelectIdx(widget.i);
            onTap();
          }
          // if (Platform.isIOS) {
          //   widget.refresh();
          // }
        },
        onVerticalDragStart: (details) {
          if (!isScroll) {
            _dragStartOffset = details.localPosition;
          }
          // if (Platform.isIOS) {
          //   widget.refresh();
          // }
        },
        onVerticalDragUpdate: (details) {
          if (_dragStartOffset != null) {
            if (details.localPosition.dy - _dragStartOffset!.dy > 10) {
              if (context.read<HomePageProvider>().mainPageBucket.length != widget.i) {
                onClick(true);
                // if (Platform.isIOS) {
                //   widget.refresh();
                // }
              }
              Future.delayed(const Duration(milliseconds: 80), () {
                _dragStartOffset = null;
              });
            } else {
              _dragStartOffset = null;
            }
            print("====start====");
            print(_dragStartOffset?.dy);
            print("====start====");
            print("====end====");
            print(details.localPosition.dy);
            print("====end====");
          } else {
            if (widget.controller.position.maxScrollExtent >= widget.controller.offset + details.delta.dy &&
                widget.controller.offset >= 0) {
              widget.controller.jumpTo(widget.controller.offset + details.delta.dy);
              // HapticFeedback.lightImpact();
            }
          }
        },
        child: Stack(
          children: [
            AnimatedContainer(
              width: deviceWidth - 32,
              height: _height,
              padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                  ? BoxDecoration(
                      color: const Color(0xFF121212),
                      border: Border.all(
                        color: const Color(0xFFF2F2F7),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    )
                  : BoxDecoration(
                      color: Color(
                        int.parse(
                          "FF${context.watch<HomePageProvider>().mainPageBucket[widget.i]['color']}",
                          radix: 16,
                        ),
                      ),
                      border: Border.all(
                        color: CustomColors.white,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.only(top: 34),
                      // color: CustomColors.accentGreen,
                      child: context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Translations.of(context)?.trans("add_bucket") ?? "error",
                                  style: TextStyle(
                                    fontFamily: Translations.of(context)?.trans("point_font"),
                                    color: CustomColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () async {
                                      if (context.read<HomePageProvider>().mainPageBucket.length >= 3) {
                                        await _server.checkTrial().then((value) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NewBucketPage(
                                                refresh: widget.refresh,
                                              ),
                                            ),
                                          );
                                        }).catchError((err) {
                                          print(err);
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: CustomColors.black,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                topRight: Radius.circular(20.0),
                                              ),
                                            ),
                                            context: context,
                                            builder: (context) {
                                              return PaymentBottomSheet(
                                                refresh: widget.refresh,
                                                redirect: "BUCKET",
                                                redirectMethod: null,
                                              );
                                            },
                                          );
                                        });

                                        // showDialog(
                                        //   context: context,
                                        //   builder: (context) => MaxBucketDialog(
                                        //     onSuccess: () async {},
                                        //     message: "Cannot Add More 3 Buckets",
                                        //   ),
                                        // );
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NewBucketPage(
                                            refresh: widget.refresh,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: CustomColors.accentGreen,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.add,
                                        color: CustomColors.accentGreen,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (bool.parse((context.read<HomePageProvider>().mainPageBucket[widget.i]
                                                ['isSecurityFolder'] ??
                                            "false")
                                        .toString()))
                                      SvgPicture.asset("assets/key.fill.svg"),
                                    Text(
                                      context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketName'],
                                      style: TextStyle(
                                        fontFamily: Translations.of(context)?.trans("point_font"),
                                        color: CustomColors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (context.watch<HomePageProvider>().mainPageBucket.length != widget.i)
                                      if (bool.parse(context
                                          .watch<HomePageProvider>()
                                          .mainPageBucket[widget.i]['isDisabled']
                                          .toString()))
                                        const Icon(
                                          CupertinoIcons.lock_circle_fill,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${context.watch<HomePageProvider>().mainPageBucket[widget.i]['totalItems']} ${context.watch<HomePageProvider>().mainPageBucket[widget.i]['totalItems'] == 1 ? Translations.of(context)?.trans("item") ?? 'Item' : Translations.of(context)?.trans("items") ?? 'Items'}",
                                      style: TextStyle(
                                        color: CustomColors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_height > 192 && context.watch<HomePageProvider>().mainPageBucket[widget.i]['totalItems'] == 0)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BucketPage(
                              bucket: context.watch<HomePageProvider>().mainPageBucket[widget.i],
                              refresh: widget.refresh,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 13),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 66,
                            color: context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                                ? const Color(0xFF121212)
                                : Color(
                                    int.parse(
                                      "FF${context.watch<HomePageProvider>().mainPageBucket[widget.i]['color']}",
                                      radix: 16,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  if (_height > 192 && context.watch<HomePageProvider>().mainPageBucket[widget.i]['totalItems'] > 0)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BucketPage(
                              bucket: context.watch<HomePageProvider>().mainPageBucket[widget.i],
                              refresh: widget.refresh,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 13),
                          Container(
                            width: deviceWidth,
                            height: 66,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: CustomColors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF39F21B),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      Translations.of(context)?.trans("status_active") ?? "Status Active",
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: CustomColors.darkGrey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${context.watch<HomePageProvider>().mainPageBucket[widget.i]['activeItems']}",
                                        style: TextStyle(
                                          color: CustomColors.darkGrey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17,
                                        ),
                                      ),
                                      TextSpan(
                                        text: context.watch<HomePageProvider>().mainPageBucket[widget.i]
                                                    ['activeItems'] ==
                                                1
                                            ? " ${Translations.of(context)?.trans("item")}"
                                            : " ${Translations.of(context)?.trans("items")}",
                                        style: TextStyle(
                                          color: CustomColors.darkGrey,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'].length == 0
                              ? Container(
                                  width: deviceWidth - 32 - 32,
                                  height: (deviceWidth - 32 - 42 - 32) / 4,
                                  alignment: Alignment.center,
                                  child: Text(
                                    Translations.of(context)?.trans("no_active_items") ?? "No Active Items",
                                    style: TextStyle(
                                      color: CustomColors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Color(
                                    int.parse(
                                      "FF${context.watch<HomePageProvider>().mainPageBucket[widget.i]['color']}",
                                      radix: 16,
                                    ),
                                  ),
                                  width: deviceWidth - 32 - 32,
                                  height: (deviceWidth - 32 - 42 - 32) / 4,
                                  child: Row(
                                    children: [
                                      if (context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'].length >
                                          0)
                                        Stack(
                                          children: [
                                            Container(
                                              width: (deviceWidth - 32 - 42 - 32) / 4,
                                              height: (deviceWidth - 32 - 42 - 32) / 4,
                                              decoration: BoxDecoration(
                                                color: CustomColors.white,
                                                borderRadius: BorderRadius.circular(9.2),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][0]['itemFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][0]['thumbnailImage']}"),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][0]
                                                    ['isActive']
                                                ? Positioned(
                                                    top: 5,
                                                    right: 5,
                                                    child: Container(
                                                      width: 14,
                                                      height: 14,
                                                      decoration: BoxDecoration(
                                                        color: CustomColors.accentGreen,
                                                        border: Border.all(
                                                          width: 1,
                                                          color: CustomColors.white,
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  )
                                                : Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    left: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: CustomColors.black.withAlpha(85),
                                                        borderRadius: BorderRadius.circular(9.2),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                      const SizedBox(width: 13),
                                      if (context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'].length >
                                          1)
                                        Stack(
                                          children: [
                                            Container(
                                              width: (deviceWidth - 32 - 42 - 32) / 4,
                                              height: (deviceWidth - 32 - 42 - 32) / 4,
                                              decoration: BoxDecoration(
                                                color: CustomColors.white,
                                                borderRadius: BorderRadius.circular(9.2),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][1]['itemFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][1]['thumbnailImage']}",
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][1]
                                                    ['isActive']
                                                ? Positioned(
                                                    top: 5,
                                                    right: 5,
                                                    child: Container(
                                                      width: 14,
                                                      height: 14,
                                                      decoration: BoxDecoration(
                                                        color: CustomColors.accentGreen,
                                                        border: Border.all(
                                                          width: 1,
                                                          color: CustomColors.white,
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  )
                                                : Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    left: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: CustomColors.black.withAlpha(85),
                                                        borderRadius: BorderRadius.circular(9.2),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                      const SizedBox(width: 14),
                                      if (context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'].length >
                                          2)
                                        Stack(
                                          children: [
                                            Container(
                                              width: (deviceWidth - 32 - 42 - 32) / 4,
                                              height: (deviceWidth - 32 - 42 - 32) / 4,
                                              decoration: BoxDecoration(
                                                color: CustomColors.white,
                                                borderRadius: BorderRadius.circular(9.2),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][2]['itemFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][2]['thumbnailImage']}"),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][2]
                                                    ['isActive']
                                                ? Positioned(
                                                    top: 5,
                                                    right: 5,
                                                    child: Container(
                                                      width: 14,
                                                      height: 14,
                                                      decoration: BoxDecoration(
                                                        color: CustomColors.accentGreen,
                                                        border: Border.all(
                                                          width: 1,
                                                          color: CustomColors.white,
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  )
                                                : Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    left: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: CustomColors.black.withAlpha(85),
                                                        borderRadius: BorderRadius.circular(9.2),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                      const SizedBox(width: 13),
                                      if (context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'].length >
                                          3)
                                        Stack(
                                          children: [
                                            Container(
                                              width: (deviceWidth - 32 - 42 - 32) / 4,
                                              height: (deviceWidth - 32 - 42 - 32) / 4,
                                              decoration: BoxDecoration(
                                                color: CustomColors.white,
                                                borderRadius: BorderRadius.circular(9.2),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][3]['itemFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][3]['thumbnailImage']}"),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][3]
                                                    ['isActive']
                                                ? Positioned(
                                                    top: 5,
                                                    right: 5,
                                                    child: Container(
                                                      width: 14,
                                                      height: 14,
                                                      decoration: BoxDecoration(
                                                        color: CustomColors.accentGreen,
                                                        border: Border.all(
                                                          width: 1,
                                                          color: CustomColors.white,
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  )
                                                : Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    left: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: CustomColors.black.withAlpha(85),
                                                        borderRadius: BorderRadius.circular(9.2),
                                                      ),
                                                    ),
                                                  ),
                                            if (context.watch<HomePageProvider>().mainPageBucket[widget.i]
                                                    ['activeItems'] >
                                                4)
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    // Gradient
                                                    borderRadius: BorderRadius.circular(9.2),
                                                    gradient: const LinearGradient(
                                                      begin: Alignment
                                                          .topCenter, // 0deg in CSS corresponds to top to bottom in Flutter
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Color.fromRGBO(0, 0, 0, 0.40),
                                                        Color.fromRGBO(0, 0, 0, 0.40),
                                                      ],
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "+${context.watch<HomePageProvider>().mainPageBucket[widget.i]['activeItems'] - 4}",
                                                    style: const TextStyle(
                                                      fontSize: 23,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
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
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: (deviceWidth - 104) / 2,
              left: (deviceWidth - 104) / 2,
              child: Transform.translate(
                offset: const Offset(0, -1),
                child: Container(
                  width: 104,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.i == 0
                        ? Colors.white
                        : _height > 244
                            ? Colors.white
                            : Color(
                                int.parse("FF${context.read<HomePageProvider>().mainPageBucket[widget.i - 1]["color"]}",
                                    radix: 16),
                              ),
                    border: const Border(
                      left: BorderSide(
                        color: Color(0xFFF2F2F7),
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Color(0xFFF2F2F7),
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: Color(0xFFF2F2F7),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, -1),
                    child: Container(
                      width: 37,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: (deviceWidth - 104) / 2 - 7,
              top: 3,
              child: Transform.rotate(
                angle: -37,
                child: Container(
                  width: 16,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(
                      context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                          ? 0xFF121212
                          : int.parse("FF${context.read<HomePageProvider>().mainPageBucket[widget.i]["color"]}",
                              radix: 16),
                    ),
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFFF2F2F7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: (deviceWidth - 104) / 2 - 7,
              top: 3,
              child: Transform.rotate(
                angle: 37,
                child: Container(
                  width: 16,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(
                      context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                          ? 0xFF121212
                          : int.parse("FF${context.read<HomePageProvider>().mainPageBucket[widget.i]["color"]}",
                              radix: 16),
                    ),
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFFF2F2F7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: (deviceWidth - 80) / 2,
              left: (deviceWidth - 80) / 2,
              top: 0,
              child: Transform.translate(
                offset: const Offset(0, -2),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Color(
                      context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                          ? 0xFFFFFFFF
                          : int.parse("FF${context.read<HomePageProvider>().mainPageBucket[widget.i]["color"]}",
                              radix: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
