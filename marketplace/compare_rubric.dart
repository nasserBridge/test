import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/transfer_appbar.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CompareRubric extends StatefulWidget {
  final List<Map<String, dynamic>> selectedAccounts;

  const CompareRubric({super.key, required this.selectedAccounts});

  @override
  CompareRubricState createState() => CompareRubricState();
}

class CompareRubricState extends State<CompareRubric> {
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  bool _isHeaderScrolling = false;
  bool _isBodyScrolling = false;
  double _customScrollbarPosition = 0.0;
  bool _showVerticalScrollbar = false;

  late List<Map<String, dynamic>> _currentAccounts;
  late Map<String, Map<String, dynamic>> comparisonData;
  late List<String> dynamicHeaders;

  @override
  void initState() {
    super.initState();

    _currentAccounts = List<Map<String, dynamic>>.from(widget.selectedAccounts);
    _initializeData();

    _headerScrollController.addListener(() {
      if (!_isBodyScrolling) {
        _isHeaderScrolling = true;
        _bodyScrollController.jumpTo(_headerScrollController.offset);
        _isHeaderScrolling = false;
      }
    });

    _bodyScrollController.addListener(() {
      if (!_isHeaderScrolling) {
        _isBodyScrolling = true;
        _headerScrollController.jumpTo(_bodyScrollController.offset);
        _isBodyScrolling = false;
      }
      setState(() {
        _customScrollbarPosition = _bodyScrollController.offset;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verticalScrollController.hasClients) {
        setState(() {
          _showVerticalScrollbar =
              _verticalScrollController.position.maxScrollExtent > 0;
        });
      }
    });

    _verticalScrollController.addListener(() {
      setState(() {});
    });
  }

  void _initializeData() {
    dynamicHeaders = extractDynamicHeaders(_currentAccounts);
    comparisonData = buildComparisonData(_currentAccounts);
  }

  void _removeAccount(String name) {
    final parts = name.split(': ');
    final bank = parts[0];
    final account = parts[1];

    _currentAccounts
        .removeWhere((acc) => acc['Bank'] == bank && acc['Account'] == account);
    setState(() {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headersWithRemove = [...dynamicHeaders, 'Remove'];

    return Scaffold(
      backgroundColor: AppColors.customGreen,
      appBar: TransferAppBar(),
      body: Container(
        margin: EdgeInsets.all(Scale.x(30)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Scale.x(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(76),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, Scale.x(3)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Scale.x(15)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                controller: _verticalScrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: Scale.x(60)),
                            for (var name in comparisonData.keys)
                              _buildFixedCell(name),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _bodyScrollController,
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: Scale.x(60)),
                                for (var entry in comparisonData.entries)
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        for (var feature in dynamicHeaders)
                                          _buildDataCell(formatValue(
                                              entry.value[feature])),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildHeaderCell('Account', fixed: true),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _headerScrollController,
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        color: AppColors.navy,
                        child: Row(
                          children: [
                            for (final feature in headersWithRemove)
                              _buildHeaderCell(feature),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: Scale.x(160),
                right: 0,
                child: Container(
                  margin: EdgeInsets.only(left: Scale.x(2), right: Scale.x(10)),
                  height: Scale.x(5),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double viewWidth = constraints.maxWidth;
                      double contentWidth = _bodyScrollController
                              .position.hasContentDimensions
                          ? _bodyScrollController.position.maxScrollExtent +
                              _bodyScrollController.position.viewportDimension
                          : viewWidth;
                      double thumbWidth =
                          viewWidth * (viewWidth / contentWidth);
                      double maxThumbOffset = viewWidth - thumbWidth;
                      double thumbOffset = (_customScrollbarPosition /
                              (contentWidth - viewWidth)) *
                          maxThumbOffset;

                      if (thumbOffset.isNaN || thumbOffset < 0) {
                        thumbOffset = 0;
                      }

                      return Stack(
                        children: [
                          Positioned(
                            left: thumbOffset,
                            child: Container(
                              width: thumbWidth,
                              height: Scale.x(3),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 172, 171, 171),
                                borderRadius:
                                    BorderRadius.circular(Scale.x(10)),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (_showVerticalScrollbar)
                Positioned(
                  top: Scale.x(61),
                  bottom: 0,
                  right: 0,
                  width: Scale.x(5),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double viewHeight = constraints.maxHeight + Scale.x(20);
                      double contentHeight = _verticalScrollController
                              .position.hasContentDimensions
                          ? _verticalScrollController.position.maxScrollExtent +
                              _verticalScrollController
                                  .position.viewportDimension
                          : viewHeight;

                      double thumbHeight =
                          viewHeight * (viewHeight / contentHeight);
                      double maxThumbOffset = viewHeight - thumbHeight;
                      double thumbOffset = (_verticalScrollController.offset /
                              (contentHeight - viewHeight)) *
                          maxThumbOffset;

                      if (thumbOffset.isNaN || thumbOffset < 0) {
                        thumbOffset = 0;
                      }

                      return Stack(
                        children: [
                          Positioned(
                            top: thumbOffset,
                            child: Container(
                              width: Scale.x(3.5),
                              height: thumbHeight,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 172, 171, 171),
                                borderRadius:
                                    BorderRadius.circular(Scale.x(10)),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, {bool fixed = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Scale.x(8)),
      width: Scale.x(160),
      height: Scale.x(60),
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.white,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
            fontSize: Scale.x(14),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildFixedCell(String label) {
    List<String> parts = label.split(': ');
    String bank = parts.length > 1 ? parts[0] : 'Unknown';
    String account = parts.length > 1 ? parts[1] : label;
    String name = '$bank: $account';

    String? matchedUrl;
    for (var acc in _currentAccounts) {
      if (acc['Account'] == account && acc['Bank'] == bank) {
        matchedUrl = acc['URL'];
        break;
      }
    }

    return Container(
      padding:
          EdgeInsets.fromLTRB(Scale.x(8), Scale.x(8), Scale.x(3), Scale.x(8)),
      width: Scale.x(160),
      height: Scale.x(120),
      decoration: const BoxDecoration(color: AppColors.grey),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$bank: ',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Raleway',
                        fontSize: Scale.x(14),
                      ),
                    ),
                    TextSpan(
                      text: account,
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Raleway',
                        fontSize: Scale.x(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (matchedUrl != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    alignment: Alignment.center,
                    icon: Icon(Icons.open_in_new, size: Scale.x(18)),
                    color: AppColors.navy,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      launchUrl(Uri.parse(matchedUrl!));
                    },
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    alignment: Alignment.center,
                    icon: Icon(Icons.remove, size: Scale.x(18)),
                    color: const Color.fromARGB(255, 207, 43, 31),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _removeAccount(name),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String value) {
    if (value == 'null' || value.trim().isEmpty) {
      value = 'N/A';
    }

    final isUrl = Uri.tryParse(value)?.hasAbsolutePath ?? false;

    if (value == 'true' || value == 'false') {
      final isTrue = value == 'true';
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: Scale.x(8), vertical: Scale.x(8)),
        width: Scale.x(160),
        height: Scale.x(120),
        decoration: const BoxDecoration(color: AppColors.white),
        child: Center(
          child: Icon(
            isTrue ? Icons.check : Icons.close,
            color: isTrue
                ? AppColors.green
                : const Color.fromARGB(255, 207, 43, 31),
            size: Scale.x(28),
          ),
        ),
      );
    }

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: Scale.x(8), vertical: Scale.x(8)),
      width: Scale.x(160),
      height: Scale.x(120),
      decoration: const BoxDecoration(color: AppColors.white),
      child: Center(
        child: isUrl
            ? InkWell(
                onTap: () => launchUrl(Uri.parse(value)),
                child: Text(
                  'View',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                    fontSize: Scale.x(14),
                  ),
                ),
              )
            : Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                  fontSize: Scale.x(14),
                ),
              ),
      ),
    );
  }

  String formatValue(dynamic value) {
    if (value == null) return 'N/A';

    if (value is Map<String, dynamic>) {
      final buffer = StringBuffer();

      for (final entry in value.entries) {
        final key = entry.key;
        final val = entry.value;

        if (val == null || val == false) {
          // Skip null or false values
          continue;
        }

        if (val == 'true') {
          buffer.writeln(key); // Just the key
        } else {
          buffer.writeln('$key: $val'); // Key and value
        }
      }

      return buffer.toString().trim();
    }
    if (value is List) {
      if (value.isNotEmpty && value.first is Map) {
        return value
            .map((map) => (map as Map)
                .entries
                .map((e) => '${e.key}: ${e.value ?? 'N/A'}')
                .join('\n'))
            .join('\n');
      } else {
        return value.join(', ');
      }
    }
    if (value is bool) return value ? 'Yes' : 'No';
    return value.toString();
  }

  Map<String, dynamic>? maybeParseJsonMap(String value) {
    // Check if the string is actually a map-like format
    if (!value.startsWith('{') || !value.endsWith('}')) return null;

    String cleaned = value.substring(1, value.length - 1);
    if (cleaned.trim().isEmpty) return {};

    List<String> pairs = cleaned.split(', ');

    Map<String, dynamic> result = {};
    for (String pair in pairs) {
      List<String> kv = pair.split(': ');
      if (kv.length == 2) {
        final key = kv[0];
        final val = kv[1];

        if (val != 'null' && val != 'false') {
          result[key] = val;
        }
      }
    }

    return result;
  }

  List<String> extractDynamicHeaders(List<Map<String, dynamic>> accounts) {
    if (accounts.isEmpty) return [];

    final firstAccount = accounts.first;
    final keys = firstAccount.keys.toList();
    return keys.sublist(4);
  }

  Map<String, Map<String, dynamic>> buildComparisonData(
      List<Map<String, dynamic>> accounts) {
    final Map<String, Map<String, dynamic>> comparisonData = {};

    for (var account in accounts) {
      final String name =
          '${account['Bank'] ?? 'Unknown'}: ${account['Account'] ?? 'Unknown'}';
      comparisonData[name] = {};

      account.forEach((key, value) {
        if (['URL', 'Logo', 'Bank', 'Account'].contains(key)) return;
        if (value == null || value == false) return;
        if (value is List && value.isNotEmpty && value.first is Map) {
          final merged = <String, dynamic>{};
          for (final item in value) {
            if (item is Map) merged.addAll(item.cast<String, dynamic>());
          }
          comparisonData[name]![key] = merged;
        } else if (value is Map) {
          comparisonData[name]![key] = value;
        } else if (value is String &&
            value.startsWith('{') &&
            value.endsWith('}')) {
          //print(value);
          final parsed = maybeParseJsonMap(value);
          //print(parsed);
          if (parsed != null) {
            comparisonData[name]![key] = parsed;
          } else {
            comparisonData[name]![key] = value;
          }
        } else {
          comparisonData[name]![key] = value;
        }
      });
    }

    return comparisonData;
  }
}
