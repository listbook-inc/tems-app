import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:listbook/screen/item_image_upload_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/image_compress.dart';
import 'package:listbook/widgets/global/delete_item_dialog.dart';
import 'package:listbook/widgets/item_manage_detail/item_manage_category_dialog.dart';

class ItemManageDetailPage extends StatefulWidget {
  final Function() refresh;
  final Map item;

  const ItemManageDetailPage({
    super.key,
    required this.item,
    required this.refresh,
  });

  @override
  State<ItemManageDetailPage> createState() => _ItemManageDetailPageState();
}

class _ItemManageDetailPageState extends State<ItemManageDetailPage> {
  bool _isActive = false;
  List<File> newImageList = [];
  List<File> newThumbnailList = [];
  List<int> deleteImageList = [];
  List<dynamic> image = [];

  bool isEditCategory = true;
  bool isEditName = true;
  bool isEditBrand = true;
  bool isEditNote = true;

  int bucketId = -1;
  String category = "";
  String name = "";
  String brand = "";
  String note = "";

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _noteController = TextEditingController();

  final nameFocus = FocusNode();
  final brandFocus = FocusNode();
  final noteFocus = FocusNode();

  late Server _server;

  @override
  void initState() {
    _isActive = widget.item['useDaily'];
    image = [...widget.item['itemImages']];
    category = widget.item['category'];
    _nameController.text = widget.item['itemName'];
    _brandController.text = widget.item['brand'];
    _noteController.text = widget.item['note'];

    _server = Server(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: CustomColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.item['itemName'],
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
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: (deviceWidth - 32 - 26) / 3 * ((image.length + 1) / 3).ceil() + 13,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                  ),
                  itemCount: image.length + 1,
                  itemBuilder: (context, index) {
                    if (index == image.length) {
                      return Material(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () async {
                            print((4 / 3).ceil());
                            final value = await showMenu(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: CustomColors.white,
                              position: RelativeRect.fromLTRB(16, (deviceHeight / 5) * (index / 3).ceil(), 16, 0),
                              items: [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    leading: SvgPicture.asset("assets/image-gallery.svg"),
                                    title: Text(
                                      Translations.of(context)?.trans("photo_album") ?? "",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                        color: CustomColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    leading: SvgPicture.asset("assets/camera.svg"),
                                    title: Text(
                                      Translations.of(context)?.trans("take_a_photo") ?? "",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                        color: CustomColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                            print(value);

                            XFile? file;

                            if (value == 1) {
                              file = await ImagePicker().pickImage(source: ImageSource.gallery);
                            } else if (value == 2) {
                              file = await ImagePicker().pickImage(source: ImageSource.camera);
                            }

                            try {
                              final dto = await compress(file);

                              if (dto != null) {
                                // ignore: use_build_context_synchronously
                                final response = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemImageUploadPage(
                                      compressDto: dto,
                                      retry: value == 1 ? ImageSource.gallery : ImageSource.camera,
                                    ),
                                  ),
                                );

                                if (response != null) {
                                  newImageList.add(response['itemImage']);
                                  newThumbnailList.add(response['itemThumbnail']);
                                  setState(() {
                                    image = [...image, response['itemThumbnail']];
                                  });
                                }
                              }
                            } catch (e) {}
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: CustomColors.black,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.add_rounded),
                          ),
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () async {
                        print("TABBBB");
                        final images = image.map((i) {
                          print(i is File);
                          if (i is File) {
                            return Image.file(i).image;
                          }
                          print(i['itemImage']);
                          return Image.network(
                                  "$s3URL${widget.item['userFolder']}/${widget.item['bucketFolder']}/${widget.item['itemFolder']}/${i['itemImage']}")
                              .image;
                        }).toList();

                        final imageProvider = MultiImageProvider(images);

                        print(images);

                        await showImageViewerPager(
                          context,
                          imageProvider,
                          useSafeArea: true,
                          doubleTapZoomable: true,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: CustomColors.lightGrey,
                                width: 1,
                              ),
                              image: image[index] is File
                                  ? DecorationImage(image: FileImage(image[index]), fit: BoxFit.cover)
                                  : DecorationImage(
                                      image: NetworkImage(
                                        "$s3URL${widget.item['userFolder']}/${widget.item['bucketFolder']}/${widget.item['itemFolder']}/${image[index]['thumbnailImage']}",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          if (image[index] is! File &&
                              image[index]['thumbnailImage'] == widget.item['mainItemThumbnail'])
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: CustomColors.black,
                                ),
                                child: Text(
                                  Translations.of(context)?.trans("main") ?? "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CustomColors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Transform.translate(
                              offset: const Offset(5, -5),
                              child: Material(
                                borderRadius: BorderRadius.circular(12),
                                color: CustomColors.white,
                                child: InkWell(
                                  onTap: () async {
                                    if (image.length <= 1) {
                                      showOkAlertDialog(
                                        context: context,
                                        title: "Cannot remove",
                                        message: "Required One image",
                                      );
                                      return;
                                    }

                                    if (image[index] is File) {
                                      final idx = newThumbnailList.indexWhere((element) => element == image[index]);
                                      if (await newImageList[idx].exists()) {
                                        newImageList[idx].delete();
                                      }
                                      if (await newThumbnailList[idx].exists()) {
                                        newThumbnailList[idx].delete();
                                      }

                                      newImageList.removeAt(idx);
                                      newThumbnailList.removeAt(idx);

                                      final fixImage = [...image];
                                      fixImage.removeAt(index);

                                      setState(() {
                                        image = [...fixImage];
                                      });
                                    } else {
                                      final fixImage = [...image];
                                      final img = fixImage.removeAt(index);

                                      deleteImageList.add(img['itemImageId']);

                                      setState(() {
                                        image = [...fixImage];
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: CustomColors.lightGrey,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      height: 57,
                      width: deviceWidth - 32,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CustomColors.lightGrey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              Translations.of(context)?.trans("category") ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: CustomColors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: CustomColors.darkGrey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => ItemManageCategoryDialog(
                                        bucketName: name,
                                        onSuccess: (value) {
                                          print(value);
                                          setState(() {
                                            category = value['bucketName'];
                                            bucketId = value['bucketId'];
                                          });

                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                    "assets/edit.svg",
                                    color: CustomColors.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 57,
                      width: deviceWidth - 32,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CustomColors.lightGrey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              Translations.of(context)?.trans("item_name") ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: CustomColors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                isEditName
                                    ? Expanded(
                                        child: TextField(
                                          controller: _nameController,
                                          focusNode: nameFocus,
                                          onTapOutside: (value) {
                                            nameFocus.unfocus();
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Input item name",
                                            hintStyle: TextStyle(
                                              color: CustomColors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: CustomColors.darkGrey,
                                        ),
                                      ),
                                IconButton(
                                  onPressed: () {
                                    _nameController.clear();
                                  },
                                  icon: isEditName
                                      ? const Icon(Icons.close_rounded)
                                      : SvgPicture.asset(
                                          "assets/edit.svg",
                                          color: CustomColors.grey,
                                        ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 57,
                      width: deviceWidth - 32,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CustomColors.lightGrey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              Translations.of(context)?.trans("brand") ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: CustomColors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                isEditBrand
                                    ? Expanded(
                                        child: TextField(
                                          controller: _brandController,
                                          focusNode: brandFocus,
                                          onTapOutside: (value) {
                                            brandFocus.unfocus();
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Input item brand",
                                            hintStyle: TextStyle(
                                              color: CustomColors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        brand,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: CustomColors.darkGrey,
                                        ),
                                      ),
                                IconButton(
                                  onPressed: () {
                                    _brandController.clear();
                                  },
                                  icon: isEditBrand
                                      ? const Icon(Icons.close_rounded)
                                      : SvgPicture.asset(
                                          "assets/edit.svg",
                                          color: CustomColors.grey,
                                        ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 57,
                      width: deviceWidth - 32,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CustomColors.lightGrey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              Translations.of(context)?.trans("note") ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: CustomColors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                isEditNote
                                    ? Expanded(
                                        child: TextField(
                                          controller: _noteController,
                                          focusNode: noteFocus,
                                          onTapOutside: (value) {
                                            noteFocus.unfocus();
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Input item note",
                                            hintStyle: TextStyle(
                                              color: CustomColors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        note,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: CustomColors.darkGrey,
                                        ),
                                      ),
                                IconButton(
                                  onPressed: () {
                                    if (isEditNote) {
                                      setState(() {
                                        note = _noteController.text;
                                      });
                                    } else {
                                      setState(() {
                                        _noteController.text = note;
                                      });
                                    }

                                    setState(() {
                                      isEditNote = !isEditNote;
                                    });
                                  },
                                  icon: isEditNote
                                      ? const Icon(Icons.close_rounded)
                                      : SvgPicture.asset(
                                          "assets/edit.svg",
                                          color: CustomColors.grey,
                                        ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 57,
                      width: deviceWidth - 32,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CustomColors.lightGrey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              Translations.of(context)?.trans("registered_date") ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: CustomColors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat("yyyy.MM.dd").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      widget.item['registerAt'],
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: CustomColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 57,
                      width: deviceWidth - 32,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CustomColors.lightGrey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              Translations.of(context)?.trans("days_of_usage") ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: CustomColors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${widget.item['dayOfUsage']} ${Translations.of(context)?.trans("days")}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: CustomColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 57,
                width: deviceWidth - 32,
                decoration: BoxDecoration(
                  color: CustomColors.lightGrey,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      Translations.of(context)?.trans("daily_use") ?? "",
                      style: TextStyle(
                        fontSize: 15,
                        color: CustomColors.darkGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    CupertinoSwitch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });

                        print(widget.item['useDaily']);
                      },
                      activeColor: CustomColors.accentGreen,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Material(
                borderRadius: BorderRadius.circular(30),
                color: CustomColors.black,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    List<MultipartFile> itemImages = [];
                    List<MultipartFile> itemThumbnails = [];
                    for (var i = 0; i < newImageList.length; i++) {
                      itemImages.add(await MultipartFile.fromFile(
                        newImageList[i].path,
                        filename: newImageList[i].path.split("/").last,
                      ));

                      itemThumbnails.add(
                        await MultipartFile.fromFile(
                          newThumbnailList[i].path,
                          filename: newThumbnailList[i].path.split("/").last,
                        ),
                      );
                    }

                    FormData formData = FormData.fromMap({
                      "itemImages": itemImages,
                      "itemThumbnails": itemThumbnails,
                      "deleteImages": deleteImageList,
                      "name": _nameController.text,
                      "brand": _brandController.text,
                      "useDaily": _isActive,
                      "note": _noteController.text,
                      "bucketId": bucketId,
                    });

                    await _server
                        .updateItem(
                      formData,
                      widget.item['itemId'],
                    )
                        .then(
                      (value) {
                        widget.refresh();
                        Navigator.pop(context);
                      },
                    );
                  },
                  child: Container(
                    height: 53,
                    width: deviceWidth - 32,
                    alignment: Alignment.center,
                    child: Text(
                      Translations.of(context)?.trans("complete") ?? "",
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
                      builder: (context) => DeleteItemDialog(onSuccess: () async {
                        await _server.deleteItem(widget.item['itemId']).then(
                          (value) {
                            showOkAlertDialog(
                              context: context,
                              title: Translations.of(context)?.trans("delete_item_title") ?? "Success to delete",
                              message:
                                  Translations.of(context)?.trans("delete_item_message") ?? "Success to delete item!",
                            ).then(
                              (value) {
                                widget.refresh();
                                Navigator.pop(context);
                              },
                            );
                          },
                        ).catchError(
                          (err) {
                            // final e = err as DioException;s
                            showOkAlertDialog(
                              context: context,
                              title: "Failed to delete",
                              message: "failed to delete because of server error",
                            ).then(
                              (value) {
                                widget.refresh();
                                Navigator.pop(context);
                                // Navigator.pop(context);
                              },
                            );
                          },
                        );
                      }),
                    ).then(
                      (value) => Navigator.pop(context),
                    );
                  },
                  child: Container(
                    height: 53,
                    width: deviceWidth - 32,
                    alignment: Alignment.center,
                    child: Text(
                      Translations.of(context)?.trans("delete_item") ?? "",
                      style: TextStyle(
                        fontSize: 17,
                        color: CustomColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              if (Platform.isAndroid)
                const SizedBox(
                  height: 20,
                )
            ],
          ),
        ),
      ),
    );
  }
}
