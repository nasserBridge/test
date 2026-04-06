import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/subscriptions/aggregated_transactions_controller.dart';
import 'package:bridgeapp/src/subscriptions/subscriptions_controller.dart';
import 'package:bridgeapp/src/subscriptions/subscriptions_repository.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionsWidget extends StatefulWidget {
  const SubscriptionsWidget({super.key});

  @override
  State<SubscriptionsWidget> createState() => _SubscriptionsWidgetState();
}

class _SubscriptionsWidgetState extends State<SubscriptionsWidget> {
  late SubscriptionsController _controller;
  late AggregatedTransactionsController _transactionsController;

  @override
  void initState() {
    super.initState();

    // Get or create the AggregatedTransactionsController
    if (Get.isRegistered<AggregatedTransactionsController>()) {
      _transactionsController = Get.find<AggregatedTransactionsController>();
    } else {
      _transactionsController = Get.put(AggregatedTransactionsController());
    }

    // Create SubscriptionsController - it will watch the transactions controller internally
    _controller = Get.put(SubscriptionsController());
  }

  @override
  void dispose() {
    // Only dispose the subscriptions controller, not the transactions controller
    // since it might be used elsewhere
    _controller.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (_controller.tryAgain.value) {
        return _buildErrorState();
      }

      return WhiteContainer(
        margin: EdgeInsets.symmetric(horizontal: Scale.x(30)),
        padding: EdgeInsets.all(Scale.x(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: Scale.x(16)),
            if (_controller.confirmedSubscriptions.isNotEmpty)
              _buildMonthlySummary(),
            if (_controller.detectedSubscriptions.isNotEmpty) ...[
              SizedBox(height: Scale.x(24)),
              _buildSectionTitle(
                'Detected Subscriptions',
                'Review recurring charges',
              ),
              SizedBox(height: Scale.x(12)),
              ..._controller.detectedSubscriptions
                  .map((sub) => _buildDetectedCard(sub)),
            ],
            if (_controller.confirmedSubscriptions.isNotEmpty) ...[
              SizedBox(height: Scale.x(24)),
              _buildSectionTitle(
                'Your Subscriptions',
                '${_controller.confirmedSubscriptions.length} active',
              ),
              SizedBox(height: Scale.x(12)),
              ..._controller.confirmedSubscriptions
                  .map((sub) => _buildConfirmedCard(sub)),
            ],
            if (_controller.confirmedSubscriptions.isEmpty &&
                _controller.detectedSubscriptions.isEmpty)
              _buildEmptyState(),
            SizedBox(height: Scale.x(16)),
            _buildAddCustomButton(),
          ],
        ),
      );
    });
  }

  // ============================================
  // UI BUILDER METHODS
  // ============================================

  Widget _buildLoadingState() {
    return WhiteContainer(
      margin: EdgeInsets.symmetric(horizontal: Scale.x(30)),
      padding: EdgeInsets.all(Scale.x(40)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
            ),
            SizedBox(height: Scale.x(16)),
            Text(
              'Analyzing your subscriptions...',
              style: TextStyle(
                fontSize: FontSizes.accountGroup,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return WhiteContainer(
      margin: EdgeInsets.symmetric(horizontal: Scale.x(30)),
      padding: EdgeInsets.all(Scale.x(40)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: Scale.x(48),
              color: Colors.red,
            ),
            SizedBox(height: Scale.x(16)),
            Text(
              'Failed to load subscriptions',
              style: TextStyle(
                fontSize: FontSizes.combinedBalance,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: Scale.x(8)),
            Text(
              'Please try again',
              style: TextStyle(
                fontSize: FontSizes.accountGroup,
                color: AppColors.mediumGrey,
              ),
            ),
            SizedBox(height: Scale.x(24)),
            ElevatedButton(
              onPressed: () => _controller.retryData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: EdgeInsets.symmetric(
                  horizontal: Scale.x(32),
                  vertical: Scale.x(12),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: FontSizes.accountGroup,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.subscriptions_outlined,
          size: Scale.x(24),
          color: AppColors.green,
        ),
        SizedBox(width: Scale.x(12)),
        Expanded(
          child: Text(
            'Subscriptions',
            style: TextStyle(
              fontSize: FontSizes.bigBanner,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
        ),
        // Manual Rescan Button
        Obx(() => _controller.isLoading.value
            ? SizedBox(
                width: Scale.x(20),
                height: Scale.x(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                ),
              )
            : IconButton(
                onPressed: () => _controller.manualRescan(),
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.green,
                  size: Scale.x(24),
                ),
                tooltip: 'Rescan Subscriptions',
              )),
        // Menu with Reset option
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: AppColors.navy,
            size: Scale.x(24),
          ),
          onSelected: (value) {
            if (value == 'reset') {
              _showResetAllDialog();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(
                    Icons.restore,
                    color: Colors.red,
                    size: Scale.x(20),
                  ),
                  SizedBox(width: Scale.x(12)),
                  Text(
                    'Reset All Data',
                    style: TextStyle(
                      fontSize: FontSizes.accountGroup,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlySummary() {
    final total = _controller.getTotalMonthlyCost();
    return Container(
      padding: EdgeInsets.all(Scale.x(16)),
      decoration: BoxDecoration(
        color: AppColors.customGreen,
        borderRadius: BorderRadius.circular(Scale.x(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Monthly Cost',
                style: TextStyle(
                  fontSize: FontSizes.accountGroup,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: Scale.x(4)),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: FontSizes.totalBalance,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          Icon(
            Icons.trending_up,
            size: Scale.x(32),
            color: AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: FontSizes.combinedBalance,
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
        SizedBox(height: Scale.x(4)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: FontSizes.navText,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDetectedCard(Subscription subscription) {
    return Container(
      margin: EdgeInsets.only(bottom: Scale.x(12)),
      padding: EdgeInsets.all(Scale.x(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(Scale.x(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.merchantName,
                      style: TextStyle(
                        fontSize: FontSizes.transInfo,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: Scale.x(4)),
                    Text(
                      subscription.category,
                      style: TextStyle(
                        fontSize: FontSizes.navText,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${subscription.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: FontSizes.transAmount,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: Scale.x(4)),
                  Text(
                    subscription.frequency,
                    style: TextStyle(
                      fontSize: FontSizes.navText,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Scale.x(12)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _controller.dismissDetectedSubscription(subscription),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.mediumGrey),
                    padding: EdgeInsets.symmetric(vertical: Scale.x(8)),
                  ),
                  child: Text(
                    'Dismiss',
                    style: TextStyle(
                      fontSize: FontSizes.accountGroup,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Scale.x(12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _controller.confirmSubscription(subscription),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: EdgeInsets.symmetric(vertical: Scale.x(8)),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: FontSizes.accountGroup,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedCard(Subscription subscription) {
    return Container(
      margin: EdgeInsets.only(bottom: Scale.x(12)),
      padding: EdgeInsets.all(Scale.x(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(Scale.x(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.merchantName,
                  style: TextStyle(
                    fontSize: FontSizes.transInfo,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: Scale.x(4)),
                Text(
                  subscription.category,
                  style: TextStyle(
                    fontSize: FontSizes.navText,
                    color: AppColors.mediumGrey,
                  ),
                ),
                if (subscription.nextBillingDate != null) ...[
                  SizedBox(height: Scale.x(4)),
                  Text(
                    'Next: ${_formatDate(subscription.nextBillingDate!)}',
                    style: TextStyle(
                      fontSize: FontSizes.navText,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${subscription.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: FontSizes.transAmount,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
              SizedBox(height: Scale.x(4)),
              Text(
                subscription.frequency,
                style: TextStyle(
                  fontSize: FontSizes.navText,
                  color: AppColors.mediumGrey,
                ),
              ),
              SizedBox(height: Scale.x(8)),
              InkWell(
                onTap: () => _showDeleteDialog(subscription),
                child: Icon(
                  Icons.delete_outline,
                  size: Scale.x(20),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(Scale.x(32)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: Scale.x(64),
              color: AppColors.mediumGrey.withValues(alpha: 0.5),
            ),
            SizedBox(height: Scale.x(16)),
            Text(
              'No subscriptions detected',
              style: TextStyle(
                fontSize: FontSizes.combinedBalance,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: Scale.x(8)),
            Text(
              'Add your subscriptions manually or\nconnect accounts to detect them automatically',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSizes.accountGroup,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showAddCustomDialog,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.green),
          padding: EdgeInsets.symmetric(vertical: Scale.x(12)),
        ),
        icon: Icon(
          Icons.add,
          color: AppColors.green,
        ),
        label: Text(
          'Add Custom Subscription',
          style: TextStyle(
            fontSize: FontSizes.accountGroup,
            color: AppColors.green,
          ),
        ),
      ),
    );
  }

  // ============================================
  // DIALOG METHODS
  // ============================================

  void _showAddCustomDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Other';
    String selectedFrequency = 'Monthly';
    DateTime nextBillingDate = DateTime.now().add(Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Add Custom Subscription',
            style: TextStyle(
              fontSize: FontSizes.accountName,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Subscription Name',
                    labelStyle: TextStyle(
                      fontSize: FontSizes.accountGroup,
                      color: AppColors.navy,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                  style: TextStyle(fontSize: FontSizes.accountGroup),
                ),
                SizedBox(height: Scale.x(16)),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                      fontSize: FontSizes.accountGroup,
                      color: AppColors.navy,
                    ),
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                  style: TextStyle(fontSize: FontSizes.accountGroup),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: Scale.x(16)),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(
                      fontSize: FontSizes.accountGroup,
                      color: AppColors.navy,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: FontSizes.accountGroup,
                    color: AppColors.navy,
                  ),
                  items: [
                    'Entertainment',
                    'Health & Fitness',
                    'Software & Apps',
                    'Utilities',
                    'Insurance',
                    'News & Media',
                    'Other',
                  ]
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                ),
                SizedBox(height: Scale.x(16)),
                DropdownButtonFormField<String>(
                  initialValue: selectedFrequency,
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    labelStyle: TextStyle(
                      fontSize: FontSizes.accountGroup,
                      color: AppColors.navy,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: FontSizes.accountGroup,
                    color: AppColors.navy,
                  ),
                  items: [
                    'Weekly',
                    'Monthly',
                    'Quarterly',
                    'Yearly',
                  ]
                      .map((freq) => DropdownMenuItem(
                            value: freq,
                            child: Text(freq),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedFrequency = value!);
                  },
                ),
                SizedBox(height: Scale.x(16)),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: nextBillingDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.green,
                              onPrimary: AppColors.white,
                              surface: AppColors.white,
                              onSurface: AppColors.navy,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() => nextBillingDate = picked);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(Scale.x(16)),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.blue),
                      borderRadius: BorderRadius.circular(Scale.x(4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Billing Date',
                              style: TextStyle(
                                fontSize: FontSizes.navText,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                            SizedBox(height: Scale.x(4)),
                            Text(
                              _formatDate(nextBillingDate),
                              style: TextStyle(
                                fontSize: FontSizes.accountGroup,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.green,
                          size: Scale.x(20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: FontSizes.accountGroup,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null) {
                    _controller.addCustomSubscription(
                      nameController.text,
                      amount,
                      selectedCategory,
                      selectedFrequency,
                      nextBillingDate,
                    );
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
              ),
              child: Text(
                'Add',
                style: TextStyle(
                  fontSize: FontSizes.accountGroup,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Subscription',
          style: TextStyle(
            fontSize: FontSizes.accountName,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${subscription.merchantName}?',
          style: TextStyle(
            fontSize: FontSizes.accountGroup,
            color: AppColors.navy,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: FontSizes.accountGroup,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.deleteSubscription(subscription);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: FontSizes.accountGroup,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: Scale.x(28),
            ),
            SizedBox(width: Scale.x(12)),
            Expanded(
              child: Text(
                'Reset All Data',
                style: TextStyle(
                  fontSize: FontSizes.accountName,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: TextStyle(
                fontSize: FontSizes.accountGroup,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: Scale.x(12)),
            _buildResetItem('All confirmed subscriptions'),
            _buildResetItem('All custom subscriptions'),
            _buildResetItem('All dismissed subscriptions'),
            SizedBox(height: Scale.x(16)),
            Text(
              'A fresh scan will run to detect subscriptions again from your transactions.',
              style: TextStyle(
                fontSize: FontSizes.navText,
                color: AppColors.mediumGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: Scale.x(16)),
            Container(
              padding: EdgeInsets.all(Scale.x(12)),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Scale.x(8)),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red,
                    size: Scale.x(20),
                  ),
                  SizedBox(width: Scale.x(8)),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: TextStyle(
                        fontSize: FontSizes.navText,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: FontSizes.accountGroup,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _controller.resetAllData();

              // Show success snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All subscription data has been reset'),
                  backgroundColor: AppColors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Reset All',
              style: TextStyle(
                fontSize: FontSizes.accountGroup,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Scale.x(8)),
      child: Row(
        children: [
          Icon(
            Icons.close,
            color: Colors.red,
            size: Scale.x(18),
          ),
          SizedBox(width: Scale.x(8)),
          Text(
            text,
            style: TextStyle(
              fontSize: FontSizes.accountGroup,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
