import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:listbook/screen/item_manage_detail_page.dart';
import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class SearchPage extends StatefulWidget {
  final Function() refresh;

  const SearchPage({super.key, required this.refresh});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Server _server;
  final _controller = TextEditingController();
  final searchFocus = FocusNode();

  Future<dynamic>? _searchResult;

  Future<void> _search() async {
    setState(() {
      _searchResult = _server.searchItemByName(_controller.text);
    });
  }

  @override
  void initState() {
    super.initState();
    _server = Server(context);
    _controller.addListener(_search);
    _search();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColors.white,
        surfaceTintColor: Colors.transparent,
        title: _buildSearchBar(deviceWidth),
      ),
      body: FutureBuilder(
        future: _searchResult,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: CustomColors.black,
              ),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorWidget();
          } else {
            return _buildResultList(snapshot.data.data);
          }
        },
      ),
    );
  }

  Widget _buildSearchBar(double deviceWidth) {
    return Stack(
      children: [
        Container(
          height: 53,
          width: deviceWidth - 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: CustomColors.lightGrey,
          ),
          child: TextField(
            controller: _controller,
            focusNode: searchFocus,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: Translations.of(context)?.trans("search_items") ?? "Search items",
              hintStyle: TextStyle(fontSize: 17, color: CustomColors.grey, fontWeight: FontWeight.w400),
              contentPadding: const EdgeInsets.only(left: 50, right: 16),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 17),
          ),
        ),
        Positioned(
          left: 14,
          top: 0,
          bottom: 0,
          child: SvgPicture.asset("assets/search.svg"),
        ),
        Positioned(
          right: 14,
          top: 16,
          bottom: 16,
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: CustomColors.white,
            child: InkWell(
              onTap: () => _controller.clear(),
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 21,
                height: 21,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: CustomColors.grey2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        Translations.of(context)?.trans("server_error") ?? "Server Error",
        style: TextStyle(color: CustomColors.red, fontSize: 17),
      ),
    );
  }

  Widget _buildResultList(dynamic data) {
    if (data.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.only(top: 120),
          child: Column(
            children: [
              Icon(CupertinoIcons.search, size: 45, color: CustomColors.grey),
              const SizedBox(height: 20),
              Text(
                Translations.of(context)?.trans("no_item_message") ?? "No items yet.\nRegister and use an item to see.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: CustomColors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: data.length,
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemBuilder: (context, index) {
        return _buildListItem(data[index]);
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
    );
  }

  Widget _buildListItem(dynamic itemData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemManageDetailPage(
                item: itemData,
                refresh: () {
                  _search();
                  widget.refresh();
                },
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 73,
                height: 73,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CustomColors.lightGrey, width: 1),
                  image: DecorationImage(
                    image: NetworkImage(
                      "$s3URL${itemData['userFolder']}/${itemData['bucketFolder']}/${itemData['itemFolder']}/${itemData['mainItemThumbnail']}",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 19),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: SizedBox(
                    height: 72,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemData['itemName'],
                          style: TextStyle(fontSize: 17, color: CustomColors.darkGrey, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              itemData['brand'],
                              style: TextStyle(fontSize: 13, color: CustomColors.grey, fontWeight: FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${itemData['dayOfUsage']} ${itemData['dayOfUsage'] == 1 ? Translations.of(context)?.trans("day") ?? 'Day' : Translations.of(context)?.trans("days") ?? 'Days'}",
                              style: TextStyle(fontSize: 13, color: CustomColors.grey, fontWeight: FontWeight.w400),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
