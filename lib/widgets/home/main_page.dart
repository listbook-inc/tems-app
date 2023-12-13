import 'dart:io';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/edit_bucket_page.dart';
import 'package:listbook/screen/notification_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/home/main_page/animated_card_view.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final Function() refresh;

  const MainPage({super.key, required this.refresh});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _controller = ScrollController();
  late final Server _server;
  int selectIndex = -1;
  String welcomeMessage = "";

  void setSelectIndex(int idx) {
    setState(() => selectIndex = idx);
  }

  void getWelcomeMessage() async {
    try {
      final response = await _server.getWelcomeMessage();
      setState(() => welcomeMessage = response.data);
    } catch (err) {
      print("Error fetching welcome message: $err");
    }
  }

  @override
  void initState() {
    _server = Server(context);
    // _controller.addListener(() {
    //   print(_controller.offset);
    // });
    getWelcomeMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        (Platform.isAndroid ? 70 : 96);

    final scrollHeight =
        (context.watch<HomePageProvider>().mainPageBucket.length + 1) * (192 * 0.42) + 15 + (192 * 0.58) + 300;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 0.1),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 46,
                ),
                child: SingleChildScrollView(
                  controller: _controller,
                  reverse: true,
                  child: SizedBox(
                    height: scrollHeight < safeAreaHeight ? safeAreaHeight : scrollHeight,
                    child: Stack(
                      children: List.generate(
                        context.watch<HomePageProvider>().mainPageBucket.length + 1,
                        (i) => Positioned(
                          bottom: (context.watch<HomePageProvider>().mainPageBucket.length - i) * (192 * 0.42) + 15,
                          child: AnimatedCardView(
                            i: i,
                            refresh: widget.refresh,
                            controller: _controller,
                            selectIdx: selectIndex,
                            setSelectIdx: setSelectIndex,
                            scrollHeight: scrollHeight,
                            safeAreaHeight: safeAreaHeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (scrollHeight > safeAreaHeight)
                const Positioned(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.1984, 0.8748],
                          colors: [
                            Colors.white,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.topLeft,
                  color: context.watch<HomePageProvider>().isWelcome
                      ? const Color.fromRGBO(255, 255, 255, 0.1)
                      : Colors.white,
                  padding: EdgeInsets.only(
                    bottom: context.watch<HomePageProvider>().isWelcome ? 20 : 0,
                  ),
                  child: Column(
                    children: [
                      SafeArea(
                        child: SizedBox(
                          width: deviceWidth,
                          height: 46,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 20),
                                child: SvgPicture.asset(
                                  "assets/tems_black.svg",
                                  width: 72.2,
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const NotificationPage(),
                                          ),
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        "assets/bell.badge.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditBucketPage(
                                              deviceWidth: deviceWidth,
                                              refresh: widget.refresh,
                                            ),
                                          ),
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        "assets/edit.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (context.watch<HomePageProvider>().isWelcome)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 17),
                            Text(
                              "${Translations.of(context)?.trans('welcome_hello')}$welcomeMessage${Translations.of(context)?.trans("welcome_message")}",
                              style: TextStyle(
                                fontFamily: Translations.of(context)?.trans("point_font"),
                                color: CustomColors.black,
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 17),
                          ],
                        )
                    ],
                  ),
                ).frosted(
                  blur: context.watch<HomePageProvider>().isWelcome ? 10 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
