import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class PhotoEditBottomSheet extends StatefulWidget {
  final Function() onClickAlbum;
  final Function() onClickTakePhoto;
  final Function() onClickDeletePhoto;

  const PhotoEditBottomSheet({
    super.key,
    required this.onClickAlbum,
    required this.onClickTakePhoto,
    required this.onClickDeletePhoto,
  });

  @override
  State<PhotoEditBottomSheet> createState() => _PhotoEditBottomSheetState();
}

class _PhotoEditBottomSheetState extends State<PhotoEditBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: CustomColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: CustomColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: InkWell(
                onTap: () {
                  widget.onClickAlbum();
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  height: 56,
                  width: deviceWidth,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/image-gallery.svg",
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        Translations.of(context)?.trans("photo_album") ?? "Photo album",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.darkGrey,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: deviceWidth,
              height: 1,
              color: CustomColors.lightGrey,
            ),
            Material(
              color: CustomColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: InkWell(
                onTap: () {
                  widget.onClickTakePhoto();
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  height: 56,
                  width: deviceWidth,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/camera.svg",
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        Translations.of(context)?.trans("take_a_photo") ?? "Take a photo",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.darkGrey,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: deviceWidth,
              height: 1,
              color: CustomColors.lightGrey,
            ),
            Material(
              color: CustomColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: InkWell(
                onTap: () {
                  widget.onClickDeletePhoto();
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  height: 56,
                  width: deviceWidth,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/trash.svg",
                        width: 24,
                        height: 24,
                        color: CustomColors.lightRed,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        Translations.of(context)?.trans("delete_photo") ?? "Delete photo",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.lightRed,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
