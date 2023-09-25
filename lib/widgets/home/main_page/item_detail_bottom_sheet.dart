import 'package:flutter/material.dart';
import 'package:listbook/utils/colors.dart';

class ItemDetailBottomSheet extends StatefulWidget {
  const ItemDetailBottomSheet({super.key});

  @override
  State<ItemDetailBottomSheet> createState() => _ItemDetailBottomSheetState();
}

class _ItemDetailBottomSheetState extends State<ItemDetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.only(left: 18.78, right: 18.78),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [],
            ),
            const SizedBox(height: 40),
            Material(
              borderRadius: BorderRadius.circular(30),
              color: CustomColors.black,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {},
                child: Container(
                    height: 53,
                    width: deviceWidth,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                            color: CustomColors.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Item in use",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.white,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
