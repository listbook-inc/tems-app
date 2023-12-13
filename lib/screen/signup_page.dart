import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/screen/home_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/instance.dart';
import 'package:listbook/widgets/signup/new_template_dialog.dart';

class SignUpPage extends StatefulWidget {
  final String? idToken;

  const SignUpPage({super.key, required this.idToken});

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  late Server _server;
  dynamic _categories;
  bool isLoading = true;
  bool isError = false;

  final storage = Instance.getInstanceStorage();

  List<int> selectList = [];

  _getAllDefaultCategories() async {
    await _server.getDefaultCategories().then((value) {
      print(value.data);
      setState(() {
        _categories = value.data;
        isLoading = false;
      });
    }).catchError((err) {
      print(err);
      setState(() {
        isError = true;
      });
    });
  }

  @override
  void initState() {
    _server = Server(context);
    _getAllDefaultCategories();
    super.initState();
  }

  Future<void> onRefresh() async {
    setState(() {
      _categories = null;
      isLoading = true;
      isError = false;
      selectList = [];
    });
    await _getAllDefaultCategories();
  }

  void selectBuckets(int bucketIdx) {
    final findIdx = selectList.indexWhere((element) => element == bucketIdx);

    if (findIdx == -1 && selectList.length == 3) {
      // showModalBottomSheet(
      //   isScrollControlled: true,
      //   backgroundColor: CustomColors.black,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(20.0),
      //       topRight: Radius.circular(20.0),
      //     ),
      //   ),
      //   context: context,
      //   builder: (context) {
      //     return const PaymentBottomSheet();
      //   },
      // );
      return;
    }

    setState(() {
      if (findIdx == -1) {
        selectList.add(bucketIdx);
      } else {
        selectList.removeAt(findIdx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: AppBar(
        backgroundColor: CustomColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        Translations.of(context)?.trans("select_bucket_title") ??
                            "What kind of bucket do you\nwant to add first?",
                        style: TextStyle(
                          fontSize: 21,
                          fontFamily: Translations.of(context)?.trans("point_font"),
                          fontWeight: FontWeight.w500,
                          color: CustomColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 33),
                if (isError)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        Translations.of(context)?.trans("no_category_message") ?? "Category Not Found, Try Again",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: CustomColors.red,
                        ),
                      )
                    ],
                  ),
                if (isLoading)
                  CircularProgressIndicator(
                    color: CustomColors.black,
                    strokeWidth: 2,
                  ),
                if (_categories != null)
                  SizedBox(
                    height: ((((deviceWidth - 46) / 2) + 16) * ((_categories['buckets'].length + 1) / 2).ceil()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _categories['buckets'].length + 1,
                        itemBuilder: (context, index) {
                          if (_categories['buckets'].length == index) {
                            return Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return NewTemplateDialog(
                                        onSuccess: (name, security) async {
                                          await _server.makeBucket(name).then((value) {
                                            setState(() {
                                              if (selectList.length < 3) {
                                                selectList.add(_categories['buckets'].length);
                                              }
                                              _categories['buckets'].add(value.data);
                                            });
                                          });
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: CustomColors.black),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.plus,
                                    weight: 1.8,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: _categories['buckets'][index]['bucketFolder'] != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            "$s3URL${_categories['buckets'][index]['bucketFolder']}/${_categories['buckets'][index]['bucketThumbnail']}",
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : DecorationImage(
                                          image: NetworkImage(
                                            "$s3URL${_categories['bucketFolder']}/${_categories['buckets'][index]['thumbnailImage']}",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: CustomColors.grey,
                                ),
                              ),
                              if (selectList.contains(index))
                                Positioned(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: CustomColors.gradient,
                                        stops: const [0, 0.7812],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              if (selectList.contains(index))
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CustomColors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      selectBuckets(index);
                                    },
                                    child: Container(),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12.5,
                                left: 12.5,
                                child: SizedBox(
                                  width: deviceWidth / 2 - 46,
                                  child: Text(
                                    _categories['buckets'][index]['bucketName'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: Translations.of(context)?.trans("point_font"),
                                      fontWeight: FontWeight.w500,
                                      color: CustomColors.white,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: CustomColors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.center,
                                  child: _categories['buckets'][index]['bucketFolder'] != null
                                      ? Icon(
                                          Icons.add,
                                          color: CustomColors.black,
                                        )
                                      : SvgPicture.asset(
                                          "assets/default_bucket/${_categories['buckets'][index]['bucketName']}.svg",
                                        ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Material(
                        color: selectList.length >= 3 ? CustomColors.black : CustomColors.lightGrey,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          highlightColor: selectList.length >= 3 ? null : CustomColors.lightGrey,
                          splashColor: selectList.length >= 3 ? null : CustomColors.lightGrey,
                          onTap: () async {
                            List<String> defaultBuckets = [];
                            List<String> bucketNames = [];
                            List<String> bucketImages = [];
                            List<String> bucketThumbnails = [];

                            print(widget.idToken);

                            for (var idx in selectList) {
                              final data = _categories['buckets'][idx];
                              print(data);
                              if (data['bucketFolder'] == null) {
                                defaultBuckets.add(data['bucketName']);
                              } else {
                                bucketNames.add(data['bucketName']);
                                bucketImages.add(data['bucketImage']);
                                bucketThumbnails.add(data['bucketThumbnail']);
                              }
                            }

                            final formData = FormData.fromMap(
                              {
                                "selectBuckets": defaultBuckets,
                                "bucketNames": bucketNames,
                                "bucketImages": bucketImages,
                                "bucketThumbnails": bucketThumbnails,
                              },
                            );

                            await _server.signUp(widget.idToken, formData, context).then((value) async {
                              await storage.write(key: accessTokenKey, value: value.data['accessToken']);
                              await storage.write(key: refreshTokenKey, value: value.data['refreshToken']);
                              await storage.write(key: expireKey, value: value.data['expiredAt'].toString());

                              Future.delayed(Duration.zero, () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                  (route) => false,
                                );
                              });
                            }).catchError((err) {
                              print(err);
                              showOkAlertDialog(
                                context: context,
                                title: "Faild Sign Up",
                                message: "Faild Sign Up with Server Error",
                              ).then(
                                (value) => Navigator.pop(context),
                              );
                            });
                          },
                          child: Container(
                            width: deviceWidth,
                            height: 53,
                            alignment: Alignment.center,
                            child: Text(
                              Translations.of(context)?.trans("select") ?? "Select",
                              style: TextStyle(
                                fontSize: 17,
                                color: selectList.length >= 3 ? CustomColors.white : CustomColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: CustomColors.white,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            List<String> defaultBuckets = [];
                            List<String> bucketNames = [];
                            List<String> bucketImages = [];
                            List<String> bucketThumbnails = [];

                            defaultBuckets.add("Books");
                            defaultBuckets.add("Bags");
                            defaultBuckets.add("Coffee");

                            final formData = FormData.fromMap(
                              {
                                "selectBuckets": defaultBuckets,
                                "bucketNames": bucketNames,
                                "bucketImages": bucketImages,
                                "bucketThumbnails": bucketThumbnails,
                              },
                            );

                            await _server.signUp(widget.idToken, formData, context).then((value) async {
                              await storage.write(key: accessTokenKey, value: value.data['accessToken']);
                              await storage.write(key: refreshTokenKey, value: value.data['refreshToken']);
                              await storage.write(key: expireKey, value: value.data['expiredAt'].toString());

                              Future.delayed(Duration.zero, () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                  (route) => false,
                                );
                              });
                            }).catchError((err) {
                              print(err);
                              showOkAlertDialog(
                                context: context,
                                title: "Faild Sign Up",
                                message: "Faild Sign Up with Server Error",
                              ).then(
                                (value) => Navigator.pop(context),
                              );
                            });
                          },
                          child: Container(
                            width: deviceWidth,
                            height: 53,
                            alignment: Alignment.center,
                            child: Text(
                              Translations.of(context)?.trans("skip") ?? "Skip",
                              style: TextStyle(
                                fontSize: 17,
                                color: CustomColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
