import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/home/main_page/color_selector_dialog.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class EditBucketPage extends StatefulWidget {
  final double deviceWidth;
  final Function() refresh;

  const EditBucketPage({
    super.key,
    required this.deviceWidth,
    required this.refresh,
  });

  @override
  State<EditBucketPage> createState() => _EditBucketPageState();
}

class _EditBucketPageState extends State<EditBucketPage> {
  late Server _server;
  List<dynamic> buckets = [];

  // setContects() {
  // _contents = [
  //   DragAndDropList(
  //     children: List.generate(
  //       widget.buckets.length,
  //       (index) => DragAndDropItem(
  //         child:
  //       ),
  //     ),
  //   ),
  // ];
  // }

  @override
  void initState() {
    super.initState();
    // setContects();
    _server = Server(context);
  }

  List<Widget> getWidthList() {
    List<Widget> result = [];

    for (var i = 0; i < context.read<HomePageProvider>().mainPageBucket.length; i++) {
      final item = context.read<HomePageProvider>().mainPageBucket[i];

      result.add(
        SwipeActionCell(
          key: ValueKey(i),
          trailingActions: [
            SwipeAction(
              title: Translations.of(context)?.trans('delete') ?? "Delete",
              onTap: (finish) async {
                await _server
                    .deleteBucket(context.read<HomePageProvider>().mainPageBucket[i]['bucketId'])
                    .then((value) {
                  finish(true);
                  // widget.refresh();
                }).catchError((err) {
                  finish(false);
                });
                buckets.remove(i);
                context.read<HomePageProvider>().setMainBuckets(buckets);
                await widget.refresh();
                // print(widget.buckets);
                // finish(true);
              },
            )
          ],
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEDEDED),
                  width: 1,
                ),
              ),
            ),
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: CustomColors.lightGrey,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/list.svg",
                    width: 18,
                    height: 18,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 70,
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['bucketName'],
                          style: TextStyle(
                            fontSize: 17,
                            color: CustomColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => ColorSelectorDialog(
                                onSuccess: (Color color) async {
                                  setState(() {
                                    item['color'] = color.value.toRadixString(16).substring(2);
                                  });
                                  print(context.read<HomePageProvider>().mainPageBucket);
                                  // setContects();
                                  await _server.updateBuckets(
                                    {
                                      "bucketCountRequests": context
                                          .read<HomePageProvider>()
                                          .mainPageBucket
                                          .map(
                                            (e) => {
                                              "id": e['bucketId'],
                                              "color": e['color'],
                                            },
                                          )
                                          .toList()
                                    },
                                  ).then((value) {
                                    widget.refresh();
                                    Navigator.pop(context);
                                  });
                                },
                                color: item['color'],
                              ),
                            );
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(
                                int.parse("FF${item['color']}", radix: 16),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColors.white,
        // surfaceTintColor: Colors.transparent,
        // foregroundColor: Colors.transparent,
        title: Text(
          Translations.of(context)?.trans("folder_details") ?? "Folder details",
          style: TextStyle(
            fontSize: 26,
            color: CustomColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: CustomColors.lightGrey,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.refresh();
                    },
                    child: const SizedBox(
                      width: 50,
                      child: Icon(
                        Icons.move_down_rounded,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ReorderableColumn(
                  onReorder: (int oldIndex, int newIndex) async {
                    final data = buckets[oldIndex];
                    setState(() {
                      buckets.removeAt(oldIndex);
                      buckets.insert(newIndex, data);
                    });
                    print("============");
                    buckets.map(
                      (e) {
                        print(e);
                      },
                    ).toList();
                    print("============");

                    await _server.updateBuckets(
                      {
                        "bucketCountRequests": buckets
                            .map(
                              (e) => {
                                "id": int.parse(e['bucketId'].toString()),
                                "color": e['color'].toString(),
                                "name": e['bucketName']
                              },
                            )
                            .toList(),
                      },
                    ).then((value) {
                      widget.refresh();
                    });
                    print(buckets);
                  },
                  children: getWidthList(),
                ),
                // DragAndDropList(
                //   buckets,
                //   onDragFinish: (before, after) async {
                //   },
                //   canBeDraggedTo: (one, two) {
                //     if (two is! int) {
                //       return false;
                //     } else {
                //       return true;
                //     }
                //   },
                //   dragElevation: 8.0,
                //   itemBuilder: (BuildContext context, item) {
                //     return ;
                //   },
                // ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
