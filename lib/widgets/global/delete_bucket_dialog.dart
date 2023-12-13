import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class DeleteBucketDialog extends StatefulWidget {
  final Future<void> Function() onSuccess;

  const DeleteBucketDialog({super.key, required this.onSuccess});

  @override
  State<DeleteBucketDialog> createState() => _DeleteBucketDialogState();
}

class _DeleteBucketDialogState extends State<DeleteBucketDialog> {
  @override
  void initState() {
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
              SvgPicture.asset(
                'assets/trash.svg',
                width: 48,
                height: 48,
                color: CustomColors.accentGreen,
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  Translations.of(context)?.trans("delete_bucket_alert_message") ??
                      "If you delete the Bucket, it cannot be restored, will you proceed?",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 34,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 39),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Material(
                        color: CustomColors.lightGrey,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            await widget.onSuccess();
                          },
                          child: Container(
                            height: 53,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              Translations.of(context)?.trans("delete") ?? "Delete",
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.darkGrey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: Material(
                        borderRadius: BorderRadius.circular(30),
                        color: CustomColors.darkGrey,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 53,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              Translations.of(context)?.trans("cancel") ?? "Cancel",
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
