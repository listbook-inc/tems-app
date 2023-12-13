import 'package:flutter/material.dart';
import 'package:listbook/screen/item_manage_detail_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class ItemHistoryDialog extends StatefulWidget {
  final String today;
  final dynamic histories;
  final Function() refresh;

  const ItemHistoryDialog({
    super.key,
    required this.today,
    required this.histories,
    required this.refresh,
  });

  @override
  State<ItemHistoryDialog> createState() => _ItemHistoryDialogState();
}

class _ItemHistoryDialogState extends State<ItemHistoryDialog> {
  int selectIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 21, right: 21, top: 21, bottom: 21),
          width: deviceWidth - 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.today} | ${Translations.of(context)?.trans("history") ?? "History"}",
                    style: TextStyle(
                      fontSize: 22,
                      color: CustomColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Material(
                    color: CustomColors.lightGrey,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          Translations.of(context)?.trans("close") ?? "CLOSE",
                          style: TextStyle(
                            fontSize: 12,
                            color: CustomColors.grey2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: deviceWidth,
                height: 250,
                child: widget.histories == null
                    ? Container()
                    : ListView.separated(
                        itemCount: widget.histories['historyItemResponseList'].length,
                        itemBuilder: (context, index) {
                          final item = widget.histories['historyItemResponseList'][index];
                          final manageItem = widget.histories['itemManageResponses'][index];
                          print(item);

                          return Material(
                            color: Colors.white,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemManageDetailPage(
                                      item: manageItem,
                                      refresh: widget.refresh,
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Image.network(
                                    "$s3URL${widget.histories['userFolder']}/${item['bucketFolder']}/${item['itemFolder']}/${item['thumbnailImage']}",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  item['itemName'],
                                ),
                                titleTextStyle: TextStyle(
                                  fontSize: 16,
                                  color: CustomColors.black,
                                ),
                                trailing: Text(
                                  "${manageItem['dayOfUsage']} ${manageItem['dayOfUsage'] == 1 ? Translations.of(context)?.trans("day") : Translations.of(context)?.trans("days")}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CustomColors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
