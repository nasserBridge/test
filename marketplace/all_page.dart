import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/categories_data.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/marketplace_repository.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/filter_popup_utility.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/filter_popup_widget.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/view_details_popup.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/compare_rubric.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceAll extends StatefulWidget {
  const MarketplaceAll({super.key});

  @override
  MarketplaceAllState createState() => MarketplaceAllState();
}

class MarketplaceAllState extends State<MarketplaceAll> {
  // Dynamic data loaded from Firestore (falls back to static on error).
  Map<String, List<Map<String, dynamic>>>? categories;
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  DateTime? _lastUpdated;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, PageController> pageControllers = {};
  final Map<String, bool> compareStates = {};
  final List<String> compareQueue = [];
  String? currentCategory;
  final _navController = Get.put(NavListeners());

  Map<String, Map<String, bool>> checkingFilters = {
    'Preferences': {
      'Bonus Offer': false, // true if string is not '\$0',
      'Earns Interest': false, // true if string is not '0%',
      '\$0 Opening Balance': false, // true if string is '\$0',
      'No Overdraft Fee': false, // true if string is '\$0',
      'Tiered Relationship Program': false, // true if not null
    },
    'Fee Waiver Options': {
      'Direct Deposit': false,
      'Daily Balance': false,
      'Student': false,
      'Transaction Minimum': false,
      'Military': false,
      'Other': false,
    },
  };

  Map<String, Map<String, bool>> savingsFilters = {
    'Preferences': {
      'No Monthly Fee': false, // true if string is '\$0',
      'High Yield APY': false, // true if string is not '0.01%',
      '\$0 Opening Balance': false, // true if string is '\$0',
      'Tiered Relationship Program': false, // true if not null
    },
    'Fee Waiver Options': {
      'Daily Balance': false, //true if value is not null
      'Age': false, // true if value is not null
      'Linked Account': false, // true if boolean value is true
      'Military': false, // true if boolean value is true
      'Other': false, // true if boolean value is true
    },
  };

  Map<String, Map<String, bool>> creditcardsFilters = {
    'Preferences': {
      'Bonus Offer': false, // true if string is not '\$0',
      'No Annual Fee': false, // true if string includes '\$0',
      '0% APR': false, // true if Intro Purchases APR not null
      'Balance Transfer': false, // true if Intro Balance Transfers APR not null
    },
    'Program': {
      'Cash Back': false, // true if string includes the word 'Cash Back',
      'Points': false, // true if string includes the word 'Points',
      'Miles': false, // true if string includes the word 'Miles',
    },
  };

  Map<String, Map<String, bool>> autoloansFilters = {
    'Loan Type': {
      'New Car': false,
      'Used Car': false,
      'Refinance': false,
      'Lease Buyout': false,
    },
    'Seller': {
      'Dealership': false,
      'Private Party': false,
    },
    'Months Term': {
      '12 Months': false,
      '24 Months': false,
      '36 Months': false,
      '48 Months': false,
      '60 Months': false,
      '66 Months': false,
      '72 Months': false,
      '75 Months': false,
      '78 Months': false,
      '84 Months': false,
    },
  };

  Map<String, Map<String, bool>> investmentsFilters = {
    'Preferences': {'No Commission': false, '\$0 Opening Balance': false},
    'Asset Classes': {
      'Stocks': false,
      'Bonds': false,
      'ETFs': false,
      'Mutual Funds': false,
      'Options': false,
      'Crypto': false,
      'CDs': false,
      'Precious Metals': false,
      'International Markets': false,
      'Money Market': false,
      'Fixed Income': false,
      'Index Funds': false,
      'Futures': false,
      'Forex': false,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await MarketplaceRepository.fetchCategoriesWithMeta()
          .timeout(const Duration(seconds: 12));
      if (mounted) {
        setState(() {
          categories = result['categories'];
          _lastUpdated = result['lastUpdated'];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Scale.init(context);
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F7F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColors.customGreen,
        body: ListView(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(
                Scale.x(30),
                Scale.x(30),
                Scale.x(30),
                Scale.x(20),
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(Scale.x(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(76),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: Scale.x(40)),
                  Icon(
                    Icons.wifi_off_rounded,
                    size: Scale.x(48),
                    color: AppColors.navy.withAlpha(80),
                  ),
                  SizedBox(height: Scale.x(16)),
                  Text(
                    'Couldn\'t load products',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: Scale.x(15),
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: Scale.x(6)),
                  Text(
                    'Check your connection and try again.',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: Scale.x(12),
                      color: AppColors.navy.withAlpha(120),
                    ),
                  ),
                  TryAgain(
                    reloadText: 'Try Again',
                    height: Scale.x(120),
                    onRetry: () async {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                      });
                      await _loadCategories();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.customGreen,
      body: _allCategoriesBody(context),
    );
  }

  Widget _allCategoriesBody(BuildContext context) {
    return Stack(
      children: [
        ListView(
          children: [
            Padding(
              padding:
                  EdgeInsets.fromLTRB(Scale.x(30), Scale.x(20), Scale.x(30), 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (compareQueue.isEmpty) ...[
                    Text(
                      'Compare Financial Products',
                      style: TextStyle(
                        fontSize: Scale.x(24),
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    if (_lastUpdated != null)
                      Padding(
                        padding: EdgeInsets.only(top: Scale.x(4)),
                        child: Text(
                          'Updated ${_formatLastUpdated(_lastUpdated!)}',
                          style: TextStyle(
                            fontSize: Scale.x(11),
                            color: AppColors.navy.withAlpha(120),
                            fontFamily: 'Open Sans',
                          ),
                        ),
                      ),
                    SizedBox(height: Scale.x(12)),
                  ],
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(Scale.x(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(
                          () => _searchQuery = val.trim().toLowerCase()),
                      style: TextStyle(
                          fontSize: Scale.x(14), fontFamily: 'Open Sans'),
                      decoration: InputDecoration(
                        hintText: 'Search banks or accounts...',
                        hintStyle: TextStyle(
                          fontSize: Scale.x(13),
                          color: Colors.grey,
                          fontFamily: 'Open Sans',
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: AppColors.navy, size: Scale.x(20)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    size: Scale.x(18), color: Colors.grey),
                                onPressed: () => setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                }),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: Scale.x(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _categoryContainers(context),
          ],
        ),
        if (compareQueue.isNotEmpty)
          Align(
            alignment: Alignment.topCenter,
            child: _compareQueue(context),
          ),
      ],
    );
  }

  bool _isFilterActive(Map<String, Map<String, bool>> filters) {
    return filters.values.any((section) => section.values.any((v) => v));
  }

  void _clearCategoryFilters(String category) {
    void clearMap(Map<String, Map<String, bool>> filters) {
      for (final section in filters.values) {
        for (final key in section.keys) {
          section[key] = false;
        }
      }
    }

    setState(() {
      if (category == 'Checkings') {
        clearMap(checkingFilters);
      } else if (category == 'Savings, CDs, & Money Market') {
        clearMap(savingsFilters);
      } else if (category == 'Credit Cards') {
        clearMap(creditcardsFilters);
      } else if (category == 'Auto Loans') {
        clearMap(autoloansFilters);
      } else if (category == 'Investments') {
        clearMap(investmentsFilters);
      }
    });
  }

  String _formatLastUpdated(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Widget _compareQueue(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        Scale.x(30),
        Scale.x(30),
        Scale.x(30),
        Scale.x(20),
      ),
      padding: EdgeInsets.fromLTRB(
        Scale.x(15),
        Scale.x(10),
        Scale.x(15),
        Scale.x(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Scale.x(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  compareQueue.clear();
                  compareStates.clear();
                });
              },
              child: SizedBox(
                height: Scale.x(22),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: Scale.x(FontSizes.statementMonth),
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _navController.isOnMain(false);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return CompareRubric(
                    selectedAccounts:
                        compareQueue.map<Map<String, dynamic>>((accountKey) {
                      final parts = accountKey.split(' - ');
                      final bank = parts[0];
                      final account = parts[1];

                      return (categories ?? getShuffledCategories())
                          .values
                          .expand((list) => list)
                          .firstWhere((acc) =>
                              acc['Bank'] == bank && acc['Account'] == account);
                    }).toList(),
                  );
                }),
              );
            },
            child: SizedBox(
              height: Scale.x(24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  'Compare Now',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontSize: Scale.x(FontSizes.statements),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(Map<String, dynamic> institution) {
    final logo = institution['Logo'];
    if (logo == null || (logo as String).isEmpty) {
      return _logoFallback(institution['Bank'] ?? '');
    }
    return Image.asset(
      logo,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _logoFallback(institution['Bank'] ?? ''),
    );
  }

  Widget _logoFallback(String bankName) {
    final initials = bankName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.customGreen.withAlpha(60),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: Scale.x(22),
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }

  Widget _categoryContainers(BuildContext context) {
    final cats = categories ?? getShuffledCategories();
    return Column(
      children: cats.keys.map((category) {
        var institutions = cats[category]!;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          institutions = institutions.where((acc) {
            final bank = acc['Bank']?.toString().toLowerCase() ?? '';
            final account = acc['Account']?.toString().toLowerCase() ?? '';
            return bank.contains(_searchQuery) ||
                account.contains(_searchQuery);
          }).toList();
          if (institutions.isEmpty) return const SizedBox.shrink();
        }

        // Apply filters by category
        if (category == 'Checkings') {
          institutions = filterCheckings(
            institutions: institutions,
            checkingFiltersData: checkingFilters,
          );
        } else if (category == 'Savings, CDs, & Money Market') {
          institutions = filterSavings(
            institutions: institutions,
            savingsFiltersData: savingsFilters,
          );
        } else if (category == 'Credit Cards') {
          institutions = filterCreditCards(
            institutions: institutions,
            creditcardsFiltersData: creditcardsFilters,
          );
        } else if (category == 'Auto Loans') {
          institutions = filterAutoLoans(
            institutions: institutions,
            autoloansFiltersData: autoloansFilters,
          );
        } else if (category == 'Investments') {
          institutions = filterInvestments(
            institutions: institutions,
            investmentsFiltersData: investmentsFilters,
          );
        }

        pageControllers[category] ??= PageController();
        final controller = pageControllers[category]!;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(
            Scale.x(30),
            Scale.x(30),
            Scale.x(30),
            Scale.x(20),
          ),
          padding: EdgeInsets.only(bottom: Scale.x(10)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Scale.x(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(76),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Scale.x(20),
                  Scale.x(5),
                  Scale.x(10),
                  Scale.x(5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: Scale.x(26),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: AppColors.navy,
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              fontSize: Scale.x(FontSizes.statements),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Builder(builder: (context) {
                      final activeFilters = category == 'Checkings'
                          ? checkingFilters
                          : category == 'Savings, CDs, & Money Market'
                              ? savingsFilters
                              : category == 'Credit Cards'
                                  ? creditcardsFilters
                                  : category == 'Auto Loans'
                                      ? autoloansFilters
                                      : investmentsFilters;
                      if (!_isFilterActive(activeFilters)) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () => _clearCategoryFilters(category),
                        child: Container(
                          margin: EdgeInsets.only(right: Scale.x(6)),
                          padding: EdgeInsets.symmetric(
                            horizontal: Scale.x(8),
                            vertical: Scale.x(3),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.navy.withAlpha(20),
                            borderRadius: BorderRadius.circular(Scale.x(12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Clear',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: Scale.x(FontSizes.statementMonth),
                                  fontFamily: 'Open Sans',
                                ),
                              ),
                              SizedBox(width: Scale.x(3)),
                              Icon(Icons.close,
                                  size: Scale.x(12), color: AppColors.navy),
                            ],
                          ),
                        ),
                      );
                    }),
                    Text(
                      'Filter',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: Scale.x(FontSizes.statementMonth),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.tune_sharp, color: AppColors.navy),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (category == 'Checkings') {
                          showFilterDetails(context, checkingFilters,
                              (updated) {
                            setState(() => checkingFilters = updated);
                          });
                        } else if (category == 'Savings, CDs, & Money Market') {
                          showFilterDetails(context, savingsFilters, (updated) {
                            setState(() => savingsFilters = updated);
                          });
                        } else if (category == 'Credit Cards') {
                          showFilterDetails(context, creditcardsFilters,
                              (updated) {
                            setState(() => creditcardsFilters = updated);
                          });
                        } else if (category == 'Auto Loans') {
                          showFilterDetails(context, autoloansFilters,
                              (updated) {
                            setState(() => autoloansFilters = updated);
                          });
                        } else if (category == 'Investments') {
                          showFilterDetails(context, investmentsFilters,
                              (updated) {
                            setState(() => investmentsFilters = updated);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (institutions.isNotEmpty)
                _institutionCard(controller, institutions, category),
              if (institutions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    Scale.x(20),
                    0,
                    Scale.x(10),
                  ),
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: institutions.length,
                      effect: ScrollingDotsEffect(
                        activeDotColor: AppColors.green,
                        dotColor: AppColors.blue,
                        dotHeight: Scale.x(6),
                        dotWidth: Scale.x(10),
                        spacing: Scale.x(6),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _institutionCard(PageController controller,
      List<Map<String, dynamic>> institutions, String category) {
    return SizedBox(
      height: Scale.x(375),
      child: PageView.builder(
        controller: controller,
        itemCount: institutions.length,
        itemBuilder: (context, index) {
          final institution = institutions[index];
          final institutionKey =
              '${institution['Bank']} - ${institution['Account']}';
          compareStates[institutionKey] ??= false;

          return Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: Scale.x(25)),
                padding: EdgeInsets.symmetric(horizontal: Scale.x(20)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color.fromARGB(255, 188, 188, 188),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(Scale.x(25)),
                          child: _buildLogo(institution),
                        ),
                      ),
                    ),
                    Flexible(
                      child: ClipRect(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                institution['Account']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  fontSize: Scale.x(FontSizes.statements),
                                ),
                              ),
                              SizedBox(height: Scale.x(8.0)),
                              if (institution.containsKey('APY')) ...[
                                Text(
                                  'APY: ${institution['APY'] ?? 'Non-Interest Bearing'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution
                                      .containsKey('Intro Purchases APR') &&
                                  institution['Intro Purchases APR'] !=
                                      null) ...[
                                Text(
                                  'APR: ${institution['Intro Purchases APR']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution
                                      .containsKey('Intro Purchases APR') &&
                                  institution['Intro Purchases APR'] ==
                                      null) ...[
                                Text(
                                  'APR: ${institution['Purchases APR']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution.containsKey('APR')) ...[
                                Text(
                                  'APR: ${institution['APR']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution
                                  .containsKey('Trade Commission')) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Text(
                                  'Trade Commission: ${institution['Trade Commission']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ],
                              if (institution
                                  .containsKey('Min Opening Balance')) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Text(
                                  'Min Opening Balance: ${institution['Min Opening Balance']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution
                                  .containsKey('Annual Fee')) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Text(
                                  'Annual: ${institution['Annual Fee']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution.containsKey('Seller') &&
                                  institution['Seller'] != null) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Text(
                                  'Seller: ${institution['Seller']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution
                                  .containsKey('Transaction Fee')) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Text(
                                  'Transaction Fee: ${institution['Transaction Fee']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution
                                  .containsKey('Overdraft Fee')) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Text(
                                  'Overdraft Fee: ${institution['Overdraft Fee']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ],
                              if (institution.containsKey('Bonus Offer') &&
                                  institution['Bonus Offer'] != null) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Text(
                                  'Bonus Offer: ${institution['Bonus Offer']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution
                                  .containsKey('Asset Classes')) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Text(
                                  'Asset Classes: ${institution['Asset Classes']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    color: AppColors.navy,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ] else if (institution
                                  .containsKey('Month Term Lengths')) ...[
                                SizedBox(height: Scale.x(8.0)),
                                Builder(builder: (context) {
                                  final termString =
                                      institution['Month Term Lengths'];
                                  final terms = termString
                                      .split(',')
                                      .map((e) => int.tryParse(e.trim()))
                                      .whereType<int>()
                                      .toList();
                                  if (terms.isNotEmpty) {
                                    terms.sort();
                                    final min = terms.first;
                                    final max = terms.last;
                                    return Text(
                                      'Term Length: $min - $max months',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Open Sans',
                                        color: AppColors.navy,
                                        fontSize: Scale.x(FontSizes.statements),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }),
                              ],
                            ]),
                      ),
                    ), // end Flexible
                    SizedBox(height: Scale.x(25.0)),
                    GestureDetector(
                      onTap: () {
                        showViewDetails(context, institution);
                      },
                      child: Center(
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            color: AppColors.navy,
                            fontSize: Scale.x(FontSizes.statementMonth),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Scale.x(5.0)),
                    Center(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: Scale.x(20)),
                              child: ElevatedButton(
                                onPressed: () async {
                                  final url = institution['URL'];
                                  if (url != null) {
                                    final uri = Uri.parse(url);
                                    if (!await launchUrl(uri)) {
                                      throw Exception('Could not launch $url');
                                    }
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    const Color.fromARGB(255, 12, 181, 144),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(Scale.x(10)),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    fontSize: Scale.x(FontSizes.statements),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                right: 35,
                child: Row(
                  children: [
                    Text(
                      (compareStates[institutionKey] ?? false) ? '' : 'Compare',
                      style: const TextStyle(
                        fontFamily: 'Pt Sans',
                        color: AppColors.darkerGrey,
                        fontSize: 12,
                      ),
                    ),
                    Checkbox(
                      value: compareStates[institutionKey],
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (compareQueue.isEmpty ||
                                currentCategory == category) {
                              compareQueue.add(institutionKey);
                              currentCategory = category;
                            } else {
                              _showClearQueueDialog(institutionKey, category);
                              return;
                            }
                          } else {
                            compareQueue.remove(institutionKey);
                            if (compareQueue.isEmpty) {
                              currentCategory = null;
                            }
                          }
                          compareStates[institutionKey] = value!;
                        });
                      },
                      checkColor: AppColors.navy,
                      activeColor: AppColors.white,
                      side: const BorderSide(color: AppColors.darkerGrey),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearQueueDialog(String institutionKey, String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Scale.x(15)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Scale.x(30),
              Scale.x(30),
              Scale.x(30),
              Scale.x(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Clear Comparison Queue?',
                  style: TextStyle(
                    fontSize: Scale.x(16),
                    color: AppColors.navy,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: Scale.x(15)),
                Text(
                  'No comparing apples to oranges (e.g., Checking vs. Savings).',
                  style: TextStyle(
                    fontSize: Scale.x(14),
                    color: AppColors.navy,
                    fontFamily: 'Open Sans',
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: Scale.x(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.navy),
                        padding: EdgeInsets.symmetric(
                          horizontal: Scale.x(20),
                          vertical: Scale.x(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: Scale.x(13),
                        ),
                      ),
                    ),
                    SizedBox(width: Scale.x(10)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: Scale.x(20),
                          vertical: Scale.x(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          compareQueue.clear();
                          compareStates.clear();
                          compareQueue.add(institutionKey);
                          currentCategory = category;
                          compareStates[institutionKey] = true;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: Scale.x(13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
