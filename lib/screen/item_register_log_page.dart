import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class ItemRegisterLogPage extends StatefulWidget {
  const ItemRegisterLogPage({super.key});

  @override
  State<ItemRegisterLogPage> createState() => _ItemRegisterLogPageState();
}

class _ItemRegisterLogPageState extends State<ItemRegisterLogPage> {
  late Server _server;
  Future<List<dynamic>>? items;

  Future<List<dynamic>> getManageItems() async {
    final response = await _server.getRegisterLog();

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
    final deviceWidth = MediaQuery.of(context).size.width;
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
          Translations.of(context)?.trans("recent_items") ?? "",
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        Translations.of(context)?.trans("latest") ?? "Latest",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: CustomColors.grey2,
                        ),
                      ),
                    ],
                  ),
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
                                  Translations.of(context)?.trans("server_error") ?? "Server Error",
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
                                    Translations.of(context)?.trans("no_item_message") ??
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: deviceWidth - 32,
                                      height: 61,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: CustomColors.lightGrey,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            DateFormat("yyyy.M.dd").format(
                                              DateTime.fromMillisecondsSinceEpoch(snapshot.data![i]['registerAt']),
                                            ),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: CustomColors.grey,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 30,
                                          ),
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
