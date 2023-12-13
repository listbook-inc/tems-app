import 'package:flutter/material.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class EditDailyUseDialog extends StatefulWidget {
  final Function() refresh;
  final dynamic item;

  const EditDailyUseDialog({
    super.key,
    required this.refresh,
    required this.item,
  });

  @override
  State<EditDailyUseDialog> createState() => _EditDailyUseDialogState();
}

class _EditDailyUseDialogState extends State<EditDailyUseDialog> {
  late Server _server;

  @override
  void initState() {
    _server = Server(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 5),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 56, bottom: 35),
          width: deviceWidth - 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 62, bottom: 62),
                child: Text(
                  Translations.of(context)?.trans("item_daily_use_message") ??
                      'The item is used daily starting today when the toggle is activated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    color: CustomColors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Material(
                        borderRadius: BorderRadius.circular(30),
                        color: CustomColors.black,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            Navigator.pop(context);
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
                          },
                          child: Container(
                            height: 53,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "OK",
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
