import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/home/history_page.dart';
import 'package:listbook/widgets/home/main_page.dart';
import 'package:listbook/widgets/home/profile_page.dart';
import 'package:listbook/widgets/home/search_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Server _server;
  late HomePageProvider provider;

  @override
  void initState() {
    _server = Server(context);
    _loadData();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page!.round();
      });
    });
    super.initState();
  }

  Future<void> _loadData() async {
    provider = context.read<HomePageProvider>();
    try {
      final userProfile = await _server.getMyProfile();
      provider.setUser(userProfile.data);
      final mainBucket = await _server.getMyMainBucket();
      provider.setMainBuckets(mainBucket.data);
      FlutterNativeSplash.remove();
      _checkTrialReset();
    } catch (error) {
      Future.delayed(Duration.zero, () {
        showOkAlertDialog(
          context: context,
          title: "서버 연결 에러",
          message: "서버에 연결하는데 문제가 발생했습니다. 인터넷 연결을 확인해주세요.",
        );
      });
      FlutterNativeSplash.remove();
    }
  }

  void _checkTrialReset() {
    if (provider.user['failRenewSubs'] == true || provider.user['isFailRenewSubs'] == true) {
      showOkAlertDialog(
        context: context,
        title: "Trial Reset",
        message: provider.user['renewFailMessage'],
      ).then((_) async {
        await _server.okFailRenew();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<HomePageProvider>().user;
    return Scaffold(
      backgroundColor: CustomColors.white,
      body: PageView(
        controller: _controller,
        children: [
          MainPage(refresh: _loadData),
          HistoryPage(refresh: _loadData),
          SearchPage(refresh: _loadData),
          ProfilePage(refresh: _loadData),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(user),
    );
  }

  Widget _buildBottomNavBar(Map user) {
    return Container(
      height: Platform.isAndroid ? 70 : 96,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(141, 141, 141, 0.17),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          backgroundColor: CustomColors.white,
          currentIndex: _currentPage,
          onTap: (value) {
            setState(() {
              _currentPage = value;
            });
            _controller.jumpToPage(
              value,
            );
            context.read<HomePageProvider>().setIsWelcome(false);
          },
          iconSize: 28,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: CustomColors.accentGreen,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: TextStyle(
            fontFamily: Translations.of(context)?.trans("font") ?? "NeueMontreal",
            fontWeight: FontWeight.w400,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: Translations.of(context)?.trans("font") ?? "NeueMontreal",
            fontWeight: FontWeight.w400,
          ),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: _buildBottomNavBarItems(user),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems(Map user) {
    return [
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: SvgPicture.asset("assets/home.svg"),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: SvgPicture.asset(
            "assets/home.svg",
            color: CustomColors.accentGreen,
          ),
        ),
        label: Translations.of(context)?.trans("home") ?? "Home",
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: SvgPicture.asset("assets/note-list.svg"),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: SvgPicture.asset(
            "assets/note-list.svg",
            color: CustomColors.accentGreen,
          ),
        ),
        label: Translations.of(context)?.trans("history") ?? "History",
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: SvgPicture.asset("assets/search.svg"),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: SvgPicture.asset(
            "assets/search.svg",
            color: CustomColors.accentGreen,
          ),
        ),
        label: Translations.of(context)?.trans("search") ?? "Search",
      ),
      BottomNavigationBarItem(
        icon: Container(
          width: 33,
          height: 33,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: context.read<HomePageProvider>().user['profileThumbnail'] == null ||
                    context.read<HomePageProvider>().user['profileThumbnail'] == "" ||
                    context.read<HomePageProvider>().user['profileType'] == "DEFAULT"
                ? const DecorationImage(
                    image: AssetImage("assets/defaultProfile.png"),
                  )
                : DecorationImage(
                    image: NetworkImage(
                      "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().user['profileThumbnail']}",
                    ),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        label: Translations.of(context)?.trans("profile") ?? "Profile",
      ),
    ];
  }
}
