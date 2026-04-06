import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/categories_data.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/marketplace_repository.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/view_details_popup.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/compare_rubric.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/category_pages_utility.dart';

class MarketplaceCategory extends StatefulWidget {
  final String category;
  const MarketplaceCategory({required this.category, super.key});

  @override
  MarketplaceCategoryState createState() => MarketplaceCategoryState();
}

class MarketplaceCategoryState extends State<MarketplaceCategory> {
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
                    spreadRadius: Scale.x(5),
                    blurRadius: Scale.x(7),
                    offset: Offset(0, Scale.x(3)),
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
      body: _allCategoriesBody(),
    );
  }

  Widget _allCategoriesBody() {
    return Stack(
      children: [
        ListView(
          children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    Scale.x(30), Scale.x(20), Scale.x(30), 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (compareQueue.isEmpty) ...[
                      Text(
                        widget.category,
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
              _categoryContainers(),
            ],
          ),
        if (compareQueue.isNotEmpty)
          Align(
            alignment: Alignment.topCenter,
            child: _compareQueue(),
          ),
      ],
    );
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

  Widget _compareQueue() {
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
            spreadRadius: Scale.x(5),
            blurRadius: Scale.x(7),
            offset: Offset(0, Scale.x(3)),
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
                      return (categories ?? getShuffledCategories())
                          .values
                          .expand((list) => list)
                          .firstWhere((acc) => acc['Account'] == accountKey);
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
                    letterSpacing: Scale.x(1.5),
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

  Widget _categoryContainers() {
    final categoryFilters = {
      'Checkings': getFilteredCheckings,
      'Savings, CDs, & Money Market': getFilteredSavings,
      'Credit Cards': getFilteredCreditCards,
      'Auto Loans': getFilteredAutoLoans,
      'Investments': getFilteredInvestments,
    };

    List<Map<String, dynamic>> applySearch(List<Map<String, dynamic>> list) {
      if (_searchQuery.isEmpty) return list;
      return list.where((acc) {
        final bank = acc['Bank']?.toString().toLowerCase() ?? '';
        final account = acc['Account']?.toString().toLowerCase() ?? '';
        return bank.contains(_searchQuery) || account.contains(_searchQuery);
      }).toList();
    }

    if (categoryFilters.containsKey(widget.category)) {
      final cats = categories ?? getShuffledCategories();
      final filtered =
          categoryFilters[widget.category]!(cats[widget.category]!);
      return Column(
        children: filtered.entries.map((entry) {
          final title = entry.key;
          final institutions = applySearch(entry.value);
          if (institutions.isEmpty) return const SizedBox.shrink();
          pageControllers[title] ??= PageController();
          return _buildCategoryContainer(
              title, institutions, pageControllers[title]!);
        }).toList(),
      );
    } else {
      final cats = categories ?? getShuffledCategories();
      if (!cats.containsKey(widget.category)) {
        return const SizedBox();
      }

      final institutions = applySearch(cats[widget.category]!);
      if (institutions.isEmpty) return const SizedBox.shrink();
      pageControllers[widget.category] ??= PageController();
      return _buildCategoryContainer(
          widget.category, institutions, pageControllers[widget.category]!);
    }
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

  Widget _buildCategoryContainer(
    String title,
    List<Map<String, dynamic>> institutions,
    PageController controller,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        Scale.x(30),
        Scale.x(30),
        Scale.x(30),
        Scale.x(20),
      ),
      padding: EdgeInsets.fromLTRB(
        Scale.x(0),
        Scale.x(0),
        Scale.x(0),
        Scale.x(10),
      ),
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
          Padding(
            padding: EdgeInsets.fromLTRB(
              Scale.x(20),
              Scale.x(14.5),
              Scale.x(10),
              Scale.x(14.5),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: Scale.x(FontSizes.statements),
              ),
            ),
          ),
          if (institutions.isNotEmpty)
            _institutionCard(controller, institutions, widget.category),
          if (institutions.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                Scale.x(0),
                Scale.x(20),
                Scale.x(0),
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
  }

  Widget _institutionCard(PageController controller,
      List<Map<String, dynamic>> institutions, String category) {
    return SizedBox(
      height: Scale.x(
        375,
      ),
      child: PageView.builder(
        controller: controller,
        itemCount: institutions.length,
        itemBuilder: (context, index) {
          final institution = institutions[index];
          final institutionKey = institution['Account']!;
          compareStates[institutionKey] ??= false;

          return Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: Scale.x(25.0)),
                padding: EdgeInsets.symmetric(horizontal: Scale.x(20)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(Scale.x(15)),
                  border: Border.all(
                    color: const Color.fromARGB(255, 188, 188, 188),
                    width: Scale.x(1.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(Scale.x(25)),
                          child: _buildLogo(institution),
                        ),
                      ),
                    ),
                    Text(
                      institution['Account']!,
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
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ] else if (institution.containsKey('Intro Purchases APR') &&
                        institution['Intro Purchases APR'] != null) ...[
                      Text(
                        'APR: ${institution['Intro Purchases APR']}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ] else if (institution.containsKey('Intro Purchases APR') &&
                        institution['Intro Purchases APR'] == null) ...[
                      Text(
                        'APR: ${institution['Purchases APR']}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ] else if (institution.containsKey('APR')) ...[
                      Text(
                        'APR: ${institution['APR']}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ] else if (institution.containsKey('Trade Commission')) ...[
                      SizedBox(height: Scale.x(8.0)),
                      Text(
                        'Trade Commission: ${institution['Trade Commission']}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ],
                    if (institution.containsKey('Min Opening Balance')) ...[
                      SizedBox(height: Scale.x(8.0)),
                      Text(
                        'Min Opening Balance: ${institution['Min Opening Balance']}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ] else if (institution.containsKey('Annual Fee')) ...[
                      SizedBox(height: Scale.x(8.0)),
                      Text(
                        'Annual: ${institution['Annual Fee']}',
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
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ] else if (institution.containsKey('Transaction Fee')) ...[
                      SizedBox(height: Scale.x(8.0)),
                      Text(
                        'Transaction Fee: ${institution['Transaction Fee']}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ] else if (institution.containsKey('Overdraft Fee')) ...[
                      SizedBox(height: Scale.x(8.0)),
                      Text(
                        'Overdraft Fee: ${institution['Overdraft Fee']}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ],
                    if (institution.containsKey('Bonus Offer')) ...[
                      SizedBox(height: Scale.x(8.0)),
                      Text(
                        'Bonus Offer: ${institution['Bonus Offer']}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          color: AppColors.navy,
                          fontSize: Scale.x(FontSizes.statements),
                        ),
                      ),
                    ] else if (institution.containsKey('Asset Classes')) ...[
                      SizedBox(height: Scale.x(8.0)),
                      Text(
                        'Asset Classes: ${institution['Asset Classes']}',
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
                        final termString = institution['Month Term Lengths'];
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
                top: Scale.x(5),
                right: Scale.x(35),
                child: Row(
                  children: [
                    Text(
                      (compareStates[institutionKey] ?? false) ? '' : 'Compare',
                      style: TextStyle(
                        fontFamily: 'Pt Sans',
                        color: AppColors.darkerGrey,
                        fontSize: Scale.x(12),
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
        return AlertDialog(
          title: const Text('Clear Queue'),
          content: const Text(
              'Do you want to clear the compare queue to add this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Clear'),
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
            ),
          ],
        );
      },
    );
  }
}
