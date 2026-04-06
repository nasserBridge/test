import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/plaid_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({super.key});

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  @override
  Widget build(BuildContext context) {
    final PlaidController plaidController = Get.put(PlaidController());

    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 40, left: 90, right: 90),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Obx(() {
        return ElevatedButton(
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0.0),
            backgroundColor:
                WidgetStateColor.resolveWith((states) => AppColors.white),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              return plaidController.isProcessing.value
                  ? const Color.fromARGB(
                      255, 181, 181, 181) // Grey when processing
                  : AppColors.navy; // Default color
            }),
          ),
          onPressed: plaidController.isProcessing.value
              ? null
              : () async {
                  plaidController.plaidConnection();
                },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 45,
                color: AppColors.navy,
              ),
              SizedBox(
                height: 10,
              ),
              Text('Add Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ))
            ],
          ),
        );
      }),
    );
  }
}
