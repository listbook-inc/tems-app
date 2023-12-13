import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:listbook/screen/item_manage_detail_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/global/delete_item_dialog.dart';
import 'package:listbook/widgets/global/edit_daily_user_dialog.dart';

class ItemDetailBottomSheet extends StatefulWidget {
  final Map item;
  final String bucketFolder;
  final Function() refresh;

  const ItemDetailBottomSheet({
    super.key,
    required this.item,
    required this.bucketFolder,
    required this.refresh,
  });

  @override
  State<ItemDetailBottomSheet> createState() => _ItemDetailBottomSheetState();
}

class _ItemDetailBottomSheetState extends State<ItemDetailBottomSheet> {
  bool _useDaily = false;
  bool _isActive = false;

  late Server _server;

  @override
  void initState() {
    _server = Server(context);
    _useDaily = widget.item['useDaily'];
    _isActive = widget.item['isActive'];
    print(widget.item);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.only(left: 18.78, right: 18.78),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      Translations.of(context)?.trans("daily_use") ?? "Daily use",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF535353),
                        fontWeight: FontWeight.w400,
                        height: 29 / 15,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.6,
                      child: CupertinoSwitch(
                        value: _useDaily,
                        activeColor: CustomColors.accentGreen,
                        // trackColor: MaterialStateProperty.all(CustomColors.lightGrey),
                        // trackOutlineColor: MaterialStateProperty.all(const Color(0xFFD9D9D9)),
                        onChanged: (value) async {
                          if (value) {
                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => EditDailyUseDialog(
                                refresh: widget.refresh,
                                item: widget.item,
                              ),
                            ).then((value) {
                              print(value);
                            });
                          } else {
                            await _server
                                .useDailyItem(
                              widget.item['itemId'],
                            )
                                .then(
                              (res) {
                                widget.refresh();
                                print(res.data);
                              },
                            );
                          }
                          setState(() {
                            _useDaily = value;
                            if (value) {
                              _isActive = true;
                            } else {
                              _isActive = false;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'Edit',
                        child: ListTile(
                          tileColor: Colors.white,
                          minLeadingWidth: 35,
                          leading: SvgPicture.asset("assets/image-gallery.svg"),
                          title: Text(
                            Translations.of(context)?.trans("edit") ?? "edit",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Delete',
                        child: ListTile(
                          tileColor: Colors.white,
                          minLeadingWidth: 35,
                          leading: SvgPicture.asset("assets/trash.svg"),
                          title: Text(
                            Translations.of(context)?.trans("delete") ?? "Delete",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // Add more menu items as needed
                    ];
                  },
                  onSelected: (String value) async {
                    print(value == 'Edit');
                    if (value == 'Edit') {
                      print(value);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemManageDetailPage(
                            item: widget.item,
                            refresh: widget.refresh,
                          ),
                        ),
                      );
                    } else {
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
                    }
                  },
                  child: const Tooltip(
                    message: 'More Options',
                    child: Icon(Icons.more_horiz),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Container(
                  width: (deviceWidth - 38) / 3,
                  height: (deviceWidth - 38) / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: CustomColors.lightGrey,
                      width: 1,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        "$s3URL${widget.item['userFolder']}/${widget.item['bucketFolder']}/${widget.item['itemFolder']}/${widget.item['mainItemThumbnail']}",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 19),
                Expanded(
                  child: SizedBox(
                    height: (deviceWidth - 38) / 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item['itemName'],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: CustomColors.darkGrey,
                              ),
                            ),
                            Text(
                              widget.item['note'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: CustomColors.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              Translations.of(context)?.trans("brand") ?? "Brand",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFC0C1C0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.item['brand'],
                              style: TextStyle(
                                fontSize: 12,
                                color: CustomColors.darkGrey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  Translations.of(context)?.trans("since") ?? "Since",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFC0C1C0),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat("yyyy.MM.dd")
                                      .format(DateTime.fromMillisecondsSinceEpoch(widget.item['registerAt'])),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CustomColors.darkGrey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  Translations.of(context)?.trans("days_of_usage") ?? "Days of usage",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFC0C1C0),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.item['dayOfUsage'].toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CustomColors.darkGrey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
            Material(
              borderRadius: BorderRadius.circular(30),
              color: CustomColors.black,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () async {
                  setState(() {
                    _isActive = !_isActive;
                  });

                  await _server.useItem(widget.item['itemId']).then((value) => widget.refresh());
                },
                child: Container(
                  height: 53,
                  width: deviceWidth,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isActive)
                        Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                            color: CustomColors.accentGreen,
                          ),
                        ),
                      if (_isActive) const SizedBox(width: 10),
                      Text(
                        _isActive
                            ? Translations.of(context)?.trans("item_in_use") ?? "Item in use"
                            : Translations.of(context)?.trans("to_use") ?? "To use",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.white,
                        ),
                      ),
                    ],
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
    );
  }
}
