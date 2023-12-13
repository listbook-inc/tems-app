import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listbook/screen/home_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/image_compress.dart';
import 'package:listbook/widgets/global/delete_bucket_dialog.dart';
import 'package:listbook/widgets/home/profile_page/photo_edit_bottom_sheet.dart';

class BucketEditPage extends StatefulWidget {
  final Map bucket;

  const BucketEditPage({super.key, required this.bucket});

  @override
  State<BucketEditPage> createState() => _BucketEditPageState();
}

class _BucketEditPageState extends State<BucketEditPage> {
  late Server _server;

  final _controller = TextEditingController();
  final nameFocus = FocusNode();

  bool _isLoading = false;
  bool _isDeleteImage = false;
  File? _imageDir;
  File? _thumbnailDir;

  @override
  void initState() {
    _server = Server(context);

    _controller.text = widget.bucket['bucketName'];
    _isDeleteImage = widget.bucket['isDeleteImage'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: _isDeleteImage
              ? Container(
                  color: CustomColors.folderDarkGrey,
                )
              : _imageDir != null
                  ? Image.file(
                      _imageDir!,
                      fit: BoxFit.cover,
                    )
                  : widget.bucket['isDefault']
                      ? Image.network(
                          "$s3URL${widget.bucket['bucketImageFolder']}/${widget.bucket['bucketImage']}",
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          "$s3URL${widget.bucket['userFolder']}/${widget.bucket['bucketFolder']}/${widget.bucket['bucketImage']}",
                          fit: BoxFit.cover,
                        ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: SvgPicture.asset(
                "assets/ChevronR.svg",
                color: Colors.white,
              ),
            ),
            actions: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 53,
                      margin: const EdgeInsets.only(right: 16, left: 54),
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
                        controller: _controller,
                        focusNode: nameFocus,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Bucket name",
                          hintStyle: TextStyle(
                            fontSize: 17,
                            color: CustomColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: const EdgeInsets.only(left: 16, right: 16),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 16,
                      bottom: 16,
                      child: Material(
                        borderRadius: BorderRadius.circular(12),
                        color: CustomColors.white,
                        child: InkWell(
                          onTap: () {
                            _controller.clear();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: CustomColors.grey2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: SizedBox(
                    width: deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Material(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomColors.black,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () async {
                              final formData = FormData.fromMap({
                                "bucketName": _controller.text,
                                "bucketImage": _imageDir != null ? await MultipartFile.fromFile(_imageDir!.path) : null,
                                "thumbnailImage":
                                    _thumbnailDir != null ? await MultipartFile.fromFile(_thumbnailDir!.path) : null,
                                "isDeleteImage": _isDeleteImage,
                              });

                              await _server.editBucket(formData, widget.bucket['bucketId']).then((value) {
                                showOkAlertDialog(
                                  context: context,
                                  title: "Edit Success",
                                  message: "Success to editing",
                                ).then((value) async {
                                  Navigator.pop(
                                    context,
                                    {
                                      "isDeleteImage": _isDeleteImage,
                                      "image": _imageDir,
                                      "thumbnail": _thumbnailDir,
                                      "bucketName": _controller.text,
                                    },
                                  );
                                });
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
                        const SizedBox(height: 22),
                        Material(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomColors.lightGrey,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) => DeleteBucketDialog(
                                  onSuccess: () async {
                                    await _server.deleteBucket(widget.bucket['bucketId']).then((value) {
                                      showOkAlertDialog(
                                        context: context,
                                        title:
                                            Translations.of(context)?.trans("delete_success_title") ?? "Delete Success",
                                        message: Translations.of(context)?.trans("delete_success_title") ??
                                            "Success to delete",
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
                                ),
                              );
                            },
                            child: Container(
                              height: 53,
                              width: deviceWidth - 32,
                              alignment: Alignment.center,
                              child: Text(
                                Translations.of(context)?.trans("delete_this_bucket") ?? "Delete this bucket",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (Platform.isAndroid) const SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (!nameFocus.hasFocus)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 26.5,
            bottom: MediaQuery.of(context).size.height / 2 - 26.5,
            left: deviceWidth / 2 - 69,
            right: deviceWidth / 2 - 69,
            child: Material(
              borderRadius: BorderRadius.circular(30),
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: CustomColors.white,
                    context: context,
                    builder: (context) {
                      return PhotoEditBottomSheet(
                        onClickAlbum: () async {
                          XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
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

                            setState(() {
                              _imageDir = profileImage;
                              _thumbnailDir = thumbnailImage;
                              _isDeleteImage = false;
                            });
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

                          setState(() {
                            _isLoading = false;
                          });
                        },
                        onClickTakePhoto: () async {
                          XFile? file;

                          try {
                            file = await ImagePicker().pickImage(source: ImageSource.camera).then((value) {
                              Navigator.pop(context);
                              return value;
                              // ignore: body_might_complete_normally_catch_error
                            }).catchError((err) {
                              Navigator.pop(context);
                            });
                          } catch (e) {
                            print(e);
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

                            setState(() {
                              _imageDir = profileImage;
                              _thumbnailDir = thumbnailImage;
                              _isDeleteImage = false;
                            });

                            print(profileImage);
                            print(thumbnailImage);
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

                          setState(() {
                            _isLoading = false;
                          });
                        },
                        onClickDeletePhoto: () async {
                          setState(() {
                            _isDeleteImage = true;
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: CustomColors.lightGrey,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    Translations.of(context)?.trans("edit_wallpaper") ?? "Edit Wallpaper",
                    style: TextStyle(
                      fontSize: 17,
                      color: CustomColors.lightGrey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_isLoading)
          Positioned(
            child: Container(
              color: Colors.black.withAlpha(40),
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: CustomColors.accentGreen,
              ),
            ),
          )
      ],
    );
  }
}
