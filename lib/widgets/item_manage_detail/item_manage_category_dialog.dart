import 'package:flutter/material.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:provider/provider.dart';

class ItemManageCategoryDialog extends StatefulWidget {
  final dynamic Function(dynamic bucket) onSuccess;
  final String bucketName;

  const ItemManageCategoryDialog({
    super.key,
    required this.onSuccess,
    required this.bucketName,
  });

  @override
  State<ItemManageCategoryDialog> createState() => _ItemManageCategoryDialogState();
}

class _ItemManageCategoryDialogState extends State<ItemManageCategoryDialog> {
  int selectIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 21, right: 21, top: 21, bottom: 21),
          width: deviceWidth - 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translations.of(context)?.trans("category") ?? "Category",
                    style: TextStyle(
                      fontSize: 24,
                      color: CustomColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Material(
                    color: CustomColors.lightGrey,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          Translations.of(context)?.trans("close") ?? "CLOSE",
                          style: TextStyle(
                            fontSize: 12,
                            color: CustomColors.grey2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: deviceWidth,
                height: 250,
                child: ListView.separated(
                  itemCount: context.watch<HomePageProvider>().mainPageBucket.length,
                  itemBuilder: (context, index) {
                    final item = context.watch<HomePageProvider>().mainPageBucket[index];

                    return Material(
                      color: selectIndex == index ? CustomColors.accentGreen.withAlpha(40) : Colors.white,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectIndex = index;
                          });
                        },
                        child: ListTile(
                          title: Text(
                            item['bucketName'],
                          ),
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            color: CustomColors.black,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  selectIndex == -1
                      ? Expanded(
                          child: Container(
                            height: 53,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: CustomColors.grey,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              Translations.of(context)?.trans("select") ?? "Select",
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Material(
                            borderRadius: BorderRadius.circular(30),
                            color: CustomColors.darkGrey,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () async {
                                widget.onSuccess(
                                  context.read<HomePageProvider>().mainPageBucket[selectIndex],
                                );
                              },
                              child: Container(
                                height: 53,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  Translations.of(context)?.trans("select") ?? "Select",
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
