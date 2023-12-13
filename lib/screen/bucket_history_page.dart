import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/global/item_history_dialog.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';

class BucketHistoryPage extends StatefulWidget {
  final Map bucket;
  final Function() refresh;

  const BucketHistoryPage({
    super.key,
    required this.bucket,
    required this.refresh,
  });

  @override
  State<BucketHistoryPage> createState() => _BucketHistoryPageState();
}

class _BucketHistoryPageState extends State<BucketHistoryPage> {
  late Server _server;
  Future<List<dynamic>>? _future;

  String type = "LIST";

  Future<List<dynamic>> getHistories() async {
    final response = await _server.getBucketHistories(widget.bucket['bucketId']);

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
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.bucket['bucketName'],
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (type == 'LIST') {
                          type = 'CALENDAR';
                        } else {
                          type = 'LIST';
                        }
                      });
                    },
                    icon: type == 'LIST'
                        ? SvgPicture.asset(
                            "assets/calendar.svg",
                          )
                        : SvgPicture.asset("assets/list.svg"),
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
                          Translations.of(context)?.trans('server_error') ?? "Server Error",
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
                  if (snapshot.data!.isEmpty && type == 'LIST') {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 120),
                        // color: Colors.blue,
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 45,
                              color: CustomColors.grey,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              Translations.of(context)?.trans("no_history_message") ??
                                  "No item history yet.\nRegister and use an item to see.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: CustomColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return type == 'LIST'
                      ? Column(
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
                        )
                      : SizedBox(
                          height: safeAreaHeight,
                          child: PagedVerticalCalendar(
                            initialDate: DateTime.now(),
                            startWeekWithSunday: true,
                            monthBuilder: (context, month, year) {
                              String monthName = DateFormat('yyyy / MMMM').format(DateTime(year, month));

                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                                    decoration: BoxDecoration(
                                      // color: CustomColors.accentGreen,
                                      border: Border(
                                        top: BorderSide(
                                          width: 1,
                                          color: CustomColors.lightGrey,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              monthName,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                color: CustomColors.darkGrey,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: CustomColors.lightGrey,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "S",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CustomColors.grey2,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "M",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CustomColors.grey2,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "T",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CustomColors.grey2,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "W",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CustomColors.grey2,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "T",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CustomColors.grey2,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "F",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CustomColors.grey2,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "S",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: CustomColors.grey2,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                            dayBuilder: (context, date) {
                              final element = snapshot.data!
                                  .where((element) => element['date'] == DateFormat("yyyy-MM-dd").format(date))
                                  .toList();

                              // print(date);

                              return Material(
                                color: CustomColors.white,
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ItemHistoryDialog(
                                          today: DateFormat('yyyy-MM-dd').format(date),
                                          histories: element.isEmpty ? null : element[0],
                                          refresh: widget.refresh,
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        // border: Border.all(
                                        //   color: CustomColors.black,
                                        //   width: 1,
                                        // ),
                                        ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: DateFormat("yyyy-MM-dd").format(DateTime.now()) ==
                                                    DateFormat("yyyy-MM-dd").format(date)
                                                ? CustomColors.black
                                                : CustomColors.white,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            date.day.toString(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: DateFormat("yyyy-MM-dd").format(DateTime.now()) ==
                                                      DateFormat("yyyy-MM-dd").format(date)
                                                  ? CustomColors.white
                                                  : CustomColors.darkGrey,
                                              // height: 29 / 15,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        if (element.isNotEmpty)
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 0,
                                                  left: 10,
                                                  right: 10,
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width / 7,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: CustomColors.white,
                                                      ),
                                                      // color: CustomColors.accentGreen,
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          "$s3URL${element[0]['userFolder']}/${element[0]['historyItemResponseList'][0]['bucketFolder']}/${element[0]['historyItemResponseList'][0]['itemFolder']}/${element[0]['historyItemResponseList'][0]['thumbnailImage']}",
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (element[0]['historyItemResponseList'].length >= 2)
                                                  Positioned(
                                                    top: 15,
                                                    left: 10,
                                                    right: 10,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width / 7,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: CustomColors.white,
                                                        ),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            "$s3URL${element[0]['userFolder']}/${element[0]['historyItemResponseList'][1]['bucketFolder']}/${element[0]['historyItemResponseList'][1]['itemFolder']}/${element[0]['historyItemResponseList'][1]['thumbnailImage']}",
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (element[0]['historyItemResponseList'].length >= 3)
                                                  Positioned(
                                                    top: 30,
                                                    left: 10,
                                                    right: 10,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width / 7,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: CustomColors.white,
                                                        ),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            "$s3URL${element[0]['userFolder']}/${element[0]['historyItemResponseList'][2]['bucketFolder']}/${element[0]['historyItemResponseList'][2]['itemFolder']}/${element[0]['historyItemResponseList'][2]['thumbnailImage']}",
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        if (element.isNotEmpty && element[0]['historyItemResponseList'].length > 3)
                                          Text(
                                            "+${element[0]['historyItemResponseList'].length - 3}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: CustomColors.darkGrey,
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
