import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/login_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/image_compress.dart';
import 'package:listbook/utils/instance.dart';
import 'package:listbook/widgets/home/profile_page/photo_edit_bottom_sheet.dart';
import 'package:provider/provider.dart';

class ProfileSettingPage extends StatefulWidget {
  final Function() refresh;

  const ProfileSettingPage({super.key, required this.refresh});

  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  FocusNode nicknameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  bool _isLoading = false;

  late Server _server;

  @override
  void initState() {
    super.initState();
    String nickname = "${context.read<HomePageProvider>().user['nickname']}";
    String email = "${context.read<HomePageProvider>().user['email']}";

    _nicknameController.text = nickname;
    _emailController.text = email;

    _server = Server(context);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: AppBar(
        title: Text(
          "My account",
          style: TextStyle(
            fontSize: 26,
            color: CustomColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: deviceWidth,
            height: safeAreaHeight,
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 15),
                    Stack(
                      children: [
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
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            color: CustomColors.lightGrey,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: CustomColors.white,
                                  context: context,
                                  builder: (context) {
                                    return PhotoEditBottomSheet(
                                      onClickAlbum: () async {
                                        XFile? file =
                                            await ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
                                          Navigator.pop(context);
                                          return value;
                                          // ignore: body_might_complete_normally_catch_error
                                        }).catchError((err) {
                                          Navigator.pop(context);
                                        });
                                        print(file);

                                        setState(() {
                                          _isLoading = true;
                                        });

                                        try {
                                          final dto = await compress(file);
                                          print(dto.toString());

                                          if (dto == null) {
                                            throw Exception();
                                          }

                                          File profileImage = File(dto.image);
                                          File thumbnailImage = File(dto.thumbnail);

                                          print(profileImage);
                                          print(thumbnailImage);

                                          FormData formData = FormData.fromMap({
                                            "profileImage": await MultipartFile.fromFile(profileImage.path,
                                                filename: profileImage.path.split("/").last),
                                            "thumbnailImage": await MultipartFile.fromFile(thumbnailImage.path,
                                                filename: thumbnailImage.path.split("/").last),
                                            "isDelete": false,
                                          });

                                          print(formData.fields);

                                          await _server.updateProfile(formData);

                                          if (await profileImage.exists()) {
                                            await profileImage.delete();
                                          }

                                          if (await thumbnailImage.exists()) {
                                            await thumbnailImage.delete();
                                          }
                                        } catch (e) {
                                          // print(e);
                                          Future.delayed(Duration.zero, () {
                                            showOkAlertDialog(
                                              context: context,
                                              title: "Upload Failed",
                                              message: "Sorry, Profile upload failed..",
                                            );
                                          });
                                        }

                                        await widget.refresh();

                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                      onClickTakePhoto: () async {
                                        XFile? file;

                                        try {
                                          file =
                                              await ImagePicker().pickImage(source: ImageSource.camera).then((value) {
                                            Navigator.pop(context);
                                            return value;
                                            // ignore: body_might_complete_normally_catch_error
                                          }).catchError((err) {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            Navigator.pop(context);
                                          });
                                        } catch (e) {
                                          print(e);
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                        print(file);

                                        setState(() {
                                          _isLoading = true;
                                        });

                                        try {
                                          final dto = await compress(file);
                                          print(dto.toString());

                                          if (dto == null) {
                                            throw Exception();
                                          }

                                          File profileImage = File(dto.image);
                                          File thumbnailImage = File(dto.thumbnail);

                                          print(profileImage);
                                          print(thumbnailImage);

                                          FormData formData = FormData.fromMap({
                                            "profileImage": await MultipartFile.fromFile(profileImage.path,
                                                filename: profileImage.path.split("/").last),
                                            "thumbnailImage": await MultipartFile.fromFile(thumbnailImage.path,
                                                filename: thumbnailImage.path.split("/").last),
                                            "isDelete": false,
                                          });

                                          print(formData.fields);

                                          await _server.updateProfile(formData);
                                        } catch (e) {
                                          // print(e);
                                          Future.delayed(Duration.zero, () {
                                            showOkAlertDialog(
                                              context: context,
                                              title: "Upload Failed",
                                              message: "Sorry, Profile upload failed..",
                                            );
                                          });
                                        }
                                      },
                                      onClickDeletePhoto: () async {
                                        FormData formData = FormData.fromMap({
                                          "profileImage": null,
                                          "profileThumbnail": null,
                                          "isDelete": true,
                                        });

                                        try {
                                          await _server.updateProfile(formData);

                                          Navigator.pop(context);
                                        } catch (e) {
                                          Future.delayed(Duration.zero, () {
                                            Navigator.pop(context);
                                            showOkAlertDialog(
                                              context: context,
                                              title: "Upload Failed",
                                              message: "Sorry, Profile upload failed..",
                                            );
                                          });
                                        }

                                        await widget.refresh();

                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/camera.svg",
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 34),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              "Name",
                              style: TextStyle(
                                fontSize: 15,
                                color: CustomColors.grey3,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 53,
                          width: deviceWidth - 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: CustomColors.lightGrey,
                          ),
                          child: TextField(
                            onTapOutside: (value) {
                              nicknameFocus.unfocus();
                            },
                            onChanged: (value) {
                              print(value);
                            },
                            controller: _nicknameController,
                            focusNode: nicknameFocus,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Nickname",
                              hintStyle: TextStyle(
                                fontSize: 17,
                                color: CustomColors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 23,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              "E-mail",
                              style: TextStyle(
                                fontSize: 15,
                                color: CustomColors.grey3,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 53,
                          width: deviceWidth - 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: CustomColors.lightGrey,
                          ),
                          child: TextField(
                            controller: _emailController,
                            focusNode: emailFocus,
                            onTapOutside: (value) {
                              emailFocus.unfocus();
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "E-mail",
                              hintStyle: TextStyle(
                                fontSize: 17,
                                color: CustomColors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 23,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 69,
                  child: Material(
                    color: CustomColors.black,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () async {
                        final storage = Instance.getInstanceStorage();
                        await _server.signOut();
                        await storage.deleteAll();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        alignment: Alignment.center,
                        height: 53,
                        child: Text(
                          "Sign out",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: Material(
                    color: CustomColors.white,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        alignment: Alignment.center,
                        height: 53,
                        child: Text(
                          "Delete your account",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.lightRed,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: CustomColors.black,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
