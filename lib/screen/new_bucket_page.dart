import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listbook/screen/bucket_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';
import 'package:listbook/utils/instance.dart';
import 'package:listbook/widgets/signup/new_template_dialog.dart';

class NewBucketPage extends StatefulWidget {
  final Function() refresh;

  const NewBucketPage({super.key, required this.refresh});

  @override
  State<NewBucketPage> createState() => _NewBucketPageState();
}

class _NewBucketPageState extends State<NewBucketPage> {
  late Server _server;
  dynamic _categories;
  bool isLoading = true;
  bool isError = false;
  bool isSecurity = false;

  final storage = Instance.getInstanceStorage();

  int selectIdx = -1;

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
      selectIdx = -1;
    });
    await _getAllDefaultCategories();
  }

  void selectBuckets(int bucketIdx) {
    setState(() {
      if (selectIdx == bucketIdx) {
        selectIdx = -1;
      } else {
        selectIdx = bucketIdx;
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
                        Translations.of(context)?.trans("select_bucket_title") ?? "",
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
                        Translations.of(context)?.trans("category_not_found") ?? "",
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
                                              isSecurity = security;
                                              selectIdx = _categories['buckets'].length;
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
                              if (selectIdx == index)
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
                              if (selectIdx == index)
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
                        color: selectIdx != -1 ? CustomColors.black : CustomColors.lightGrey,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          highlightColor: selectIdx != -1 ? null : CustomColors.lightGrey,
                          splashColor: selectIdx != -1 ? null : CustomColors.lightGrey,
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            if (selectIdx != -1) {
                              final newBucket = _categories["buckets"][selectIdx];
                              _server
                                  .uploadBucket(
                                newBucket['bucketName'],
                                newBucket['bucketFolder'] == null ? "DEFAULT" : "RANDOM",
                                isSecurity,
                              )
                                  .then(
                                (value) {
                                  widget.refresh();
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BucketPage(
                                        bucket: value.data,
                                        refresh: widget.refresh,
                                      ),
                                    ),
                                  );
                                },
                              );
                              print(selectIdx);
                              print(newBucket);
                            }
                          },
                          child: Container(
                            width: deviceWidth,
                            height: 53,
                            alignment: Alignment.center,
                            child: Text(
                              Translations.of(context)?.trans("select") ?? "Select",
                              style: TextStyle(
                                fontSize: 17,
                                color: selectIdx != -1 ? CustomColors.white : CustomColors.black,
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
