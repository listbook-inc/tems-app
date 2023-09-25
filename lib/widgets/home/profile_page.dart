import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/item_management_page.dart';
import 'package:listbook/screen/profile_setting_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/colors.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final Function() refresh;

  const ProfilePage({super.key, required this.refresh});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _appVersion = '1.0.0';

  getVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  @override
  void initState() {
    getVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: AppBar(
        actions: [
          Row(
            children: [
              Material(
                color: CustomColors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettingPage(refresh: widget.refresh),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    "assets/settings.svg",
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16)
            ],
          )
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: deviceWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(76),
                  border: Border.all(
                    color: CustomColors.accentGreen,
                    width: 1,
                  ),
                  image: context.watch<HomePageProvider>().user['profileType'] == 'DEFAULT'
                      ? const DecorationImage(
                          image: AssetImage("assets/defaultProfile.png"),
                        )
                      : DecorationImage(
                          image: NetworkImage(
                            "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().user['profileImage']}",
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.watch<HomePageProvider>().user['nickname'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.darkGrey,
                ),
              ),
              Text(
                context.watch<HomePageProvider>().user['email'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: CustomColors.grey3,
                ),
              ),
              const SizedBox(height: 15),
              Material(
                color: CustomColors.black,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ItemManagementPage(),
                      ),
                    );
                  },
                  child: Container(
                    height: 25,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Total : ${context.watch<HomePageProvider>().user['totalItems']} items",
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    width: deviceWidth,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: CustomColors.lightGrey,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: CustomColors.lightGrey,
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset("assets/note-list.svg"),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "List of items",
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        Icon(
                          CupertinoIcons.forward,
                          color: CustomColors.grey2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    width: deviceWidth,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: CustomColors.lightGrey,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: CustomColors.lightGrey,
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset("assets/users-group-alt.svg"),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "Customer Service",
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        Icon(
                          CupertinoIcons.forward,
                          color: CustomColors.grey2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    width: deviceWidth,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: CustomColors.lightGrey,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: CustomColors.lightGrey,
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset("assets/envelope-notification.svg"),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "Notification",
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        Icon(
                          CupertinoIcons.forward,
                          color: CustomColors.grey2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    width: deviceWidth,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: CustomColors.lightGrey,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: CustomColors.lightGrey,
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset("assets/document.svg"),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "Terms and Conditions",
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        Icon(
                          CupertinoIcons.forward,
                          color: CustomColors.grey2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Version $_appVersion",
                style: TextStyle(
                  fontSize: 12,
                  color: CustomColors.grey2,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
