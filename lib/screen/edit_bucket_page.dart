import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/home/main_page/color_selector_dialog.dart';

class EditBucketPage extends StatefulWidget {
  final List<dynamic> buckets;
  final double deviceWidth;
  final Function() refresh;

  const EditBucketPage({
    super.key,
    required this.buckets,
    required this.deviceWidth,
    required this.refresh,
  });

  @override
  State<EditBucketPage> createState() => _EditBucketPageState();
}

class _EditBucketPageState extends State<EditBucketPage> {
  List<DragAndDropList> _contents = [];
  late Server _server;

  setContects() {
    _contents = [
      DragAndDropList(
        children: List.generate(
          widget.buckets.length,
          (index) => DragAndDropItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 70,
                  width: widget.deviceWidth - 30,
                  padding: const EdgeInsets.only(left: 60, right: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFEDEDED),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.buckets[index]['bucketName'],
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
                                  widget.buckets[index]['color'] = color.value.toRadixString(16).substring(2);
                                });
                                print(widget.buckets);
                                setContects();
                                print(
                                  {
                                    "bucketCountRequests": widget.buckets
                                        .map(
                                          (e) => {
                                            "id": int.parse(e['bucketId'].toString()),
                                            "color": e['color'].toString(),
                                          },
                                        )
                                        .toList()
                                  },
                                );
                                await _server.updateBuckets(
                                  {
                                    "bucketCountRequests": widget.buckets
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
                              color: widget.buckets[index]['color'],
                            ),
                          );
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(
                              int.parse("FF${widget.buckets[index]['color']}", radix: 16),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    setContects();
    _server = Server(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Folder details",
          style: TextStyle(
            fontSize: 26,
            color: CustomColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: DragAndDropLists(
          onItemReorder: _onItemReorder,
          onListReorder: _onListReorder,
          children: _contents,
          listPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          itemDecorationWhileDragging: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          listInnerDecoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          lastItemTargetHeight: 8,
          addLastItemTargetHeightToTop: true,
          lastListTargetSize: 40,
          onItemDraggingChanged: (item, dragging) async {
            await _server.updateBuckets(
              {
                "bucketCountRequests": widget.buckets
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
            });
          },
          itemDragHandle: DragHandle(
            onLeft: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);
      _contents[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, movedList);
    });
  }
}
