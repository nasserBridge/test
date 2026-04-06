import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/all_page.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/category_page.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class MarketplaceNavigation extends StatefulWidget {
  const MarketplaceNavigation({super.key});

  @override
  MarketplaceNavigationState createState() => MarketplaceNavigationState();
}

class MarketplaceNavigationState extends State<MarketplaceNavigation> {
  String _selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Checkings',
    'Savings, CDs, & Money Market',
    'Credit Cards',
    'Auto Loans',
    'Investments'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customGreen,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Scale.x(80)),
        child: _customAppBar(),
      ),
      body: _marketplaceBody(),
    );
  }

  Widget _customAppBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: Scale.x(4)),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          _buildCategoryButton('All'),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .where((cat) => cat != 'All')
                    .map(_buildCategoryButton)
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final bool isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicWidth(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Scale.x(10)),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  Scale.x(10),
                  0,
                  Scale.x(10),
                  Scale.x(3),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 108, 195, 176)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(Scale.x(12)),
                ),
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.navy,
                    fontFamily: 'Open Sans',
                    fontSize: Scale.x(15),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketplaceBody() {
    return Column(
      children: [
        Expanded(
          child: _selectedCategory == 'All'
              ? const MarketplaceAll()
              : MarketplaceCategory(category: _selectedCategory),
        ),
      ],
    );
  }
}
