import 'package:flutter/material.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class ColorSelectorDialog extends StatefulWidget {
  final dynamic Function(Color color) onSuccess;
  final String color;

  const ColorSelectorDialog({super.key, required this.onSuccess, required this.color});

  @override
  State<ColorSelectorDialog> createState() => _ColorSelectorDialogState();
}

class _ColorSelectorDialogState extends State<ColorSelectorDialog> {
  int selectIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
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
                    Translations.of(context)?.trans("color") ?? "Color",
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
                height: ((deviceWidth - 42 - (13 * 6)) / 7) * 3 + 26,
                width: deviceWidth - 32,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    mainAxisSpacing: 13,
                    crossAxisSpacing: 13,
                  ),
                  itemCount: CustomColors.getFolderColors().length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectIndex = index;
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: CustomColors.getFolderColors()[index],
                            ),
                          ),
                          if (index == selectIndex)
                            const Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Icon(
                                Icons.check,
                              ),
                            )
                        ],
                      ),
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
                                widget.onSuccess(CustomColors.getFolderColors()[selectIndex]);
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
