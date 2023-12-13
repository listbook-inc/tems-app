import 'package:flutter/material.dart';
import 'package:listbook/utils/colors.dart';

class MaxBucketDialog extends StatefulWidget {
  final Future<void> Function() onSuccess;
  final String message;

  const MaxBucketDialog({
    super.key,
    required this.onSuccess,
    required this.message,
  });

  @override
  State<MaxBucketDialog> createState() => _MaxBucketDialogState();
}

class _MaxBucketDialogState extends State<MaxBucketDialog> {
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
              const Icon(
                Icons.cancel,
                size: 48,
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.message,
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
                              "Ok",
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
