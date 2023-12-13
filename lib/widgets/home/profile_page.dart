import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/item_management_page.dart';
import 'package:listbook/screen/item_register_log_page.dart';
import 'package:listbook/screen/profile_setting_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/ios_device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      _appVersion = "${info.version}(${info.buildNumber})";
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
        backgroundColor: CustomColors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          Row(
            children: [
              Material(
                color: CustomColors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettingPage(refresh: widget.refresh),
                      ),
                    ).then((value) {
                      widget.refresh();
                    });
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
        child: SingleChildScrollView(
          child: SizedBox(
            width: deviceWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                Material(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () async {
                      ImageProvider src;
                      if (context.read<HomePageProvider>().user['profileType'] != 'DEFAULT') {
                        src = Image.network(
                                "$s3URL${context.read<HomePageProvider>().user['userFolder']}/${context.read<HomePageProvider>().user['profileImage']}")
                            .image;
                      } else {
                        src = Image.asset("assets/defaultProfile.png").image;
                      }

                      await showImageViewer(
                        context,
                        src,
                        doubleTapZoomable: true,
                      );
                    },
                    child: Container(
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
                                  "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().user['profileThumbnail']}",
                                ),
                                fit: BoxFit.cover,
                              ),
                      ),
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
                          builder: (context) => ItemManagementPage(
                            refresh: widget.refresh,
                          ),
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
                        "${Translations.of(context)?.trans("total")}${context.watch<HomePageProvider>().user['totalItems']}${context.watch<HomePageProvider>().user['totalItems'] <= 1 ? Translations.of(context)?.trans("total_items") : Translations.of(context)?.trans("total_item")}",
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ItemRegisterLogPage(),
                        ),
                      );
                    },
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
                                Translations.of(context)?.trans("recent_items") ?? "",
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
                    onTap: () async {
                      const url = "https://listbook.com";

                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.white,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            width: MediaQuery.of(context).size.width - 40,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  Translations.of(context)?.trans("customer_service") ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  Translations.of(context)?.trans("customer_service_message") ??
                                      'Please send your inquiries to the email below',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xffa4a4a4),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBEBEB),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'dev@listbook.com',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFFA4A4A4),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            await Clipboard.setData(const ClipboardData(text: 'dev@listbook.com'));
                                            final data = await Fluttertoast.showToast(
                                              msg: "이메일 복사되었습니다!",
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: const Color(0xFFA4A4A4),
                                              textColor: const Color(0xFF000000),
                                              fontSize: 16,
                                              toastLength: Toast.LENGTH_SHORT,
                                            );

                                            if (data != null && data) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: const Icon(
                                            Icons.copy,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Material(
                                  borderRadius: BorderRadius.circular(16),
                                  color: CustomColors.accentGreen,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () async {
                                      // if (await canLaunchUrlString(url)) {
                                      //   await launchUrlString(url);
                                      // }

                                      final packageInfo = await PackageInfo.fromPlatform();

                                      String body = "";

                                      body += "==========================\n";
                                      body += "${Translations.of(context)?.trans("email_content")}\n";
                                      body +=
                                          "${packageInfo.appName} ${Translations.of(context)?.trans("version_key")} : ${packageInfo.version}(${packageInfo.buildNumber}\n";
                                      body +=
                                          "${Translations.of(context)?.trans("user_info_key")} : ${context.read<HomePageProvider>().user['nickname']}\n";

                                      final deviceInfo = DeviceInfoPlugin();

                                      if (Platform.isAndroid) {
                                        final android = await deviceInfo.androidInfo;
                                        body +=
                                            "${Translations.of(context)?.trans("device_info_key")} : ${android.manufacturer} ${android.model}\n";
                                        body +=
                                            "${Translations.of(context)?.trans("os_info_key")} : Android ${android.version.release} (SDK ${android.version.sdkInt})\n";
                                      } else {
                                        final iOS = await deviceInfo.iosInfo;
                                        body +=
                                            "${Translations.of(context)?.trans("device_info_key")} : ${lookup(iOS.utsname.machine)}\n";
                                        body +=
                                            "${Translations.of(context)?.trans("os_info_key")} : ${iOS.systemName} ${iOS.systemVersion}\n";
                                      }
                                      body += "==========================\n\n";

                                      body += "${Translations.of(context)?.trans("email_content2")}\n\n";

                                      body += "==========================\n";

                                      final email = Email(
                                        recipients: ['dev@listbook.com'],
                                        body: body,
                                        subject: 'TEMS Customer Service',
                                        cc: [],
                                        bcc: [],
                                        attachmentPaths: [],
                                        isHTML: false,
                                      );

                                      print(email);

                                      try {
                                        await FlutterEmailSender.send(email);
                                      } catch (e) {
                                        if (Platform.isAndroid) {
                                          showOkAlertDialog(
                                            context: context,
                                            title: "이메일 전송 실패",
                                            message: "이메일을 보내시려면 Gmail 앱의 계정 연동을 확인해주세요.",
                                          );
                                        } else {
                                          showOkAlertDialog(
                                            context: context,
                                            title: "이메일 전송 실패",
                                            message: "이메일을 보내시려면 iOS 기본 메일 앱의 계정 연동을 확인해주세요.",
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 80,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        Translations.of(context)?.trans("go_to_website") ?? 'Go to Website',
                                        style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 17,
                                          color: CustomColors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
                                Translations.of(context)?.trans("customer_service") ?? "",
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
                    onTap: () async {
                      const url =
                          "https://same-bun-b05.notion.site/c0579c5412044d2994a3388c4b19e4a4?v=36f1d0a15a064feba5fc191b1d03501e&pvs=4";
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      }
                    },
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
                                Translations.of(context)?.trans("notice") ?? "Notice",
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
                    onTap: () async {
                      const url =
                          "https://same-bun-b05.notion.site/Terms-of-Service_TEMS-36156882478d4539ae37e20ded5bf4dc?pvs=4";

                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      }
                    },
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
                                Translations.of(context)?.trans("terms_and_conditions") ?? "",
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
                    onTap: () async {
                      const url =
                          "https://same-bun-b05.notion.site/Privacy-Policy_TEMS-661d3b6d830a4cd0abd595ea4590448b?pvs=4";

                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      }
                    },
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
                                Translations.of(context)?.trans("privacy_policy") ?? "Privacy Policy",
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
                    onTap: () async {
                      const url =
                          "https://same-bun-b05.notion.site/End-User-License-Agreement-EULA-042d2ab278f049ce836a0f7d74876e1a?pvs=4";

                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      }
                    },
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
                                Translations.of(context)?.trans("eula") ?? "EULA",
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
                  "${Translations.of(context)?.trans("version")} $_appVersion",
                  style: TextStyle(
                    fontSize: 12,
                    color: CustomColors.grey2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
