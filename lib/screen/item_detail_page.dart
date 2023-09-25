import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:listbook/screen/home_page.dart';
import 'package:listbook/server/server.dart';
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
        backgroundColor: Colors.white,
        title: Text(
          "Item information",
          style: TextStyle(
            fontSize: 26,
            color: CustomColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        nameFocus.unfocus();
                      },
                      onChanged: (value) {
                        print(value);
                      },
                      controller: _nameController,
                      focusNode: nameFocus,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Item name",
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
                        "Brand",
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
                        hintText: "e.g. Apple",
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
                        "Note",
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
                        hintText: "Write a memo about it!",
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
                      "Daily use",
                      style: TextStyle(
                        fontSize: 15,
                        color: CustomColors.darkGrey,
                      ),
                    ),
                    Switch(
                      value: dailyUse,
                      activeColor: CustomColors.black,
                      inactiveThumbColor: CustomColors.black,
                      inactiveTrackColor: CustomColors.white,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "The number of days in use is counted when the toggle is activated.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: CustomColors.mediumGrey,
                  ),
                ),
              ),
              const SizedBox(height: 42),
              Material(
                borderRadius: BorderRadius.circular(30),
                color: CustomColors.black,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    if (_nameController.text == "" || _brandController.text == "" || _noteController.text == "") {
                      showOkAlertDialog(
                        context: context,
                        title: "Faild Upload",
                        message: "Faild Item upload..",
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
                    });

                    await _server.uploadItem(formData, widget.bucketId).then((value) async {
                      await image.delete();
                      await thumbnail.delete();

                      showOkAlertDialog(
                        context: context,
                        title: "Upload Success",
                        message: "Upload Success Item Registered",
                      ).then((value) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (route) => false,
                        );
                      });
                    });
                  },
                  child: Container(
                    height: 53,
                    width: deviceWidth - 32,
                    alignment: Alignment.center,
                    child: Text(
                      "Complete",
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
      ),
    );
  }
}
