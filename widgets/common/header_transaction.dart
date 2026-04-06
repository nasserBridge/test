import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/common_widgets/popup_yes_no.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/repositories/remove_account_repository.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:bridgeapp/src/utils/scale.dart'; // Make sure this is imported
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderTransactions extends StatefulWidget implements PreferredSizeWidget {
  final String institution;
  final String accountID;
  const HeaderTransactions({
    super.key,
    required this.institution,
    required this.accountID,
  });

  @override
  State<HeaderTransactions> createState() => _HeaderTransactionsState();

  @override
  Size get preferredSize => Size.fromHeight(Scale.x(kToolbarHeight));
}

class _HeaderTransactionsState extends State<HeaderTransactions> {
  final _repoRemove = Get.put(RemoveAccountRepo());
  bool _appBar = true;

  @override
  Widget build(BuildContext context) {
    return _appBar == false
        ? const SizedBox.shrink()
        : AppBar(
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () {
                setState(() => _appBar = false);
                Navigator.of(context).pop();
                NavListeners.instance.isOnMain(true);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: Scale.x(22),
              ),
            ),
            title: Text(
              widget.institution,
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'Raleway',
                fontSize: Scale.x(FontSizes.tHeader),
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              PopupMenuButton<String>(
                constraints: BoxConstraints(maxWidth: Scale.x(140)),
                color: AppColors.white,
                surfaceTintColor: AppColors.navy,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Option 1',
                    child: Text(
                      'Remove Account',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        letterSpacing: Scale.x(1),
                        fontSize: Scale.x(12),
                      ),
                    ),
                    onTap: () {
                      dialogBox();
                    },
                  ),
                  PopupMenuItem<String>(
                    value: 'Option 2',
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        letterSpacing: Scale.x(1),
                        fontSize: Scale.x(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  void dialogBox() {
    PopupYesNo.showInfoDialog(
      context,
      mainText: 'Are you sure you want to delete this account?',
      onYesPressed: () {
        _repoRemove.removeaccount(widget.accountID);
        NavListeners.instance.popTilIndexRoute(0, context);
      },
    );
  }
}
