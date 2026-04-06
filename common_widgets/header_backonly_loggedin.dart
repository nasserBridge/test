
import 'package:flutter/material.dart';



class HeaderSimple extends StatelessWidget implements PreferredSizeWidget {
  const HeaderSimple({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
        ),
      ),
      title: Image.asset(
        'assets/images/greenBridge.png',
        height: 45,
        fit: BoxFit.contain,
        //scale the image down.
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
