import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Server _server;
  Future<List<dynamic>>? _future;

  Future<List<dynamic>> getHistories() async {
    final response = await _server.getHistories();

    print(response.data);

    return response.data;
  }

  @override
  void initState() {
    _server = Server(context);
    _future = getHistories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(
            fontSize: 26,
            color: CustomColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 47,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: CustomColors.lightGrey,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "2023",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.darkGrey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/calendar.svg",
                    ),
                  )
                ],
              ),
            ),
            FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Server Error",
                          style: TextStyle(
                            fontSize: 17,
                            color: CustomColors.lightRed,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CustomColors.black,
                        )
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      for (var i = 0; i < snapshot.data!.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Text(
                                    "${DateTime.parse(snapshot.data![i]['date']).month}/${DateTime.parse(snapshot.data![i]['date']).day}",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: CustomColors.grey2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              for (var j = 0; j < snapshot.data![i]['historyItemResponseList'].length; j++)
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 73,
                                          height: 73,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: CustomColors.lightGrey,
                                              width: 1,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                "$s3URL${snapshot.data![i]['userFolder']}/${snapshot.data![i]['historyItemResponseList'][j]['bucketFolder']}/${snapshot.data![i]['historyItemResponseList'][j]['itemFolder']}/${snapshot.data![i]['historyItemResponseList'][j]['thumbnailImage']}",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 19),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  snapshot.data![i]['historyItemResponseList'][j]['itemName'],
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: CustomColors.darkGrey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 11),
                                  ],
                                ),
                              const SizedBox(height: 3),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 1,
                                color: CustomColors.lightGrey,
                              )
                            ],
                          ),
                        )
                    ],
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
