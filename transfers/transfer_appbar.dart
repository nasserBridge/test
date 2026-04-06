import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class TransferAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TransferAppBar({super.key});

  @override
  State<TransferAppBar> createState() => _TransferAppBarState();
  @override
  Size get preferredSize => Size.fromHeight(Scale.x(kToolbarHeight));
}

class _TransferAppBarState extends State<TransferAppBar> {
  bool _appBar = true;

  @override
  Widget build(BuildContext context) {
    return _appBar == false
        ? SizedBox.shrink()
        : PreferredSize(
            preferredSize: Size.fromHeight(Scale.x(65)),
            child: AppBar(
              scrolledUnderElevation: 0,
              leading: IconButton(
                onPressed: () {
                  setState(() => _appBar = false);
                  Navigator.of(context).pop();
                  NavListeners.instance.isOnMain(true);
                  //NavListeners.instance.popTilIndexRoute(1, context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                ),
              ),
              title: Image.asset(
                'assets/images/greenBridge.png',
                height: Scale.x(45),
                fit: BoxFit.contain,
                //scale the image down.
              ),
              centerTitle: true,
              actions: [
                // IconButton( null
                //   // onPressed: null,
                //   // icon: null,
                // ),
              ],
            ),
          );
  }
}
