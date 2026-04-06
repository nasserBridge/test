import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/link_tokens/consents_link_token_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/link_tokens/update_link_token_controller.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:get/get.dart';

class ReauthenticateLinkToken extends StatefulWidget {
  final String controllerTag;

  const ReauthenticateLinkToken({
    super.key,
    required this.controllerTag,
  });

  @override
  State<ReauthenticateLinkToken> createState() =>
      _ReauthenticateLinkTokenState();
}

class _ReauthenticateLinkTokenState extends State<ReauthenticateLinkToken> {
  late UpdateLinkTokenController _updateLinkTokenController;
  late ConsentsLinkTokenController _consentLinkTokenController;

  @override
  void initState() {
    super.initState();
    final tag = widget.controllerTag;

    if (Get.isRegistered<UpdateLinkTokenController>(tag: tag)) {
      _updateLinkTokenController =
          Get.find<UpdateLinkTokenController>(tag: tag);
    } else {
      _updateLinkTokenController = Get.put(
        UpdateLinkTokenController(tag: tag),
        tag: tag,
      );
    }

    if (Get.isRegistered<ConsentsLinkTokenController>(tag: tag)) {
      _consentLinkTokenController =
          Get.find<ConsentsLinkTokenController>(tag: tag);
    } else {
      _consentLinkTokenController = Get.put(
        ConsentsLinkTokenController(tag: tag),
        tag: tag,
      );
    }
  }

  @override
  void dispose() {
    _updateLinkTokenController.manuallyDispose();
    _consentLinkTokenController.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _updateLinkTokenController.updateLinkTokenBool.value == true ||
              _consentLinkTokenController.consentsLinkTokenBool.value == true
          ? _reauthenticationFlag()
          : SizedBox.shrink();
    });
  }

  Container _reauthenticationFlag() {
    return Container(
      margin: EdgeInsets.only(
          left: Scale.x(30),
          right: Scale.x(30),
          top: Scale.x(10),
          bottom: Scale.x(50)),
      padding: EdgeInsets.fromLTRB(Scale.x(10), 3, Scale.x(10), Scale.x(3)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Scale.x(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            spreadRadius: Scale.x(5),
            blurRadius: Scale.x(7),
            offset:
                Offset(Scale.x(0), Scale.x(3)), // Offset positions the shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              //SizedBox(width: 10),
              Text(
                'Bank Login Required',
                style: TextStyle(
                  color: Color.fromARGB(238, 220, 47, 47),
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: Scale.x(1.5),
                  fontSize: FontSizes.statements,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        color: Color.fromARGB(238, 220, 47, 47),
                        onPressed: () {
                          _updateLinkTokenController.processNextToken();
                          _consentLinkTokenController.processNextToken();
                        },
                        icon: Icon(
                          Icons.login,
                          size: Scale.x(28),
                        )),
                    SizedBox(
                      width: Scale.x(10),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
