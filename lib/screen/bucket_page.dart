import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/item_make_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/image_compress.dart';
import 'package:listbook/widgets/home/main_page/item_detail_bottom_sheet.dart';
import 'package:provider/provider.dart';

class BucketPage extends StatefulWidget {
  final Map bucket;

  const BucketPage({super.key, required this.bucket});

  @override
  State<BucketPage> createState() => _BucketPageState();
}

class _BucketPageState extends State<BucketPage> {
  @override
  Widget build(BuildContext context) {
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    final scrollHeight = ((deviceWidth - (14 * 3)) / 2) +
        ((((deviceWidth - (14 * 3)) / 2) * 0.43) * (widget.bucket['allItems'].length + 1));

    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: Image.network("$s3URL${widget.bucket['bucketImageFolder']}/${widget.bucket['bucketImage']}"),
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
                color: Colors.white,
              ),
            ),
            title: Text(
              widget.bucket['bucketName'],
              style: TextStyle(
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
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Text(
                      "EDIT",
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
                  ? Center(
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
                                            return const ItemDetailBottomSheet();
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
                                                  "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${widget.bucket['bucketFolder']}/${widget.bucket['allItems'][i - 1]['itemFolder']}/${widget.bucket['allItems'][i - 1]['thumbnailImage']}",
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
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
