import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/transfer_appbar.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CheckDepositPage extends StatefulWidget {
  const CheckDepositPage({super.key});

  @override
  CheckDepositPageState createState() => CheckDepositPageState();
}

class CheckDepositPageState extends State<CheckDepositPage> {
  File? frontImage;
  File? backImage;
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  String? selectedAccount;

  final Map<String, double> accounts = {
    'Chase Checking 5486': 1200.50,
    'Capital One Savings 4584': 5500.75,
    'Wells Fargo Checking 1234': 800.00,
    'Bank of America Savings 5678': 3000.00,
  };

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_amountListener);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _amountListener() {
    final text = _amountController.text;
    if (!text.startsWith('\$')) {
      _amountController.value = _amountController.value.copyWith(
        text: '\$${text.replaceAll('\$', '')}',
        selection:
            TextSelection.collapsed(offset: _amountController.text.length + 1),
      );
    }
  }

  Future<void> pickImage(bool isFront) async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          if (isFront) {
            frontImage = File(pickedFile.path);
          } else {
            backImage = File(pickedFile.path);
          }
        });
      }
    } catch (e, stackTrace) {
      SnackbarService.show('Error picking image', isError: true);
      LogUtil.error('Error picking image', error: e, stackTrace: stackTrace);
    }
  }

  void submitDeposit() {
    if (selectedAccount == null ||
        frontImage == null ||
        backImage == null ||
        _amountController.text.isEmpty) {
      SnackbarService.show('Please Complete all necessary fields',
          isError: true);
      return;
    }
    _showConfirmDepositDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customGreen,
      appBar: TransferAppBar(),
      body: ListView(
        children: [
          _uploadCheckImages(),
          _amountAndAccountSelectionContainer(),
          _submitButton(),
        ],
      ),
    );
  }

  Widget _uploadCheckImages() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(30), 30, 0),
      padding: EdgeInsets.fromLTRB(
          Scale.x(20), Scale.x(15), Scale.x(20), Scale.x(25)),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            spreadRadius: Scale.x(5),
            blurRadius: Scale.x(7),
            offset: Offset(0, Scale.x(3)),
          ),
        ],
        borderRadius: BorderRadius.circular(Scale.x(15)),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: Scale.x(15)),
            child: Text(
              'Upload Check',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.darkerGrey,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: Scale.x(1.5),
                fontSize: FontSizes.statements,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _imagePickerContainer(true, frontImage, 'Front'),
              SizedBox(height: Scale.x(25)),
              _imagePickerContainer(false, backImage, 'Back'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePickerContainer(bool isFront, File? image, String label) {
    return GestureDetector(
      onTap: () => pickImage(isFront),
      child: Container(
        height: Scale.x(140),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Scale.x(10)),
          color: AppColors.grey,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_sharp, color: AppColors.navy),
                  SizedBox(height: Scale.x(8)),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: Scale.x(14),
                      color: AppColors.navy,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(Scale.x(10)),
                child: Image.file(image, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _amountAndAccountSelectionContainer() {
    final accountList = accounts.keys.toList();

    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      padding: EdgeInsets.fromLTRB(
          Scale.x(20), Scale.x(15), Scale.x(20), Scale.x(15)),
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
        children: [
          _amountInputField(),
          const Divider(color: Colors.grey),
          _accountSelectionField(accountList),
        ],
      ),
    );
  }

  Widget _amountInputField() {
    return Padding(
      padding: EdgeInsets.only(bottom: Scale.x(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Confirm Amount',
              style: TextStyle(
                fontFamily: 'Open Sans',
                color: Color.fromARGB(255, 99, 99, 99),
                fontSize: Scale.x(16),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: '\$0.00',
                hintStyle: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: Scale.x(16),
                  color: AppColors.navy,
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: Scale.x(16),
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountSelectionField(List<String> accountList) {
    return Padding(
      padding: EdgeInsets.only(top: Scale.x(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'To',
            style: TextStyle(
              fontFamily: 'Open Sans',
              color: Color.fromARGB(255, 99, 99, 99),
              fontSize: Scale.x(16),
            ),
          ),
          GestureDetector(
            onTap: () => _showSelectionPopup(context, accountList),
            child: Row(
              children: [
                Text(
                  selectedAccount ?? 'Select Account',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: Scale.x(16),
                    color: AppColors.navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.navy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectionPopup(BuildContext context, List<String> items) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                Scale.x(10), Scale.x(30), Scale.x(10), Scale.x(30)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Account:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    color: AppColors.navy,
                    fontSize: Scale.x(18),
                  ),
                ),
                SizedBox(
                  height: Scale.x(150),
                  width: double.maxFinite,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          splashColor: AppColors.customGreen,
                          title: Text(
                            items[index],
                            style: const TextStyle(color: AppColors.darkerGrey),
                          ),
                          onTap: () {
                            setState(() {
                              selectedAccount = items[index];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: Scale.x(30)),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(AppColors.navy),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(AppColors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _submitButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      child: ElevatedButton(
        onPressed: submitDeposit,
        style: ButtonStyle(
          minimumSize:
              WidgetStateProperty.all<Size>(const Size(double.infinity, 52)),
          backgroundColor: WidgetStateProperty.all<Color>(
              const Color.fromARGB(255, 3, 63, 80)),
          foregroundColor: WidgetStateProperty.all<Color>(AppColors.white),
          textStyle: WidgetStateProperty.all<TextStyle>(
            TextStyle(
              fontFamily: 'Open Sans',
              fontSize: Scale.x(20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: Scale.x(16),
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  void _showConfirmDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          child: Padding(
            padding: EdgeInsets.all(Scale.x(30)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: Scale.x(20)),
                  child: Text(
                    'Confirm Check Deposit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      color: AppColors.navy,
                      fontSize: Scale.x(18),
                    ),
                  ),
                ),
                _buildDialogRow('Amount:', _amountController.text),
                _buildDialogRow('To:', selectedAccount ?? 'Not Selected'),
                SizedBox(height: Scale.x(20)),
                _buildDialogActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Scale.x(8)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Open Sans',
                color: Color.fromARGB(255, 99, 99, 99),
                fontSize: Scale.x(16),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Open Sans',
              color: AppColors.navy,
              fontSize: Scale.x(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Scale.x(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: Scale.x(10), left: Scale.x(10)),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(AppColors.white),
                  foregroundColor:
                      WidgetStateProperty.all<Color>(AppColors.navy),
                  side: WidgetStateProperty.all(
                      BorderSide(color: AppColors.navy, width: 1)),
                ),
                onPressed: () {
                  NavListeners.instance.popTilIndexRoute(1, context);
                },
                child: const Text('Cancel'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: Scale.x(10), left: Scale.x(10)),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(AppColors.green),
                  foregroundColor:
                      WidgetStateProperty.all<Color>(AppColors.white),
                ),
                onPressed: () {
                  SnackbarService.show('Check Deposit Successful',
                      isError: false);
                  NavListeners.instance.popTilIndexRoute(1, context);
                },
                child: const Text('Deposit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
