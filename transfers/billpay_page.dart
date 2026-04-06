import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/transfer_appbar.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class BillPayPage extends StatefulWidget {
  const BillPayPage({super.key});

  @override
  State<BillPayPage> createState() => _BillPayPageState();
}

class _BillPayPageState extends State<BillPayPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  String? _selectedAccount = 'Select Account';
  String? _selectedBiller;
  String _selectedSpeed = '';
  DateTime? _selectedDate;

  final Map<String, double> _accountBalances = {
    'Chase Checking 5486': 1200.50,
    'Capital One Savings 4584': 5500.75,
    'Wells Fargo Checking 1234': 800.00,
    'Bank of America Savings 5678': 3000.00,
  };

  // Map to track selected bills and their amounts
  final Map<String, double> _selectedBills = {};

  double get _runningTotal =>
      _selectedBills.values.fold(0.0, (sum, amount) => sum + amount);

  final Map<String, double> _bills = {
    'Electric Bill': 150.75,
    'Water Bill': 50.25,
    'Internet Bill': 75.00,
    'Credit Card ': 200.00,
  };

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      final text = _amountController.text;
      if (!text.startsWith('\$')) {
        _amountController.value = _amountController.value.copyWith(
          text: '\$${text.replaceAll('\$', '')}',
          selection: TextSelection.collapsed(
            offset: _amountController.text.length + 1,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
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
        billCards(),
        selectedBillsSummary(),
        transferSpeed(),
        if (_selectedSpeed == 'Schedule') date(),
        accountSelectionContainer(),
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
          Scale.x(20), Scale.x(10), Scale.x(10), Scale.x(16)),
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
            child: Text(
              'Date',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: Scale.x(16),
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

  Widget billCards() {
    return Container(
      height: Scale.x(160),
      margin:
          EdgeInsets.fromLTRB(Scale.x(0), Scale.x(20), Scale.x(0), Scale.x(10)),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          addBillCard(),
          ..._bills.entries.map((entry) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedBills.containsKey(entry.key)) {
                    _selectedBills.remove(entry.key);
                  } else {
                    _selectedBills[entry.key] = entry.value;
                  }
                });
              },
              child: Stack(
                children: [
                  billCard(entry.key, entry.value),
                  if (_selectedBills.containsKey(entry.key))
                    Positioned(
                      top: Scale.x(8),
                      right: Scale.x(24),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: Scale.x(24),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget billCard(String billName, double billAmount) {
    return Container(
      width: Scale.x(150),
      margin:
          EdgeInsets.symmetric(horizontal: Scale.x(10), vertical: Scale.x(15)),
      padding: EdgeInsets.all(Scale.x(15)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            color: AppColors.navy,
            size: Scale.x(30),
          ),
          SizedBox(height: Scale.x(10)),
          Text(
            billName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: Scale.x(14),
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: Scale.x(5)),
          Text(
            '\$${billAmount.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 14,
              color: AppColors.darkerGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedBillsSummary() {
    return Visibility(
      visible: _selectedBills.isNotEmpty,
      child: Container(
        margin: EdgeInsets.fromLTRB(
            Scale.x(30), Scale.x(20), Scale.x(30), Scale.x(0)),
        padding: EdgeInsets.all(Scale.x(15)),
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
              'Selected Bills',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: Scale.x(16),
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: Scale.x(10)),
            ..._selectedBills.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: Scale.x(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: Scale.x(14),
                        color: AppColors.darkerGrey,
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: Scale.x(14),
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: Scale.x(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  '\$${_runningTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: Scale.x(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget addBillCard() {
    return GestureDetector(
      onTap: () {
        // Action for adding a bill
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add New Bill'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Bill Name',
                    ),
                    onChanged: (value) {
                      // Handle bill name input
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Bill Amount',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Handle bill amount input
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle adding the new bill
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: Scale.x(150),
        height: Scale.x(160),
        margin: EdgeInsets.symmetric(
            horizontal: Scale.x(10), vertical: Scale.x(15)),
        padding: EdgeInsets.all(Scale.x(15)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle,
              color: AppColors.navy,
              size: Scale.x(40),
            ),
            const SizedBox(height: 10),
            Text(
              'Add Bill',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: Scale.x(14),
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget accountSelectionContainer() {
    final accounts = _accountBalances.keys.toList();

    return Container(
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
            offset: Offset(0, Scale.x(3)),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'From',
            style: TextStyle(
              fontFamily: 'Open Sans',
              color: Color.fromARGB(255, 99, 99, 99),
              fontSize: Scale.x(16),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showSelectionPopup(context, accounts);
            },
            child: Row(
              children: [
                Text(
                  _selectedAccount ?? 'Select Account',
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

  Widget button() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      child: ElevatedButton(
        onPressed: () {
          _showConfirmBillPayDialog(context);
        },
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all<Size>(
            Size(double.infinity, Scale.x(52)),
          ),
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

  Widget selections(String label, List<String> items, BuildContext context,
      {bool isBiller = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Open Sans',
            color: Color.fromARGB(255, 99, 99, 99),
            fontSize: Scale.x(16),
          ),
        ),
        GestureDetector(
          onTap: () {
            _showSelectionPopup(context, items, isBiller: isBiller);
          },
          child: Row(
            children: [
              Text(
                isBiller
                    ? (_selectedBiller ?? 'Select Biller')
                    : (_selectedAccount ?? 'Select Account'),
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  color: AppColors.navy,
                  fontSize: Scale.x(16),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: AppColors.navy,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSelectionPopup(BuildContext context, List<String> items,
      {bool isBiller = false}) {
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
                  isBiller ? 'Select Biller:' : 'Select Account:',
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
                            style: const TextStyle(
                              color: AppColors.darkerGrey,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              if (isBiller) {
                                _selectedBiller = items[index];
                              } else {
                                _selectedAccount = items[index];
                              }
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

  void _showConfirmBillPayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: Scale.x(20)),
                  child: Text(
                    'Confirm Bill Payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      color: AppColors.navy,
                      fontSize: Scale.x(18),
                    ),
                  ),
                ),
                _buildDialogRow('Account:', _selectedAccount ?? 'Not Selected'),
                ..._selectedBills.entries.map(
                  (entry) => _buildDialogRow(
                      entry.key, '\$${entry.value.toStringAsFixed(2)}'),
                ),
                _buildDialogRow(
                    'Total Amount:', '\$${_runningTotal.toStringAsFixed(2)}'),
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
                  SnackbarService.show('Bill Payment Successful',
                      isError: false);
                  NavListeners.instance.popTilIndexRoute(1, context);
                },
                child: const Text('Pay'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
