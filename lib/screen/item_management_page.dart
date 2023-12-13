import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/screen/item_manage_detail_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class ItemManagementPage extends StatefulWidget {
  final Function() refresh;

  const ItemManagementPage({super.key, required this.refresh});

  @override
  State<ItemManagementPage> createState() => _ItemManagementPageState();
}

class _ItemManagementPageState extends State<ItemManagementPage> {
  late Server _server;
  Future<List<dynamic>>? items;

  Future<List<dynamic>> getManageItems() async {
    final response = await _server.getManageItems();

    print(response.data);

    return response.data;
  }

  @override
  void initState() {
    _server = Server(context);
    items = getManageItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight -
        (24 + 18.5 + 4);

    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: AppBar(
        backgroundColor: CustomColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          Translations.of(context)?.trans("item_management_title") ?? "",
          style: TextStyle(
            fontSize: 26,
            color: CustomColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              items = getManageItems();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 18.5),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/filter.svg",
                        width: 24,
                        height: 24,
                        color: CustomColors.grey2,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Translations.of(context)?.trans("latest") ?? "Latest",
                        style: TextStyle(
                          fontSize: 17,
                          color: CustomColors.grey2,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder(
                    future: items,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return SizedBox(
                          height: safeAreaHeight,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Server Error",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: CustomColors.lightRed,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: safeAreaHeight,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: CustomColors.black,
                                  strokeWidth: 2,
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        if (snapshot.data!.isEmpty) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 120),
                              child: Column(
                                children: [
                                  Icon(CupertinoIcons.search, size: 45, color: CustomColors.grey),
                                  const SizedBox(height: 20),
                                  Text(
                                    Translations.of(context)?.trans("no_manage_item") ??
                                        "There are no items to manage, you must add items first",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: CustomColors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
                          constraints: BoxConstraints(
                            minHeight: safeAreaHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              for (var i = 0; i < snapshot.data!.length; i++)
                                Column(
                                  children: [
                                    Material(
                                      color: CustomColors.white,
                                      child: InkWell(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ItemManageDetailPage(
                                                item: snapshot.data![i],
                                                refresh: widget.refresh,
                                              ),
                                            ),
                                          ).then((value) {
                                            setState(() {
                                              items = getManageItems();
                                            });
                                            widget.refresh();
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          height: 83,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 83,
                                                height: 83,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: CustomColors.lightGrey,
                                                    width: 1,
                                                  ),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      "$s3URL${snapshot.data![i]['userFolder']}/${snapshot.data![i]['bucketFolder']}/${snapshot.data![i]['itemFolder']}/${snapshot.data![i]['mainItemThumbnail']}",
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 19),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      snapshot.data![i]['itemName'],
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w500,
                                                        color: CustomColors.darkGrey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 11),
                                  ],
                                )
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
