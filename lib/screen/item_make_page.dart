import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/screen/item_detail_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ItemMakePage extends StatefulWidget {
  final CompressDto compressDto;
  final int bucketId;

  const ItemMakePage({
    super.key,
    required this.compressDto,
    required this.bucketId,
  });

  @override
  State<ItemMakePage> createState() => _ItemMakePageState();
}

class _ItemMakePageState extends State<ItemMakePage> {
  bool _isBackgroundRemove = false;
  bool _isBackgroundLoading = false;

  File? _removeImage;
  File? _removeThumbnail;

  late Server _server;

  @override
  void initState() {
    _server = Server(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: _isBackgroundRemove
              ? Image.file(
                  _removeImage!,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(widget.compressDto.image),
                  fit: BoxFit.cover,
                ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: SvgPicture.asset(
                "assets/ChevronR.svg",
                color: CustomColors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: _isBackgroundLoading
                ? Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          color: CustomColors.black.withOpacity(0.4),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                "assets/hourglass.svg",
                                width: 44,
                                height: 44,
                                color: CustomColors.white,
                              ),
                              const SizedBox(height: 19),
                              Text(
                                "Processing, please wait",
                                style: TextStyle(
                                  color: CustomColors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                : Stack(
                    children: [
                      Positioned(
                        bottom: 2,
                        left: 16,
                        right: 16,
                        child: Material(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomColors.black,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () async {
                              if (_isBackgroundRemove) {
                                File image = File(widget.compressDto.image);
                                File thumbnail = File(widget.compressDto.thumbnail);

                                if (await image.exists()) {
                                  await image.delete();
                                }

                                if (await thumbnail.exists()) {
                                  await thumbnail.delete();
                                }

                                Future.delayed(Duration.zero, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailPage(
                                        imageDir: _removeImage!.path,
                                        thumbnailDir: _removeThumbnail!.path,
                                        bucketId: widget.bucketId,
                                        isRemove: _isBackgroundRemove,
                                      ),
                                    ),
                                  );
                                });
                              } else {
                                Future.delayed(Duration.zero, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailPage(
                                        imageDir: widget.compressDto.image,
                                        thumbnailDir: widget.compressDto.thumbnail,
                                        bucketId: widget.bucketId,
                                        isRemove: _isBackgroundRemove,
                                      ),
                                    ),
                                  );
                                });
                              }
                            },
                            child: Container(
                              height: 53,
                              alignment: Alignment.center,
                              child: Text(
                                "Save image",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: CustomColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!_isBackgroundRemove)
                        Positioned(
                          bottom: 79.5,
                          left: 16,
                          right: 16,
                          child: Material(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () async {
                                setState(() {
                                  _isBackgroundLoading = true;
                                });
                                try {
                                  File image = File(widget.compressDto.image);
                                  File thumbnail = File(widget.compressDto.thumbnail);

                                  final dir = await getApplicationDocumentsDirectory();

                                  String removeImagePath =
                                      "${dir.path}/PROFILE_USERID_${DateTime.now().millisecondsSinceEpoch}.jpg";
                                  String removeThumbnailPath =
                                      "${dir.path}/PROFILE_THUMBNAIL_USERID_${DateTime.now().millisecondsSinceEpoch}.jpg";

                                  File? removeImage;
                                  File? removeThumbnail;

                                  if (await image.exists()) {
                                    FormData formData = FormData.fromMap({
                                      "image_file": await MultipartFile.fromFile(
                                        image.path,
                                        filename: image.path.split("/").last,
                                      ),
                                      "bg_color": "white",
                                      "channels": "rgba",
                                      "crop": "false",
                                    });

                                    print(image.path);
                                    print(await image.exists());

                                    final response = await _server.removeBackground(formData, removeImagePath);

                                    // print(response.data);

                                    removeImage = File(removeImagePath);
                                    removeImage.writeAsBytes(response.data);

                                    print(await removeImage.exists());
                                  }

                                  if (await thumbnail.exists()) {
                                    FormData formData = FormData.fromMap({
                                      "image_file": await MultipartFile.fromFile(
                                        thumbnail.path,
                                        filename: thumbnail.path.split("/").last,
                                      ),
                                      "bg_color": "white",
                                      "channels": "rgba",
                                      "crop": "false",
                                    });

                                    final response = await _server.removeBackground(formData, removeThumbnailPath);

                                    removeThumbnail = File(removeThumbnailPath);
                                    removeThumbnail.writeAsBytes(response.data);

                                    print(await removeThumbnail.exists());
                                  }

                                  setState(() {
                                    _removeImage = removeImage;
                                    _removeThumbnail = removeThumbnail;
                                    _isBackgroundLoading = false;
                                    _isBackgroundRemove = true;
                                  });
                                } catch (e) {
                                  print(e);
                                  setState(() {
                                    _isBackgroundLoading = false;
                                  });
                                }
                              },
                              child: Container(
                                height: 53,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CustomColors.white,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  "Remove background",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: CustomColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: _isBackgroundRemove ? 77 : 156,
                        left: deviceWidth / 3,
                        right: deviceWidth / 3,
                        child: Material(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomColors.lightGrey,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () async {},
                            child: Container(
                              height: 53,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/rotate-left.svg"),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Retry",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
