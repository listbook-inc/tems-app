import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listbook/screen/home_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class ItemDetailPage extends StatefulWidget {
  final String imageDir;
  final String thumbnailDir;
  final bool isRemove;
  final int bucketId;

  const ItemDetailPage({
    super.key,
    required this.imageDir,
    required this.thumbnailDir,
    required this.bucketId,
    required this.isRemove,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Server _server;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode brandFocus = FocusNode();
  FocusNode noteFocus = FocusNode();

  bool dailyUse = false;
  bool _isLoading = false;
  bool isPushAlarm = true;

  @override
  void initState() {
    _server = Server(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          Translations.of(context)?.trans("item_information_title") ?? "Item information",
          style: TextStyle(
            fontSize: 26,
            color: CustomColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 173,
                        height: 173,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: CustomColors.lightGrey,
                            width: 1,
                          ),
                          image: DecorationImage(
                            image: FileImage(
                              File(widget.thumbnailDir),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            Translations.of(context)?.trans("item_name") ?? "Name",
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
                            nameFocus.unfocus();
                          },
                          onChanged: (value) {
                            print(value);
                          },
                          controller: _nameController,
                          focusNode: nameFocus,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: Translations.of(context)?.trans("item_name") ?? "Item name",
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
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            Translations.of(context)?.trans("brand") ?? "Brand",
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
                            brandFocus.unfocus();
                          },
                          onChanged: (value) {
                            print(value);
                          },
                          controller: _brandController,
                          focusNode: brandFocus,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: Translations.of(context)?.trans("e_g_apple"),
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
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            Translations.of(context)?.trans("note") ?? "Note",
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
                        height: 90,
                        width: deviceWidth - 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomColors.lightGrey,
                        ),
                        child: TextField(
                          onTapOutside: (value) {
                            noteFocus.unfocus();
                          },
                          onChanged: (value) {
                            print(value);
                          },
                          controller: _noteController,
                          focusNode: noteFocus,
                          maxLength: 100,
                          maxLines: 2,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: Translations.of(context)?.trans("write_memo_it"),
                            hintStyle: TextStyle(
                              fontSize: 17,
                              color: CustomColors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: deviceWidth - 32,
                    height: 53,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: CustomColors.lightGrey,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Translations.of(context)?.trans("daily_use") ?? "Daily use",
                          style: TextStyle(
                            fontSize: 15,
                            color: CustomColors.darkGrey,
                          ),
                        ),
                        CupertinoSwitch(
                          value: dailyUse,
                          activeColor: CustomColors.black,
                          onChanged: (value) {
                            setState(() {
                              dailyUse = value;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          Translations.of(context)?.trans("toggle_alert_message") ??
                              "The number of daws in use is counted when the toggle is activated.",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: CustomColors.mediumGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: deviceWidth - 32,
                    height: 53,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: CustomColors.lightGrey,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Translations.of(context)?.trans("unused_item_notification") ?? "Unused Notifications",
                          style: TextStyle(
                            fontSize: 15,
                            color: CustomColors.darkGrey,
                          ),
                        ),
                        CupertinoSwitch(
                          value: isPushAlarm,
                          activeColor: CustomColors.black,
                          onChanged: (value) {
                            setState(() {
                              isPushAlarm = value;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          Translations.of(context)?.trans("unused_item_notification_message") ?? "",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: CustomColors.mediumGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 42),
                  Material(
                    borderRadius: BorderRadius.circular(30),
                    color: CustomColors.black,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        if (_nameController.text == "") {
                          showOkAlertDialog(
                            context: context,
                            title: "Faild Upload",
                            message: "Faild Item upload, please input item's name",
                          );
                          return;
                        }

                        File image = File(widget.imageDir);
                        File thumbnail = File(widget.thumbnailDir);

                        print(await image.exists());
                        print(await thumbnail.exists());

                        FormData formData = FormData.fromMap({
                          "itemImage": await MultipartFile.fromFile(
                            image.path,
                            filename: image.path.split("/").last,
                          ),
                          "itemThumbnail": await MultipartFile.fromFile(
                            thumbnail.path,
                            filename: thumbnail.path.split("/").last,
                          ),
                          "brand": _brandController.text,
                          "name": _nameController.text,
                          "note": _noteController.text,
                          "dailyUse": dailyUse,
                          "isRemove": widget.isRemove,
                          "isPushAlarm": isPushAlarm,
                        });

                        await _server.uploadItem(formData, widget.bucketId).then((value) async {
                          await image.delete();
                          await thumbnail.delete();
                          print("테스트");

                          Future.delayed(Duration.zero, () {
                            showOkAlertDialog(
                              context: context,
                              title: Translations.of(context)?.trans("upload_success_title") ?? "Upload Success",
                              message: Translations.of(context)?.trans("upload_success_message") ??
                                  "Upload Success Item Registered",
                            ).then((value) {
                              setState(() {
                                _isLoading = false;
                              });
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                                (route) => false,
                              );
                            });
                          });
                        }).catchError((err) {
                          setState(() {
                            _isLoading = false;
                          });
                          showOkAlertDialog(
                            context: context,
                            title: Translations.of(context)?.trans("upload_faild_title") ?? "Upload failed",
                            message: Translations.of(context)?.trans("upload_faild_title") ?? "Faild to upload item",
                          );
                        });
                      },
                      child: Container(
                        height: 53,
                        width: deviceWidth - 32,
                        alignment: Alignment.center,
                        child: Text(
                          Translations.of(context)?.trans("complete") ?? "Complete",
                          style: TextStyle(
                            fontSize: 17,
                            color: CustomColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  alignment: Alignment.center,
                  color: CustomColors.black.withOpacity(0.7),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CustomColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
