import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:listbook/screen/new_bucket_page.dart';

import 'package:listbook/server/server.dart';
import 'package:listbook/translation.dart';
import 'package:listbook/utils/colors.dart';

class PaymentBottomSheet extends StatefulWidget {
  final Function() refresh;
  final String redirect;
  final Function()? redirectMethod;

  const PaymentBottomSheet({
    super.key,
    required this.refresh,
    required this.redirect,
    required this.redirectMethod,
  });

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String _trial = "yearly";

  bool _isSandbox = false;

  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // bool _isAvailable = false;
  bool _isLoading = false;
  late Server _server;

  ProductDetails? yearly;
  ProductDetails? monthly;

  _initialize() async {
    if (Platform.isIOS) {
      bool isAvailable = await _iap.isAvailable();
      if (isAvailable) {
        Set<String> ids;
        if (Platform.isIOS) {
          ids = {'TEMS.UNLOCK.MONTHLY', 'TEMS.UNLOCK.YEARLY'};
        } else {
          ids = {'monthly_tems_pro', 'yearly-tems-pro'};
        }
        ProductDetailsResponse response = await _iap.queryProductDetails(ids);
        for (var i in response.productDetails) {
          print(i);
        }

        if (response.notFoundIDs.isEmpty) {
          for (var i = 0; i < response.productDetails.length; i++) {
            print(response.productDetails[i].id);
          }
          setState(() {
            _products = response.productDetails;
            yearly = response.productDetails.firstWhere((element) => element.id == 'TEMS.UNLOCK.YEARLY');
            monthly = response.productDetails.firstWhere((element) => element.id == 'TEMS.UNLOCK.MONTHLY');
          });
        }
      }

      if (Platform.isIOS) {
        var transaction = await SKPaymentQueueWrapper().transactions();
        for (var skPaymentTransactionWrapper in transaction) {
          SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
        }
      }

      const method = MethodChannel("com.example.app/sandbox");
      final bool isSandboxEnv = await method.invokeMethod('isSandbox');

      print("========isSandbox========");
      print(_isSandbox);
      print("========isSandbox========");

      setState(() {
        // _isAvailable = isAvailable;
        _isSandbox = isSandboxEnv;
      });
    } else {
      bool isAvailable = await _iap.isAvailable();
      print("======isAcailable=====");
      print(isAvailable);
      print("======isAcailable=====");
      if (isAvailable) {
        Set<String> ids = {
          'monthly_tems_pro',
          // 'tems_unlock',
        };
        ProductDetailsResponse response = await _iap.queryProductDetails(ids);
        for (var i in response.productDetails) {
          print(i.id);
          print(i.title);
          print(i.description);
          print(i.price);
          print(i.rawPrice);
        }

        if (response.notFoundIDs.isEmpty) {
          print(response.productDetails);
          var price = 0;
          var idx = -1;

          for (var i = 0; i < response.productDetails.length; i++) {
            if (price < response.productDetails[i].rawPrice) {
              idx = i;
            }
          }

          setState(() {
            _products = response.productDetails;
            yearly = response.productDetails[idx];
            monthly = response.productDetails[1 - idx];
          });
        } else {
          showOkAlertDialog(
            context: context,
            title: 'Can\'t found products',
            message: response.notFoundIDs.toString(),
          );
        }
      }

      if (Platform.isIOS) {
        var transaction = await SKPaymentQueueWrapper().transactions();
        for (var skPaymentTransactionWrapper in transaction) {
          SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
        }
      }

      print("========isSandbox========");
      print(_isSandbox);
      print("========isSandbox========");

      setState(() {
        // _isAvailable = isAvailable;
        // _isSandbox = isSandboxEnv;
      });
    }
  }

  Future<void> _buyProduct(ProductDetails prod) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("pendding! ${purchaseDetails.status}");
        setState(() {
          _isLoading = true;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("error! ${purchaseDetails.error}");
          setState(() {
            _isLoading = false;
          });
          showOkAlertDialog(
            context: context,
            title: "결제 실패",
            message: purchaseDetails.error?.message ?? "일시적으로 결제에 실패했습니다.",
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          print("purchased! ${purchaseDetails.status}");
          print("purchased! ${purchaseDetails.productID}");
          print("purchased! ${purchaseDetails.purchaseID}");
          print("purchased! ${purchaseDetails.transactionDate}");
          // print("purchased! ${purchaseDetails.verificationData.serverVerificationData}");

          if (Platform.isIOS) {
            await _server
                .verifyReceipts(purchaseDetails.verificationData.serverVerificationData, true)
                .then((value) async {
              if (widget.redirect == 'BUCKET') {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewBucketPage(refresh: widget.refresh),
                  ),
                );
              } else {
                Navigator.pop(context);
                await widget.redirectMethod!();
              }
            }).catchError((err) {
              if (err is DioException) {
                final e = err;
                showOkAlertDialog(
                  context: context,
                  title: "Faild subscript",
                  message: "Faild to subscription, reason : [${e.response?.data['message']}]",
                );

                return;
              } else {
                showOkAlertDialog(
                  context: context,
                  title: "Faild subscript",
                  message: "Faild to subscription, try again",
                );
                return;
              }
            });
          } else {
            final String packageName = purchaseDetails.verificationData.localVerificationData;
            final String productID = purchaseDetails.productID;
            final String purchaseToken = purchaseDetails.verificationData.serverVerificationData;

            try {
              final json = jsonDecode(packageName);
              print("Purchase Information : $json");
              _server.androidVerifyReceipt({
                "purchaseToken": purchaseToken,
                "productId": productID,
                "packageName": 'com.listbook.tems',
              }).then((value) async {
                if (widget.redirect == 'BUCKET') {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewBucketPage(refresh: widget.refresh),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  await widget.redirectMethod!();
                }
              }).catchError((err) {
                if (err is DioException) {
                  final e = err;
                  showOkAlertDialog(
                    context: context,
                    title: "Faild subscript",
                    message: "Faild to subscription, reason : [${e.response?.data['message']}]",
                  );

                  return;
                } else {
                  showOkAlertDialog(
                    context: context,
                    title: "Faild subscript",
                    message: "Faild to subscription, try again",
                  );
                  return;
                }
              });
            } catch (e) {
              print("type error");
            }
          }
        }
        // if (Platform.isAndroid) {
        //   if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
        //     final InAppPurchaseAndroidPlatformAddition androidAddition =
        //         _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        //     await androidAddition.consumePurchase(purchaseDetails);
        //   }
        // }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails).catchError((err) {
            print(err);
            // showOkAlertDialog(context: context, title: "결제 실패");
          });
        }
      }
    }
  }

  @override
  void initState() {
    print("initstate");
    _server = Server(context);
    _initialize();
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void selectTrial(String trial) {
    setState(() {
      _trial = trial;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: CustomColors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.only(left: 18.78, right: 18.78, top: 109),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    "assets/tems_white.svg",
                    width: 103,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "UNLOCK",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 104),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7.91),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              selectTrial("yearly");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                Translations.of(context)?.trans("yearly") ?? "Yearly",
                                style: TextStyle(
                                  color: _trial == "yearly" ? CustomColors.white : CustomColors.grey3,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              selectTrial("monthly");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                Translations.of(context)?.trans("monthly") ?? "Monthly",
                                style: TextStyle(
                                  color: _trial == "monthly" ? CustomColors.white : CustomColors.grey3,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (_trial == "yearly" && yearly != null)
                      Container(
                        width: deviceWidth,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CustomColors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              yearly!.title,
                              style: TextStyle(
                                color: CustomColors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              yearly!.description,
                              style: TextStyle(
                                color: CustomColors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: CustomColors.white,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  Translations.of(context)?.trans("payment_message1") ?? "Additional item recordable",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: CustomColors.white,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 7),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: CustomColors.white,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  Translations.of(context)?.trans("payment_message2") ??
                                      "Unlimited category bucket generation",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: CustomColors.white,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    if (_trial == "monthly" && monthly != null)
                      Container(
                        width: deviceWidth,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CustomColors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monthly!.title,
                              style: TextStyle(
                                color: CustomColors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              monthly!.description,
                              style: TextStyle(
                                color: CustomColors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: CustomColors.white,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  Translations.of(context)?.trans("payment_message1") ?? "Additional item recordable",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: CustomColors.white,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 7),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: CustomColors.white,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  Translations.of(context)?.trans("payment_message2") ??
                                      "Unlimited category bucket generation",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: CustomColors.white,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 127),
              Material(
                borderRadius: BorderRadius.circular(30),
                color: CustomColors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    if (!_isLoading) {
                      if (_trial == 'monthly') {
                        if (monthly != null) {
                          _buyProduct(monthly!);
                        }
                      } else {
                        if (yearly != null) {
                          _buyProduct(yearly!);
                        }
                      }
                    } else {
                      await showOkAlertDialog(
                        context: context,
                        title: "Payment processing",
                        message: "Payment processing now, Please wait a minute and do not close this bottom sheet",
                      );
                      return;
                    }
                  },
                  child: Container(
                    height: 53,
                    width: deviceWidth,
                    alignment: Alignment.center,
                    child: _products.isEmpty || _isLoading
                        ? CircularProgressIndicator(
                            color: CustomColors.black,
                            strokeWidth: 2,
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${Translations.of(context)?.trans("go_to_pro_version")} ",
                                  style: TextStyle(
                                    fontSize: 17,
                                    wordSpacing: -1,
                                    fontWeight: FontWeight.w500,
                                    color: CustomColors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: _trial == 'monthly' ? monthly!.price : yearly!.price,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: CustomColors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
