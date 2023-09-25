import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/server/server.dart';
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

  Future<void> getDatas() async {
    await _server.getMyProfile().then((value) {
      context.read<HomePageProvider>().setUser(value.data);
      print(value.data);
    }).catchError((err) {
      final error = err as DioException;
      print(error);
    });

    await _server.getMyMainBucket().then((value) {
      context.read<HomePageProvider>().setMainBuckets(value.data);
      print(value.data);
    }).catchError((err) {
      // final error = err as DioException;
      // print(error);
      print(err);
    });
  }

  refresh() async {
    await getDatas();
  }

  @override
  void initState() {
    _server = Server(context);
    getDatas().then((value) => FlutterNativeSplash.remove());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.white,
      body: PageView(
        controller: _controller,
        children: [
          MainPage(
            refresh: refresh,
          ),
          const HistoryPage(),
          const SearchPage(),
          ProfilePage(refresh: refresh),
        ],
      ),
      bottomNavigationBar: Container(
        height: 96,
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
              _controller.animateToPage(
                value,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            iconSize: 28,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: CustomColors.accentGreen,
            unselectedItemColor: Colors.black,
            selectedLabelStyle: const TextStyle(
              fontFamily: "NeueMontreal",
              fontWeight: FontWeight.w400,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: "NeueMontreal",
              fontWeight: FontWeight.w400,
            ),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: [
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
                label: "Home",
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
                label: "History",
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
                label: "Search",
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
                              "$s3URL${context.read<HomePageProvider>().user['userFolder']}/${context.read<HomePageProvider>().user['profileThumbnail']}",
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
