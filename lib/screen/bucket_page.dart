import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/bucket_edit_page.dart';
import 'package:listbook/screen/bucket_history_page.dart';
import 'package:listbook/screen/home_page.dart';
import 'package:listbook/screen/item_make_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/image_compress.dart';
import 'package:listbook/widgets/global/max_bucket_item_dialog.dart';
import 'package:listbook/widgets/global/payment_bottom_sheet.dart';
import 'package:listbook/widgets/home/main_page/item_detail_bottom_sheet.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class BucketPage extends StatefulWidget {
  final Map bucket;
  final Function() refresh;

  const BucketPage({super.key, required this.bucket, required this.refresh});

  @override
  State<BucketPage> createState() => _BucketPageState();
}

class _BucketPageState extends State<BucketPage> {
  File? _image;
  File? _thumbnail;
  final localAuth = LocalAuthentication();

  bool _isSecurity = false;

  late Server _server;

  Future<void> deleteImage() async {
    if (_image != null && await _image!.exists()) {
      await _image!.delete();
    }

    if (_thumbnail != null && await _thumbnail!.exists()) {
      await _thumbnail!.delete();
    }
  }

  @override
  void initState() {
    _server = Server(context);
    print(widget.bucket['isDeleteImage']);
    print(widget.bucket['isSecurityFolder']);
    _isSecurity = bool.parse(widget.bucket['isSecurityFolder'].toString());
    print(widget.bucket);
    super.initState();
  }

  @override
  void dispose() {
    deleteImage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    final scrollHeight = ((deviceWidth - (14 * 3)) / 2) +
        ((((deviceWidth - (14 * 3)) / 2) * 0.43) * (widget.bucket['allItems'].length + 1)) +
        300;

    print(widget.bucket['allItems']);

    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: widget.bucket['isDeleteImage']
              ? Container(
                  color: CustomColors.folderDarkGrey,
                )
              : _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print(stackTrace);
                        return Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : widget.bucket['isDefault']
                      ? Image.network(
                          "$s3URL${widget.bucket['bucketImageFolder']}/${widget.bucket['bucketImage']}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(stackTrace);
                            return Image.network(
                              "$s3URL${widget.bucket['bucketImageFolder']}/${widget.bucket['bucketImage']}",
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.network(
                          "$s3URL${widget.bucket['userFolder']}/${widget.bucket['bucketFolder']}/${widget.bucket['bucketImage']}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(stackTrace);
                            return Image.network(
                              "$s3URL${widget.bucket['userFolder']}/${widget.bucket['bucketFolder']}/${widget.bucket['bucketImage']}",
                              fit: BoxFit.cover,
                            );
                          },
                        ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () async {
                if (_image != null && await _image!.exists()) {
                  await _image!.delete();
                }

                if (_thumbnail != null && await _thumbnail!.exists()) {
                  await _thumbnail!.delete();
                }
                Navigator.pop(context);
              },
              icon: SvgPicture.asset(
                "assets/ChevronR.svg",
                color: Colors.white,
              ),
            ),
            title: Text(
              widget.bucket['bucketName'],
              style: TextStyle(
                fontFamily: Translations.of(context)?.trans("point_font"),
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: CustomColors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              Material(
                color: CustomColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () async {
                    final obj = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BucketEditPage(
                          bucket: widget.bucket,
                        ),
                      ),
                    );

                    if (obj != null) {
                      widget.refresh();
                      if (obj['isDelete'] != "@#DELETE#@") {
                        setState(() {
                          widget.bucket['bucketName'] = obj['bucketName'];
                          widget.bucket['isDeleteImage'] = obj['isDeleteImage'];
                          _image = obj['image'];
                          _thumbnail = obj['thumbnail'];
                        });
                      } else {
                        if (_image != null && await _image!.exists()) {
                          await _image!.delete();
                        }

                        if (_thumbnail != null && await _thumbnail!.exists()) {
                          await _thumbnail!.delete();
                        }
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Text(
                      Translations.of(context)?.trans("edit") ?? "EDIT",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.grey3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SafeArea(
            child: SizedBox(
              height: safeAreaHeight,
              child: widget.bucket['totalItems'] == 0
                  ? Stack(
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: kToolbarHeight),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final value = await showMenu(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: CustomColors.white,
                                    position: RelativeRect.fromLTRB(
                                      1,
                                      deviceHeight / 2,
                                      0,
                                      deviceHeight / 2,
                                    ),
                                    items: [
                                      PopupMenuItem(
                                        value: 1,
                                        child: ListTile(
                                          leading: SvgPicture.asset("assets/image-gallery.svg"),
                                          title: Text(
                                            Translations.of(context)?.trans("photo_album") ?? "Photo album",
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
                                            Translations.of(context)?.trans("take_a_photo") ?? "Take a photo",
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
                                      Future.delayed(Duration.zero, () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ItemMakePage(
                                              compressDto: dto,
                                              bucketId: widget.bucket['bucketId'],
                                              retry: value == 1 ? ImageSource.gallery : ImageSource.camera,
                                            ),
                                          ),
                                        );
                                      });
                                    }
                                  } catch (e) {}
                                },
                                child: Container(
                                  width: (deviceWidth - (14 * 3)) / 2,
                                  height: (deviceWidth - (14 * 3)) / 2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18.8),
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ).frosted(
                              blur: 12.549020767211914,
                              borderRadius: BorderRadius.circular(18.8),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                Translations.of(context)?.trans("security") ?? "",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 10),
                              CupertinoSwitch(
                                value: _isSecurity,
                                trackColor: Colors.white,
                                onChanged: (value) async {
                                  if (value) {
                                    print(await localAuth.canCheckBiometrics);
                                    if (!await localAuth.canCheckBiometrics) {
                                      showOkAlertDialog(
                                        context: context,
                                        title: "Auth faild",
                                        message: "Not available biometric authentication",
                                      );
                                      return;
                                    }

                                    final authentication = await localAuth.authenticate(
                                      localizedReason: "Please authenticate to show account balance",
                                    );

                                    print(authentication);

                                    if (authentication) {
                                      await _server
                                          .updateSecurity(value, int.parse(widget.bucket['bucketId'].toString()))
                                          .then((res) {
                                        widget.refresh();
                                        setState(() {
                                          _isSecurity = authentication;
                                        });
                                      });
                                    }

                                    return;
                                  }
                                  await _server
                                      .updateSecurity(value, int.parse(widget.bucket['bucketId'].toString()))
                                      .then((res) {
                                    widget.refresh();
                                    setState(() {
                                      _isSecurity = value;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: SizedBox(
                        height: scrollHeight < safeAreaHeight ? safeAreaHeight : scrollHeight,
                        child: Stack(
                          children: [
                            for (var i = 0; i < widget.bucket['allItems'].length + 1; i++)
                              if (i == 0)
                                Positioned(
                                  top: 40,
                                  left: 16,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        if (widget.bucket['totalItems'] >= 4) {
                                          if (context.read<HomePageProvider>().mainPageBucket.length >= 3) {
                                            await _server.checkTrial().then((value) async {
                                              final value = await showMenu(
                                                context: context,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                color: CustomColors.white,
                                                position: RelativeRect.fromLTRB(
                                                  1,
                                                  deviceHeight / 2,
                                                  0,
                                                  deviceHeight / 2,
                                                ),
                                                items: [
                                                  PopupMenuItem(
                                                    value: 1,
                                                    child: ListTile(
                                                      leading: SvgPicture.asset("assets/image-gallery.svg"),
                                                      title: Text(
                                                        Translations.of(context)?.trans("photo_album") ?? "Photo album",
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
                                                        Translations.of(context)?.trans("take_a_photo") ??
                                                            "Take a photo",
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
                                                  Future.delayed(Duration.zero, () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ItemMakePage(
                                                          compressDto: dto,
                                                          bucketId: widget.bucket['bucketId'],
                                                          retry: value == 1 ? ImageSource.gallery : ImageSource.camera,
                                                        ),
                                                      ),
                                                    );
                                                  });
                                                }
                                              } catch (e) {}
                                            }).catchError((err) {
                                              print(err);
                                              showModalBottomSheet(
                                                isScrollControlled: true,
                                                backgroundColor: CustomColors.black,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(20.0),
                                                    topRight: Radius.circular(20.0),
                                                  ),
                                                ),
                                                context: context,
                                                builder: (context) {
                                                  return PaymentBottomSheet(
                                                    refresh: widget.refresh,
                                                    redirect: "ITEM",
                                                    redirectMethod: () async {
                                                      final value = await showMenu(
                                                        context: context,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        color: CustomColors.white,
                                                        position: RelativeRect.fromLTRB(
                                                          1,
                                                          deviceHeight / 2,
                                                          0,
                                                          deviceHeight / 2,
                                                        ),
                                                        items: [
                                                          PopupMenuItem(
                                                            value: 1,
                                                            child: ListTile(
                                                              leading: SvgPicture.asset("assets/image-gallery.svg"),
                                                              title: Text(
                                                                Translations.of(context)?.trans("photo_album") ??
                                                                    "Photo album",
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
                                                                Translations.of(context)?.trans("take_a_photo") ??
                                                                    "Take a photo",
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
                                                        file =
                                                            await ImagePicker().pickImage(source: ImageSource.gallery);
                                                      } else if (value == 2) {
                                                        file =
                                                            await ImagePicker().pickImage(source: ImageSource.camera);
                                                      }

                                                      try {
                                                        final dto = await compress(file);

                                                        if (dto != null) {
                                                          Future.delayed(Duration.zero, () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => ItemMakePage(
                                                                  compressDto: dto,
                                                                  bucketId: widget.bucket['bucketId'],
                                                                  retry: value == 1
                                                                      ? ImageSource.gallery
                                                                      : ImageSource.camera,
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                        }
                                                      } catch (e) {}
                                                    },
                                                  );
                                                },
                                              );
                                            });

                                            // showDialog(
                                            //   context: context,
                                            //   builder: (context) => MaxBucketDialog(
                                            //     onSuccess: () async {},
                                            //     message: "Cannot Add More 3 Buckets",
                                            //   ),
                                            // );
                                            return;
                                          }

                                          showDialog(
                                            context: context,
                                            builder: (context) => MaxBucketDialog(
                                              onSuccess: () async {},
                                              message: "Cannot Add More 4 Items",
                                            ),
                                          );
                                          return;
                                        }
                                        final value = await showMenu(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          color: CustomColors.white,
                                          position: RelativeRect.fromLTRB(
                                            1,
                                            deviceHeight / 2,
                                            0,
                                            deviceHeight / 2,
                                          ),
                                          items: [
                                            PopupMenuItem(
                                              value: 1,
                                              child: ListTile(
                                                leading: SvgPicture.asset("assets/image-gallery.svg"),
                                                title: Text(
                                                  Translations.of(context)?.trans("photo_album") ?? "Photo album",
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
                                                  Translations.of(context)?.trans("take_a_photo") ?? "Take a photo",
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
                                            Future.delayed(Duration.zero, () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ItemMakePage(
                                                    compressDto: dto,
                                                    bucketId: widget.bucket['bucketId'],
                                                    retry: value == 1 ? ImageSource.gallery : ImageSource.camera,
                                                  ),
                                                ),
                                              );
                                            });
                                          }
                                        } catch (e) {}
                                      },
                                      child: Container(
                                        width: (deviceWidth - (14 * 3)) / 2,
                                        height: (deviceWidth - (14 * 3)) / 2,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18.8),
                                        ),
                                        child: const Icon(Icons.add),
                                      ),
                                    ),
                                  ).frosted(
                                    blur: 12.549020767211914,
                                    borderRadius: BorderRadius.circular(18.8),
                                  ),
                                )
                              else
                                Positioned(
                                  top: 40 + i * (((deviceWidth - (14 * 3)) / 2) * 0.57),
                                  right: (i + 1) % 2 == 0 ? 16 : null,
                                  left: (i + 1) % 2 == 0 ? null : 16,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(18.8),
                                    child: InkWell(
                                      onTap: () async {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: CustomColors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0),
                                            ),
                                          ),
                                          context: context,
                                          builder: (context) {
                                            return ItemDetailBottomSheet(
                                              item: widget.bucket['allItems'][i - 1],
                                              bucketFolder: widget.bucket['bucketFolder'],
                                              refresh: widget.refresh,
                                            );
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(18.8),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: (deviceWidth - (14 * 3)) / 2,
                                            height: (deviceWidth - (14 * 3)) / 2,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(18.8),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  "$s3URL${widget.bucket['allItems'][i - 1]['userFolder']}/${widget.bucket['bucketFolder']}/${widget.bucket['allItems'][i - 1]['itemFolder']}/${widget.bucket['allItems'][i - 1]['mainItemThumbnail']}",
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          if (widget.bucket['allItems'][i - 1]['isActive'])
                                            Positioned(
                                              top: 12,
                                              right: 12,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(13),
                                                  color: CustomColors.accentGreen,
                                                ),
                                              ),
                                            ),
                                          if (widget.bucket['allItems'][i - 1]['isDisabled'])
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              left: 0,
                                              bottom: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor: CustomColors.black,
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(20.0),
                                                        topRight: Radius.circular(20.0),
                                                      ),
                                                    ),
                                                    context: context,
                                                    builder: (context) {
                                                      return PaymentBottomSheet(
                                                        refresh: widget.refresh,
                                                        redirect: "ITEM",
                                                        redirectMethod: () async {
                                                          final value = await showMenu(
                                                            context: context,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            color: CustomColors.white,
                                                            position: RelativeRect.fromLTRB(
                                                              1,
                                                              deviceHeight / 2,
                                                              0,
                                                              deviceHeight / 2,
                                                            ),
                                                            items: [
                                                              PopupMenuItem(
                                                                value: 1,
                                                                child: ListTile(
                                                                  leading: SvgPicture.asset("assets/image-gallery.svg"),
                                                                  title: Text(
                                                                    Translations.of(context)?.trans("photo_album") ??
                                                                        "Photo album",
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
                                                                    Translations.of(context)?.trans("take_a_photo") ??
                                                                        "Take a photo",
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
                                                            file = await ImagePicker()
                                                                .pickImage(source: ImageSource.gallery);
                                                          } else if (value == 2) {
                                                            file = await ImagePicker()
                                                                .pickImage(source: ImageSource.camera);
                                                          }

                                                          try {
                                                            final dto = await compress(file);

                                                            if (dto != null) {
                                                              Future.delayed(Duration.zero, () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => ItemMakePage(
                                                                      compressDto: dto,
                                                                      bucketId: widget.bucket['bucketId'],
                                                                      retry: value == 1
                                                                          ? ImageSource.gallery
                                                                          : ImageSource.camera,
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                            }
                                                          } catch (e) {}
                                                        },
                                                      );
                                                    },
                                                  );
                                                  return;
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(18.8),
                                                    color: CustomColors.black.withOpacity(0.6),
                                                  ),
                                                  child: const Icon(
                                                    CupertinoIcons.lock_circle_fill,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            Positioned(
                              top: 0,
                              right: 16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    Translations.of(context)?.trans("security") ?? "",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  CupertinoSwitch(
                                    value: _isSecurity,
                                    trackColor: Colors.white,
                                    onChanged: (value) async {
                                      if (value) {
                                        print(await localAuth.canCheckBiometrics);
                                        if (!await localAuth.canCheckBiometrics) {
                                          showOkAlertDialog(
                                            context: context,
                                            title: "Auth faild",
                                            message: "Not available biometric authentication",
                                          );
                                          return;
                                        }

                                        final authentication = await localAuth.authenticate(
                                          localizedReason: "Please authenticate to show account balance",
                                        );

                                        print(authentication);

                                        if (authentication) {
                                          await _server
                                              .updateSecurity(value, int.parse(widget.bucket['bucketId'].toString()))
                                              .then((res) {
                                            widget.refresh();
                                            setState(() {
                                              _isSecurity = authentication;
                                            });
                                          });
                                        }

                                        return;
                                      }
                                      await _server
                                          .updateSecurity(value, int.parse(widget.bucket['bucketId'].toString()))
                                          .then((res) {
                                        widget.refresh();
                                        setState(() {
                                          _isSecurity = value;
                                        });
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
        Positioned(
          right: 30,
          bottom: 115,
          child: Material(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BucketHistoryPage(
                      bucket: widget.bucket,
                      refresh: widget.refresh,
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: 53,
                width: 138,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/note-list.svg",
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Translations.of(context)?.trans("history") ?? "History",
                      style: TextStyle(
                        fontSize: 20,
                        color: CustomColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
