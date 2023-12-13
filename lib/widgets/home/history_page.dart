import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:listbook/screen/item_manage_detail_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/global/item_history_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryPage extends StatefulWidget {
  final Function() refresh;

  const HistoryPage({super.key, required this.refresh});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Server _server;
  Future<List<dynamic>>? _future;
  DateTime _focusDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final TextStyle dateTextStyle = TextStyle(
    fontSize: 17,
    color: CustomColors.grey2,
  );

  final TextStyle itemNameTextStyle = TextStyle(
    fontSize: 17,
    color: CustomColors.darkGrey,
    fontWeight: FontWeight.w500,
  );

  final TextStyle brandTextStyle = TextStyle(
    fontSize: 14,
    color: CustomColors.darkGrey,
    fontWeight: FontWeight.w500,
  );

  final TextStyle daysTextStyle = TextStyle(
    fontSize: 14,
    color: CustomColors.grey,
    fontWeight: FontWeight.w500,
  );

  String type = "CALENDAR";

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
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          Translations.of(context)?.trans("history") ?? "History",
          style: TextStyle(
            fontSize: 26,
            color: CustomColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
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
      body: Column(
        children: [
          FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 120,
                    ),
                    child: Text(
                      Translations.of(context)?.trans("server_error") ?? "Server Error",
                      style: TextStyle(
                        fontSize: 17,
                        color: CustomColors.lightRed,
                      ),
                    ),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 120,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomColors.black,
                    ),
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

                // print(snapshot.data);

                final findData = snapshot.data!
                    .where(
                      (element) => element['date'] == DateFormat('yyyy-MM-dd').format(_focusDate),
                    )
                    .toList();
                List<dynamic> data = [];
                int count = 0;

                print(findData);

                if (findData.isNotEmpty) {
                  data = findData.first['historyItemResponseList'];
                  count = data.length;
                }

                return type == 'LIST'
                    ? Expanded(
                        child: ListView(
                          children: [
                            ListHistoryWidget(
                              snapshot: snapshot,
                              refresh: widget.refresh,
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TableCalendar(
                              currentDay: _focusDate,
                              focusedDay: DateTime.now(),
                              firstDay: DateTime(2000, 01, 01),
                              lastDay: DateTime(2050, 12, 31),
                              availableCalendarFormats: const {
                                CalendarFormat.month: "한달",
                                CalendarFormat.twoWeeks: "2주",
                                CalendarFormat.week: "일주일",
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                print(selectedDay);
                                print(focusedDay);
                                setState(() {
                                  _focusDate = selectedDay;
                                });
                              },
                              eventLoader: (day) {
                                final idx = snapshot.data
                                    ?.indexWhere((element) => element['date'] == DateFormat('yyyy-MM-dd').format(day));

                                print(idx);

                                if (idx != null && idx != -1) {
                                  return snapshot.data![idx]['historyItemResponseList'];
                                } else {
                                  return [];
                                }
                              },
                              locale: Translations.of(context)?.getLocale(),
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              calendarFormat: _calendarFormat,
                              calendarStyle: const CalendarStyle(),
                              calendarBuilders: CalendarBuilders(
                                singleMarkerBuilder: (context, day, event) {
                                  return Container(
                                    width: 10,
                                    height: 10,
                                    decoration:
                                        BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
                                  );
                                },
                                markerBuilder: (context, day, events) {
                                  return events.isNotEmpty
                                      ? Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        )
                                      : Container();
                                },
                              ),
                            ),
                            Container(
                              width: deviceWidth,
                              margin: const EdgeInsets.only(top: 20),
                              height: 1,
                              color: const Color(0xFFF4F4F4),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: count,
                                padding: const EdgeInsets.only(top: 20),
                                itemBuilder: (BuildContext context, int index) {
                                  // print(data[index]);
                                  // return Container();
                                  // print(
                                  //     "$s3URL${findData[0]['userFolder']}/${data[index]['bucketFolder']}/${data[index]['itemFolder']}/${data[index]['thumbnailImage']}");
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ItemManageDetailPage(
                                            item: findData[0]['itemManageResponses'][index],
                                            refresh: widget.refresh,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
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
                                                  "$s3URL${findData[0]['userFolder']}/${data[index]['bucketFolder']}/${data[index]['itemFolder']}/${data[index]['thumbnailImage']}",
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 19),
                                          Expanded(
                                            child: Container(
                                              height: 73,
                                              padding: const EdgeInsets.symmetric(vertical: 5),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    data[index]['itemName'],
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: CustomColors.darkGrey,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        findData[0]['itemManageResponses'][index]['brand'],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: CustomColors.darkGrey,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${findData[0]['itemManageResponses'][index]['dayOfUsage']} ${findData[0]['itemManageResponses'][index]['dayOfUsage'] == 1 ? Translations.of(context)?.trans("day") : Translations.of(context)?.trans("days")}",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: CustomColors.grey,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 10),
                                    height: 1,
                                    width: deviceWidth,
                                    color: const Color(0xFFF4F4F4),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
              }
            },
          )
        ],
      ),
    );
  }
}

class MonthBuilder extends StatelessWidget {
  final int month;
  final int year;

  MonthBuilder({super.key, required this.month, required this.year});

  final List<String> dayOfNum = ["S", "M", "T", "W", "T", "F", "S"];

  @override
  Widget build(BuildContext context) {
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
            children: dayOfNum
                .map(
                  (e) => Text(
                    e,
                    style: TextStyle(
                      fontSize: 15,
                      color: CustomColors.grey2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}

class DayBuilder extends StatelessWidget {
  final DateTime date;
  final AsyncSnapshot<List<dynamic>> snapshot;
  final Function() refresh;

  const DayBuilder({
    super.key,
    required this.date,
    required this.snapshot,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    final element =
        snapshot.data!.where((element) => element['date'] == DateFormat("yyyy-MM-dd").format(date)).toList();

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
                refresh: refresh,
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
                  color: DateFormat("yyyy-MM-dd").format(DateTime.now()) == DateFormat("yyyy-MM-dd").format(date)
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
                    color: DateFormat("yyyy-MM-dd").format(DateTime.now()) == DateFormat("yyyy-MM-dd").format(date)
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
  }
}

class ListHistoryWidget extends StatelessWidget {
  final TextStyle dateTextStyle = TextStyle(
    fontSize: 17,
    color: CustomColors.grey2,
  );

  final TextStyle itemNameTextStyle = TextStyle(
    fontSize: 17,
    color: CustomColors.darkGrey,
    fontWeight: FontWeight.w500,
  );

  final TextStyle brandTextStyle = TextStyle(
    fontSize: 14,
    color: CustomColors.darkGrey,
    fontWeight: FontWeight.w500,
  );

  final TextStyle daysTextStyle = TextStyle(
    fontSize: 14,
    color: CustomColors.grey,
    fontWeight: FontWeight.w500,
  );

  final AsyncSnapshot<List<dynamic>> snapshot;
  final Function() refresh;

  ListHistoryWidget({
    super.key,
    required this.snapshot,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < snapshot.data!.length; i++)
          HistoryItem(
            data: snapshot.data![i],
            dateTextStyle: dateTextStyle,
            itemNameTextStyle: itemNameTextStyle,
            brandTextStyle: brandTextStyle,
            daysTextStyle: daysTextStyle,
            onTap: (item) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemManageDetailPage(
                    item: item,
                    refresh: refresh,
                  ),
                ),
              );
            },
          )
      ],
    );
  }
}

class HistoryItem extends StatelessWidget {
  final data;
  final TextStyle dateTextStyle;
  final TextStyle itemNameTextStyle;
  final TextStyle brandTextStyle;
  final TextStyle daysTextStyle;
  final Function onTap;

  const HistoryItem({
    super.key,
    required this.data,
    required this.dateTextStyle,
    required this.itemNameTextStyle,
    required this.brandTextStyle,
    required this.daysTextStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                DateFormat("MMM/dd/yyyy").format(DateTime.parse(data['date'])),
                style: dateTextStyle,
              ),
            ],
          ),
          const SizedBox(height: 7),
          for (var j = 0; j < data['historyItemResponseList'].length; j++)
            InkWell(
              onTap: () => onTap(data['itemManageResponses'][j]),
              child: HistoryItemDetail(data: data, index: j),
            ),
          const SizedBox(height: 3),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            color: CustomColors.lightGrey,
          )
        ],
      ),
    );
  }
}

class HistoryItemDetail extends StatelessWidget {
  final data;
  final int index;

  const HistoryItemDetail({super.key, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 11),
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
                    "$s3URL${data['userFolder']}/${data['historyItemResponseList'][index]['bucketFolder']}/${data['historyItemResponseList'][index]['itemFolder']}/${data['historyItemResponseList'][index]['thumbnailImage']}",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 19),
            Expanded(
              child: Container(
                height: 73,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['historyItemResponseList'][index]['itemName'],
                      style: TextStyle(
                        fontSize: 17,
                        color: CustomColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['itemManageResponses'][index]['brand'],
                          style: TextStyle(
                            fontSize: 14,
                            color: CustomColors.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${data['itemManageResponses'][index]['dayOfUsage']}  ${data['itemManageResponses'][index]['dayOfUsage'] == 1 ? Translations.of(context)?.trans("day") : Translations.of(context)?.trans("days")}",
                          style: TextStyle(
                            fontSize: 14,
                            color: CustomColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 11),
      ],
    );
  }
}
