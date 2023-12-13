import 'package:flutter/material.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Server _server;
  Future<dynamic>? _notification;

  @override
  void initState() {
    _server = Server(context);

    _notification = getNotifications();
    super.initState();
  }

  getNotifications() async {
    final data = await _server.getAlarms().then((value) {
      return value.data;
    }).catchError((err) {
      print(err);
      return [];
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context)?.trans("notification_title") ?? "Notifications",
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 26,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _notification,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
              if (snapshot.data.isEmpty) {
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
                          Translations.of(context)?.trans("no_notification") ?? "There are not notifications",
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

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _notification = getNotifications();
                  });
                },
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data[index];

                    return ListTile(
                      title: Text(
                        data['title'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      leading: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                "$s3URL${data['item']['bucket']['folder']}/${data['item']['folder']}/${data['item']['itemImage']['thumbnailImage']}"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: data['content'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${DateTime.fromMillisecondsSinceEpoch(data['ringAt']).difference(DateTime.now()).inHours} h",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: CustomColors.grey2,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
