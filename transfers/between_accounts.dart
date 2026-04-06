import "package:bridgeapp/src/constants/colors.dart";
import "package:bridgeapp/src/common_widgets/snackbar_service.dart";
import "package:bridgeapp/src/features/authentication/screens/transfers/transfer_appbar.dart";
import "package:bridgeapp/src/features/authentication/controllers/nav_listener.dart";
import "package:bridgeapp/src/utils/scale.dart";
import "package:flutter/material.dart";

class BetweenAccounts extends StatefulWidget {
  const BetweenAccounts({super.key});

  @override
  State<BetweenAccounts> createState() => _BetweenAccountsState();
}

class _BetweenAccountsState extends State<BetweenAccounts> {
  String _selectedSpeed = '';
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;

  // Map to track selected accounts for each direction
  final Map<String, String?> _selectedAccounts = {
    'From': null,
    'To': null,
  };

  // Sample account data with balances
  final Map<String, double> _accountBalances = {
    'Citibank Online Checking 0000': 100.00,
    'Bank of America Checking 0000': 100.00,
    'CitiBank Online Savings 1111': 200.00,
    'American Express Credit Card 3333': 410.00,
    'Citibank Online Credit Card 3333': 410.00,
  };

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      final text = _amountController.text;
      if (!text.startsWith('\$')) {
        _amountController.value = _amountController.value.copyWith(
          text:
              '\$${text.replaceAll('\$', '')}', // Remove existing $ to avoid duplication
          selection: TextSelection.collapsed(
            offset:
                _amountController.text.length + 1, // Maintain cursor position
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customGreen,
      appBar: TransferAppBar(),
      body: pageWidgets(),
    );
  }

  Widget pageWidgets() {
    return ListView(
      children: [
        transferSpeed(),
        if (_selectedSpeed == 'Schedule') date(),
        selectAccounts(),
        amount(),
        button(),
      ],
    );
  }

  Widget transferSpeed() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
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
      child: Row(
        children: [
          // Instant Option
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSpeed = 'Instant'; // Update state
                });
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(0, Scale.x(12), 0, Scale.x(12)),
                decoration: BoxDecoration(
                  color: _selectedSpeed == 'Instant'
                      ? const Color.fromARGB(255, 49, 145, 124)
                      : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Scale.x(15)),
                    bottomLeft: Radius.circular(Scale.x(15)),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Instant',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      color: _selectedSpeed == 'Instant'
                          ? AppColors.white
                          : _selectedSpeed == 'Schedule'
                              ? AppColors.navy
                              : AppColors.darkerGrey,
                      fontSize: Scale.x(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_selectedSpeed == '')
            Container(
              width: Scale.x(1), // Thin divider
              height: Scale.x(40),
              color: AppColors.navy, // Divider color
            ),
          // Schedule Option
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSpeed = 'Schedule'; // Update state
                });
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(0, Scale.x(12), 0, Scale.x(12)),
                decoration: BoxDecoration(
                  color: _selectedSpeed == 'Schedule'
                      ? const Color.fromARGB(255, 49, 145, 124)
                      : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Scale.x(15)),
                    bottomRight: Radius.circular(Scale.x(15)),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Schedule',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      color: _selectedSpeed == 'Schedule'
                          ? AppColors.white
                          : _selectedSpeed == 'Instant'
                              ? AppColors.navy
                              : AppColors.darkerGrey,
                      fontSize: Scale.x(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget date() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      padding: EdgeInsets.fromLTRB(
          Scale.x(20), Scale.x(16), Scale.x(20), Scale.x(16)),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: const Text(
              'Date',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 16,
                color: Color.fromARGB(255, 99, 99, 99),
              ),
            ),
          ),
          SizedBox(height: Scale.x(10)),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"
                      : 'Select  ', // Default placeholder
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: Scale.x(16),
                    color: AppColors.navy,
                  ),
                ),
                _selectedDate != null
                    ? SizedBox.shrink()
                    : Icon(Icons.calendar_today, color: AppColors.navy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Default to today
      firstDate: DateTime.now(), // No past dates
      lastDate:
          DateTime.now().add(const Duration(days: 365)), // One year from now
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white), // Background color of the dialog
            colorScheme: ColorScheme.light(
              primary: AppColors.green, // Header background color
              onPrimary: AppColors.white, // Header text color
              onSurface: AppColors.darkerGrey, // Date text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Widget selectAccounts() {
    final accounts = [
      'Citibank Online Checking 0000',
      'Bank of America Checking 0000',
      'CitiBank Online Savings 1111',
      'American Express Credit Card 3333',
      'Citibank Online Credit Card 3333',
    ];
    final directions = ['From', 'To'];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      padding: EdgeInsets.all(Scale.x(15)),
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
      child: Column(
        children: directions.map((direction) {
          return Column(
            children: [
              transferDirection(direction, accounts, context),
              if (direction != directions.last) const Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget transferDirection(
      String direction, List<String> accounts, BuildContext context) {
    // Get the opposite direction (From -> To, To -> From)
    String oppositeDirection = direction == 'From' ? 'To' : 'From';

    // Filter accounts to exclude the one selected in the opposite direction
    List<String> filteredAccounts = accounts.where((account) {
      return _selectedAccounts[oppositeDirection] != account;
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Scale.x(6.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            direction,
            style: TextStyle(
              fontFamily: 'Open Sans',
              color: Color.fromARGB(255, 99, 99, 99),
              fontSize: Scale.x(16),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showAccountSelectionPopup(context, filteredAccounts, (selected) {
                setState(() {
                  // Update selected account for this direction
                  _selectedAccounts[direction] = selected;

                  // Clear opposite direction's selection if it conflicts
                  if (_selectedAccounts[oppositeDirection] == selected) {
                    _selectedAccounts[oppositeDirection] = null;
                  }
                });
              });
            },
            child: Row(
              children: [
                Text(
                  _selectedAccounts[direction] ?? 'Select Account',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    color: AppColors.navy,
                    fontSize: Scale.x(16),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.navy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountSelectionPopup(
    BuildContext context,
    List<String> accounts,
    Function(String) onSelect,
  ) {
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
                Padding(
                  padding: EdgeInsets.only(bottom: Scale.x(20)),
                  child: Text(
                    'Select Account:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      color: AppColors.navy,
                      fontSize: Scale.x(18),
                    ),
                  ),
                ),
                SizedBox(
                  height: Scale.x(150), // Adjusted to fit more accounts
                  width: double.maxFinite,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          splashColor: AppColors.customGreen,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  accounts[index],
                                  textAlign: TextAlign.left,
                                  maxLines: 2, // Allows wrapping
                                  softWrap: true,
                                  style: const TextStyle(
                                    color: AppColors.darkerGrey,
                                  ),
                                ),
                              ),
                              SizedBox(width: Scale.x(10)),
                              Text(
                                '\$${_accountBalances[accounts[index]]?.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            onSelect(accounts[index]);
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
                    child: const Text(
                      'Cancel',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget amount() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      padding:
          EdgeInsets.fromLTRB(Scale.x(20), Scale.x(2), Scale.x(20), Scale.x(2)),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Amount',
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
                hintText: '\$0.00', // Example hint text
                hintStyle: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: Scale.x(16),
                  color: AppColors.navy,
                ),
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

  Widget button() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      child: ElevatedButton(
        onPressed: () {
          _showConfirmTransferDialog(context);
        },
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all<Size>(
            Size(double.infinity, Scale.x(52)), // Full width, height as needed
          ),
          backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(
              255, 3, 63, 80)), // Replace with AppColors.navy
          foregroundColor: WidgetStateProperty.all<Color>(
              AppColors.white), // Replace with AppColors.white
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

  void _showConfirmTransferDialog(BuildContext context) {
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
                _buildDialogTitle(),
                //_buildDialogRow('Type:', _selectedSpeed),
                if (_selectedSpeed == 'Schedule')
                  _buildDialogRow(
                    'Scheduled:',
                    _selectedDate != null
                        ? "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"
                        : 'Not Set',
                  ),
                _buildDialogRow(
                    'From:', _selectedAccounts['From'] ?? 'Not Selected'),
                _buildDialogRow(
                    'To:', _selectedAccounts['To'] ?? 'Not Selected'),
                _buildDialogRow('Amount:', _amountController.text),
                _buildDialogActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: Scale.x(20)),
      child: Text(
        'Confirm Transfer',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Open Sans',
          color: AppColors.navy,
          fontSize: Scale.x(18),
        ),
      ),
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
                  side: WidgetStateProperty.all(BorderSide(
                      color: AppColors.navy, width: 1)), // Adding border
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
                  SnackbarService.show('Transfer Successful', isError: false);
                  NavListeners.instance.popTilIndexRoute(1, context);
                },
                child: const Text('Transfer'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
