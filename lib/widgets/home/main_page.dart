import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/provider/home_page_provider.dart';
import 'package:listbook/screen/edit_bucket_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/widgets/home/main_page/animated_card_view.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final Function() refresh;

  const MainPage({super.key, required this.refresh});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _controller = ScrollController();
  late Server _server;

  @override
  void initState() {
    _server = Server(context);
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   Future.delayed(const Duration(milliseconds: 300), () {
    //     _controller.jumpTo(_controller.position.maxScrollExtent);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        96 -
        46;
    // print(safeAreaHeight);
    // print(MediaQuery.of(context).size.height);

    final scrollHeight =
        (context.watch<HomePageProvider>().mainPageBucket.length + 1) * (192 * 0.42) + 15 + (192 * 0.58);

    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: AppBar(
        toolbarHeight: 46,
        leading: Container(
          padding: const EdgeInsets.only(left: 20),
          child: SvgPicture.asset("assets/tems_black.svg"),
        ),
        leadingWidth: 92,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBucketPage(
                        buckets: context.watch<HomePageProvider>().mainPageBucket,
                        deviceWidth: deviceWidth,
                        refresh: widget.refresh,
                      ),
                    ),
                  );
                },
                child: SvgPicture.asset(
                  "assets/edit.svg",
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _controller,
                reverse: true,
                // physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: scrollHeight < safeAreaHeight ? safeAreaHeight : scrollHeight, // 마지막 192는 마지막 Container의 높이
                  // padding: EdgeInsets.only(top: safeAreaHeight / 4),
                  child: Stack(
                    children: [
                      for (var i = 0; i < context.watch<HomePageProvider>().mainPageBucket.length + 1; i++)
                        Positioned(
                          bottom: ((context.watch<HomePageProvider>().mainPageBucket.length) - i) * (192 * 0.42) + 15,
                          child: AnimatedCardView(
                            i: i,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (scrollHeight > safeAreaHeight)
                Positioned(
                  child: Container(
                    height: 100,
                    width: deviceWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.1984, 0.8748],
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
