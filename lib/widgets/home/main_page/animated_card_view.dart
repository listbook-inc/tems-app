import 'package:flutter/material.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/bucket_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/colors.dart';
import 'package:provider/provider.dart';

class AnimatedCardView extends StatefulWidget {
  final int i;

  const AnimatedCardView({super.key, required this.i});

  @override
  State<AnimatedCardView> createState() => _AnimatedCardViewState();
}

class _AnimatedCardViewState extends State<AnimatedCardView> {
  double _height = 192;

  onClick() {
    setState(() {
      if (_height == 192) {
        _height = 356.36;
      } else {
        _height = 192;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        if (context.read<HomePageProvider>().mainPageBucket.length != widget.i) {
          onClick();
        }
      },
      child: Stack(
        children: [
          AnimatedContainer(
            width: deviceWidth - 32,
            height: _height,
            padding: const EdgeInsets.only(top: 34, left: 24, right: 24),
            decoration: context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                ? BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border.all(
                      color: const Color(0xFFF2F2F7),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  )
                : BoxDecoration(
                    color: Color(
                      int.parse(
                        "FF${context.watch<HomePageProvider>().mainPageBucket[widget.i]['color']}",
                        radix: 16,
                      ),
                    ),
                    border: Border.all(
                      color: CustomColors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Tems",
                            style: TextStyle(
                              color: CustomColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CustomColors.accentGreen,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add,
                                  color: CustomColors.accentGreen,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketName'],
                            style: TextStyle(
                              color: CustomColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${context.watch<HomePageProvider>().mainPageBucket[widget.i]['totalItems']} Items",
                            style: TextStyle(
                              color: CustomColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                if (_height > 192)
                  Column(
                    children: [
                      const SizedBox(height: 13),
                      Container(
                        width: deviceWidth,
                        height: 66,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: CustomColors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39F21B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Status Active",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: CustomColors.darkGrey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${context.watch<HomePageProvider>().mainPageBucket[widget.i]['activeItems']}",
                                    style: TextStyle(
                                      color: CustomColors.darkGrey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " Items",
                                    style: TextStyle(
                                      color: CustomColors.darkGrey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BucketPage(bucket: context.watch<HomePageProvider>().mainPageBucket[widget.i]),
                            ),
                          );
                        },
                        child: Container(
                          color: Color(
                            int.parse(
                              "FF${context.watch<HomePageProvider>().mainPageBucket[widget.i]['color']}",
                              radix: 16,
                            ),
                          ),
                          width: deviceWidth - 48,
                          height: (deviceWidth - 66 - 48) / 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (context.watch<HomePageProvider>().mainPageBucket[widget.i]['activeItems'] > 0)
                                Container(
                                  width: (deviceWidth - 66 - 48) / 4,
                                  height: (deviceWidth - 66 - 48) / 4,
                                  decoration: BoxDecoration(
                                    color: CustomColors.white,
                                    borderRadius: BorderRadius.circular(9.2),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][0]['itemFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][0]['thumbnailImage']}"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (context.watch<HomePageProvider>().mainPageBucket[widget.i]['activeItems'] > 1)
                                Container(
                                  width: (deviceWidth - 66 - 48) / 4,
                                  height: (deviceWidth - 66 - 48) / 4,
                                  decoration: BoxDecoration(
                                    color: CustomColors.white,
                                    borderRadius: BorderRadius.circular(9.2),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][1]['itemFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][1]['thumbnailImage']}",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (context.watch<HomePageProvider>().mainPageBucket[widget.i]['activeItems'] > 2)
                                Container(
                                  width: (deviceWidth - 66 - 48) / 4,
                                  height: (deviceWidth - 66 - 48) / 4,
                                  decoration: BoxDecoration(
                                    color: CustomColors.white,
                                    borderRadius: BorderRadius.circular(9.2),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][2]['itemFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][2]['thumbnailImage']}"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (context.watch<HomePageProvider>().mainPageBucket[widget.i]['activeItems'] > 3)
                                Stack(
                                  children: [
                                    Container(
                                      width: (deviceWidth - 66 - 48) / 4,
                                      height: (deviceWidth - 66 - 48) / 4,
                                      decoration: BoxDecoration(
                                        color: CustomColors.white,
                                        borderRadius: BorderRadius.circular(9.2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              "$s3URL${context.watch<HomePageProvider>().user['userFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['bucketFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][3]['itemFolder']}/${context.watch<HomePageProvider>().mainPageBucket[widget.i]['items'][3]['thumbnailImage']}"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          // Gradient
                                          gradient: LinearGradient(
                                            begin: Alignment
                                                .topCenter, // 0deg in CSS corresponds to top to bottom in Flutter
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color.fromRGBO(0, 0, 0, 0.40),
                                              Color.fromRGBO(0, 0, 0, 0.40),
                                            ],
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "+${context.watch<HomePageProvider>().mainPageBucket[widget.i]['activeItems'] - 3}",
                                          style: const TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: (deviceWidth - 104) / 2,
            left: (deviceWidth - 104) / 2,
            child: Transform.translate(
              offset: const Offset(0, -1),
              child: Container(
                width: 104,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.i == 0
                      ? Colors.white
                      : _height > 192
                          ? Colors.white
                          : Color(
                              int.parse("FF${context.read<HomePageProvider>().mainPageBucket[widget.i - 1]["color"]}",
                                  radix: 16),
                            ),
                  border: const Border(
                    left: BorderSide(
                      color: Color(0xFFF2F2F7),
                      width: 1,
                    ),
                    right: BorderSide(
                      color: Color(0xFFF2F2F7),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: Color(0xFFF2F2F7),
                      width: 1,
                    ),
                  ),
                ),
                child: Transform.translate(
                  offset: const Offset(0, -1),
                  child: Container(
                    width: 37,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: (deviceWidth - 104) / 2 - 7,
            top: 3,
            child: Transform.rotate(
              angle: -37,
              child: Container(
                width: 16,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(
                    context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                        ? 0xFF121212
                        : int.parse("FF${context.read<HomePageProvider>().mainPageBucket[widget.i]["color"]}",
                            radix: 16),
                  ),
                  border: const Border(
                    top: BorderSide(
                      color: Color(0xFFF2F2F7),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: (deviceWidth - 104) / 2 - 7,
            top: 3,
            child: Transform.rotate(
              angle: 37,
              child: Container(
                width: 16,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(
                    context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                        ? 0xFF121212
                        : int.parse("FF${context.read<HomePageProvider>().mainPageBucket[widget.i]["color"]}",
                            radix: 16),
                  ),
                  border: const Border(
                    top: BorderSide(
                      color: Color(0xFFF2F2F7),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: (deviceWidth - 80) / 2,
            left: (deviceWidth - 80) / 2,
            top: 0,
            child: Transform.translate(
              offset: const Offset(0, -2),
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Color(
                    context.watch<HomePageProvider>().mainPageBucket.length == widget.i
                        ? 0xFFFFFFFF
                        : int.parse("FF${context.read<HomePageProvider>().mainPageBucket[widget.i]["color"]}",
                            radix: 16),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
