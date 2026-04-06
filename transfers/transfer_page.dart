import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/between_accounts.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/billpay_page.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/checkdeposit_page.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/peer_to_peer.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransfersPage extends StatefulWidget {
  const TransfersPage({super.key});

  @override
  State<TransfersPage> createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  String _activity = 'History';
  final _navController = Get.put(NavListeners());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customGreen,
      body: Stack(
        children: [
          pageWidgets(),
          Obx(() =>
              _navController.demoBool.value ? _customPopup() : SizedBox()),
        ],
      ),
    );
  }

  Widget _customPopup() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5), // Dark overlay background
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * Scale.x(0.70),
        padding: EdgeInsets.all(Scale.x(20)),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(Scale.x(15)),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 5)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            Text(
              "Money Movement Features",
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: Scale.x(18),
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Scale.x(30)),
            Padding(
              padding: EdgeInsets.only(left: Scale.x(2)),
              child: Text(
                "Under construction.",
                style: TextStyle(color: Colors.white70, fontSize: Scale.x(16)),
                textAlign: TextAlign.start, // Align text to the left
              ),
            ),
            SizedBox(height: Scale.x(20)),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align button to the right
              children: [
                TextButton(
                  onPressed: () {
                    _navController.demoBool.value = false;
                  },
                  child: Text("Try Demo",
                      style: TextStyle(
                          color: Colors.greenAccent, fontSize: Scale.x(16))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget pageWidgets() {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [selectTransfer(), activity()],
    );
  }

  Widget selectTransfer() {
    final transfer = [
      'Transfer',
      Icons.sync_alt_outlined,
      'Between My Accounts'
    ];
    final bridge = ['Bridge', Icons.social_distance, 'Send/Request Money'];
    final billpay = ['Bill Pay', Icons.payments, 'Pay Now or Schedule'];
    final checkdeposit = [
      'Check Deposit',
      Icons.picture_in_picture,
      'Digital Deposit'
    ];
    final types = [transfer, billpay, bridge, checkdeposit];
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Scale.x(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            spreadRadius: Scale.x(5),
            blurRadius: Scale.x(7),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: rowOfTransfers(types[0], types[1], 1)),
            Container(
                width: Scale.x(1),
                height: double.infinity,
                margin: EdgeInsets.symmetric(vertical: Scale.x(15)),
                color: const Color.fromARGB(255, 212, 212, 212)),
            Expanded(child: rowOfTransfers(types[2], types[3], 2)),
          ],
        ),
      ),
    );
  }

  Widget rowOfTransfers(List type1, List type2, num order) {
    return Column(
      children: [
        transferType(
            type1[0] as String, type1[1] as IconData?, type1[2] as String),
        Container(
            width: double.infinity,
            height: Scale.x(1),
            margin: EdgeInsets.only(
                left: order == 1 ? Scale.x(15) : 0,
                right: order == 1 ? 0 : Scale.x(15)),
            color: const Color.fromARGB(255, 212, 212, 212)),
        transferType(
            type2[0] as String, type2[1] as IconData?, type2[2] as String),
      ],
    );
  }

  Widget transferType(String type, IconData? icon, String description) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          NavListeners.instance.isOnMain(false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return type == 'Transfer'
                  ? BetweenAccounts()
                  : type == 'Bridge'
                      ? PeerToPeer()
                      : type == 'Bill Pay'
                          ? BillPayPage()
                          : CheckDepositPage();
            }),
          );
        },
        child: Container(
          width: double.infinity,
          color: AppColors.white,
          margin: EdgeInsets.fromLTRB(0, Scale.x(17), 0, Scale.x(19)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: Scale.x(37), color: AppColors.navy),
              SizedBox(height: Scale.x(6)),
              Text(
                type,
                style: TextStyle(
                  color: Color.fromARGB(239, 100, 100, 100),
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: Scale.x(1.5),
                  fontSize: FontSizes.statements,
                ),
              ),
              SizedBox(height: Scale.x(8)),
              Text(
                description,
                style: TextStyle(
                    fontFamily: 'Open Sans',
                    color: Color.fromARGB(255, 99, 99, 99),
                    fontSize: FontSizes.statementMonth),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget activity() {
    final transactionsHistory = [
      [
        'Bridge',
        Icons.social_distance,
        'Sent Money To Kim',
        '\$80',
        '01/09/2025'
      ],
      [
        'Transfer',
        Icons.sync_alt_outlined,
        'From Acc 8012 To Acc 3293',
        '\$20',
        '01/02/2025'
      ],
      [
        'Bridge',
        Icons.social_distance,
        'Received Money From Joe',
        '\$120',
        '12/17/2024'
      ],
      ['Bill Pay', Icons.payments, 'T-Mobile Bill', '\$99', '10/18/2024'],
    ];

    final transactionsScheduled = [
      [
        'Bridge',
        Icons.social_distance,
        'Send Money To Kim',
        '\$80',
        'Scheduled 06/09/2025'
      ],
      [
        'Transfer',
        Icons.sync_alt_outlined,
        'From Acc 8012 To Acc 3293',
        '\$20',
        'Scheduled 08/02/2025'
      ],
      [
        'Bridge',
        Icons.social_distance,
        'Request Money From Joe',
        '\$120',
        'Scheduled 04/17/2024'
      ],
      [
        'Bill Pay',
        Icons.payments,
        'T-Mobile Bill',
        '\$99',
        'Scheduled 04/18/2024'
      ],
    ];

    final transactions =
        _activity == 'History' ? transactionsHistory : transactionsScheduled;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
          Scale.x(30), Scale.x(40), Scale.x(30), Scale.x(50)),
      padding: EdgeInsets.fromLTRB(
          Scale.x(15), Scale.x(15), Scale.x(15), Scale.x(10)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Scale.x(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            spreadRadius: Scale.x(5),
            blurRadius: Scale.x(7),
            offset: Offset(0, Scale.x(3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: TextStyle(
              color: AppColors.darkerGrey,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              letterSpacing: Scale.x(1.5),
              fontSize: FontSizes.statements,
            ),
          ),
          SizedBox(height: Scale.x(12)),
          transferSpeed(),
          SizedBox(height: Scale.x(18)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  transaction(
                    transactions[index][0] as String, // Bill Pay or Bridge
                    transactions[index][1] as IconData?, // Icon
                    transactions[index][2] as String, // Description
                    transactions[index][3] as String, // Amount
                    transactions[index][4] as String, // Date
                  ),
                  index == transactions.length - 1
                      ? SizedBox.shrink()
                      : const Divider(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget transferSpeed() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.navy, // Border color
          width: Scale.x(1.0), // Border width
        ),
        borderRadius: BorderRadius.circular(Scale.x(10)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Instant Option
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activity = 'History'; // Update state
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _activity == 'History'
                        ? AppColors
                            .navy //const Color.fromARGB(255, 49, 145, 124)
                        : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Scale.x(10)),
                      bottomLeft: Radius.circular(Scale.x(10)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'History',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        color: _activity == 'History'
                            ? AppColors.white
                            : _activity == 'Scheduled'
                                ? AppColors.navy
                                : AppColors.darkerGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_activity == '')
              Container(
                width: 1, // Thin divider
                height: double.infinity,
                color: AppColors.navy, // Divider color
              ),
            // Schedule Option
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activity = 'Scheduled'; // Update state
                  });
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, Scale.x(2), 0, Scale.x(2)),
                  decoration: BoxDecoration(
                    color: _activity == 'Scheduled'
                        ? AppColors
                            .navy //const Color.fromARGB(255, 49, 145, 124)
                        : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Scale.x(10)),
                      bottomRight: Radius.circular(Scale.x(10)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Scheduled',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        color: _activity == 'Scheduled'
                            ? AppColors.white
                            : _activity == 'History'
                                ? AppColors.navy
                                : AppColors.darkerGrey,
                        fontSize: Scale.x(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transaction(String type, IconData? icon, String description,
      String amount, String date) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Scale.x(5), Scale.x(2), 0, Scale.x(2)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        color: AppColors.green,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: Scale.x(1.5),
                        fontSize: FontSizes.statements,
                      ),
                    ),
                    SizedBox(width: Scale.x(10)),
                    Icon(icon, size: Scale.x(25), color: AppColors.navy),
                  ],
                ),
                SizedBox(height: Scale.x(5)),
                Text(
                  date, // Use the passed date here
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    color: Color.fromARGB(255, 99, 99, 99),
                    fontSize: FontSizes.statementMonth,
                  ),
                ),
                SizedBox(height: Scale.x(5)),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    color: Color.fromARGB(255, 99, 99, 99),
                    fontSize: FontSizes.statementMonth,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: AppColors.darkerGrey,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              letterSpacing: Scale.x(1.5),
              fontSize: Scale.x(20),
            ),
          ),
        ],
      ),
    );
  }
}
