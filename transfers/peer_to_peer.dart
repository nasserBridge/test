import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/transfer_appbar.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class PeerToPeer extends StatefulWidget {
  const PeerToPeer({super.key});

  @override
  State<PeerToPeer> createState() => _PeerToPeerState();
}

class _PeerToPeerState extends State<PeerToPeer> {
  String _p2pDirection = 'Send';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedAccount = 'Bank of America Checking 0000';
  String? _selectedPerson;

  final Map<String, double> _accountBalances = {
    'Citibank Online Checking 0000': 100.00,
    'Bank of America Checking 0000': 100.00,
    'CitiBank Online Savings 1111': 200.00,
    'American Express Credit Card 3333': 410.00,
    'Citibank Online Credit Card 3333': 410.00,
  };

  final Map<String, String> _people = {
    'Chris Tao': '(881) 654-1813',
    'Jay Smith': '(415) 234-5678',
    'Alice Rivers': '(212) 345-6789',
    'Alex Condavel': '(310) 123-1234',
    'Motolani Oy': '(718) 987-6543',
    'Justin Tomilson': '(646) 456-7890',
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

    _phoneNumberController.addListener(() {
      final text = _phoneNumberController.text;
      final newText = _formatPhoneNumber(text);
      if (newText != text) {
        _phoneNumberController.value = _phoneNumberController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(
            offset: newText.length,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    } else {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 10)}';
    }
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
        selectDirection(),
        personAmountContainer(),
        fromToContainer(),
        button(),
      ],
    );
  }

  Widget selectDirection() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), 40, Scale.x(30), 0),
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
      child: Row(
        children: [
          _direction('Send', _p2pDirection == 'Send'),
          if (_p2pDirection == '')
            Container(
              width: Scale.x(1),
              height: Scale.x(40),
              color: AppColors.navy,
            ),
          _direction('Request', _p2pDirection == 'Request'),
        ],
      ),
    );
  }

  Widget _direction(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _p2pDirection = label;
          });
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(0, Scale.x(12), 0, Scale.x(12)),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 49, 145, 124)
                : AppColors.white,
            borderRadius: label == 'Send'
                ? BorderRadius.only(
                    topLeft: Radius.circular(Scale.x(15)),
                    bottomLeft: Radius.circular(Scale.x(15)),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(Scale.x(15)),
                    bottomRight: Radius.circular(Scale.x(15)),
                  ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Open Sans',
                color: isSelected
                    ? AppColors.white
                    : _p2pDirection == (label == 'Send' ? 'Request' : 'Send')
                        ? AppColors.navy
                        : AppColors.darkerGrey,
                fontSize: Scale.x(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget personAmountContainer() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      padding: EdgeInsets.fromLTRB(
          Scale.x(15), Scale.x(15), Scale.x(15), Scale.x(15)),
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
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: Scale.x(5)),
            child: selections('Person', _people.keys.toList(), context,
                isPerson: true),
          ),
          const Divider(),
          amount(),
        ],
      ),
    );
  }

  Widget amount() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, Scale.x(5), Scale.x(5), 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Amount',
            style: TextStyle(
              fontFamily: 'Open Sans',
              color: Color.fromARGB(255, 99, 99, 99),
              fontSize: Scale.x(16),
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
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 0),
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

  Widget fromToContainer() {
    final accounts = _accountBalances.keys.toList();

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
            offset: Offset(0, Scale.x(3)),
          ),
        ],
      ),
      child: Column(
        children: [
          selections(
              _p2pDirection == 'Request' ? 'To' : 'From', accounts, context),
        ],
      ),
    );
  }

  Widget selections(String direction, List<String> items, BuildContext context,
      {bool isPerson = false}) {
    List<String> filteredItems = items.where((item) {
      return isPerson ? _selectedPerson != item : _selectedAccount != item;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
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
              if (isPerson) {
                _personPopup(context, filteredItems, (selected) {
                  setState(() {
                    _selectedPerson = selected;
                  });
                });
              } else {
                _showAccountSelectionPopup(context, filteredItems, (selected) {
                  setState(() {
                    _selectedAccount = selected;
                  });
                });
              }
            },
            child: Row(
              children: [
                Text(
                  isPerson
                      ? (_selectedPerson ?? 'Search  ')
                      : (_selectedAccount ?? 'Select Account'),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    color: AppColors.navy,
                    fontSize: Scale.x(16),
                  ),
                ),
                if (isPerson && _selectedPerson != null) const Text('  '),
                Icon(
                  isPerson ? Icons.person_search : Icons.arrow_drop_down,
                  color: AppColors.navy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _personPopup(
      BuildContext context, List<String> items, Function(String) onSelect) {
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: Scale.x(10),
                        left: Scale.x(10),
                        right: Scale.x(10)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recent',
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              color: AppColors.navy,
                              fontSize: Scale.x(18),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.person_add,
                              color: AppColors.navy),
                          label: Text(
                            'Add Person',
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              color: AppColors.navy,
                              fontSize: Scale.x(16),
                            ),
                          ),
                          onPressed: () {
                            // Add your onPressed code here
                          },
                        ),
                      ],
                    ),
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
                        final item = items[index];
                        final phoneNumber = _people[item];
                        return ListTile(
                          splashColor: AppColors.customGreen,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item,
                                style: const TextStyle(
                                  color: AppColors.darkerGrey,
                                ),
                              ),
                              if (phoneNumber != null)
                                Text(
                                  phoneNumber,
                                  style: const TextStyle(
                                    color: AppColors.darkerGrey,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            onSelect(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: Scale.x(30)),
                  child: Center(
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAccountSelectionPopup(
    BuildContext context,
    List<String> accounts,
    Function(String) onSelect,
  ) async {
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
                  height: Scale.x(150),
                  width: double.maxFinite,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
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
                              if (_p2pDirection != 'Request')
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

  Widget button() {
    return Container(
      margin: EdgeInsets.fromLTRB(Scale.x(30), Scale.x(40), Scale.x(30), 0),
      child: ElevatedButton(
        onPressed: () {
          _showConfirmTransferDialog(context);
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
                _buildDialogRow('Type:', _p2pDirection),
                _buildDialogRow('Person:', _selectedPerson ?? 'Not Selected'),
                _buildDialogRow('Amount:', _amountController.text),
                _buildDialogRow('From:', _selectedAccount ?? 'Not Selected'),
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
                      color: AppColors.navy,
                      width: Scale.x(1))), // Adding border
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
