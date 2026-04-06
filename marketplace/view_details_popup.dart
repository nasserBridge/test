import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showViewDetails(BuildContext context, institution) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: AppColors.white,
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: double.infinity),
              child: Padding(
                padding: EdgeInsets.all(Scale.x(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(Scale.x(25)),
                        child: _buildPopupLogo(institution),
                      ),
                    ),
                    Text(
                      institution['Account']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        fontSize: Scale.x(FontSizes.statements),
                      ),
                    ),
                    SizedBox(height: Scale.x(15.0)),
                    Container(
                      padding:
                          EdgeInsets.only(left: Scale.x(10), right: Scale.x(2)),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 189, 189, 189)),
                        borderRadius: BorderRadius.circular(Scale.x(10)),
                      ),
                      constraints: BoxConstraints(maxHeight: Scale.x(200)),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...institution.entries.skip(4).map((entry) {
                                final key = entry.key;
                                final value = entry.value;

                                if (value is Map) {
                                  final filteredEntries = value.entries
                                      .where((e) =>
                                          e.value != null && e.value != false)
                                      .toList();
                                  if (filteredEntries.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: Scale.x(12.0)),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '$key:',
                                                style: TextStyle(
                                                  fontFamily: 'Open Sans',
                                                  color: AppColors.navy,
                                                  fontSize: Scale.x(14),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ...filteredEntries.map((nestedEntry) {
                                        final nestedKey = nestedEntry.key;
                                        final nestedValue = nestedEntry.value;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              top: Scale.x(4.0)),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: Scale.x(12.0),
                                                  ),
                                                  child: Text(
                                                    '$nestedKey:',
                                                    style: TextStyle(
                                                      fontFamily: 'Open Sans',
                                                      color: AppColors.navy,
                                                      fontSize: Scale.x(
                                                          FontSizes.statements),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (nestedValue is String &&
                                                  Uri.tryParse(nestedValue)
                                                          ?.hasAbsolutePath ==
                                                      true)
                                                Expanded(
                                                  flex: 3,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      final uri = Uri.parse(
                                                          nestedValue);
                                                      if (!await launchUrl(
                                                          uri)) {
                                                        throw Exception(
                                                            'Could not launch $nestedValue');
                                                      }
                                                    },
                                                    child: Text(
                                                      'View',
                                                      style: TextStyle(
                                                        fontFamily: 'Open Sans',
                                                        color: AppColors.green,
                                                        fontSize: Scale.x(
                                                            FontSizes
                                                                .statements),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              else
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    _formatValue(nestedValue),
                                                    style: TextStyle(
                                                      fontFamily: 'Open Sans',
                                                      color: AppColors.navy,
                                                      fontSize: Scale.x(
                                                          FontSizes.statements),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                } else if (value != null && value != false) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.only(top: Scale.x(12.0)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: Scale.x(5)),
                                            child: Text(
                                              '$key:',
                                              style: TextStyle(
                                                fontFamily: 'Open Sans',
                                                color: AppColors.navy,
                                                fontSize: Scale.x(14),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (value is String &&
                                            Uri.tryParse(value)
                                                    ?.hasAbsolutePath ==
                                                true)
                                          Expanded(
                                            flex: 3,
                                            child: GestureDetector(
                                              onTap: () async {
                                                final uri = Uri.parse(value);
                                                if (!await launchUrl(uri)) {
                                                  throw Exception(
                                                      'Could not launch $value');
                                                }
                                              },
                                              child: Text(
                                                'View',
                                                style: TextStyle(
                                                  fontFamily: 'Open Sans',
                                                  color: AppColors.green,
                                                  fontSize: Scale.x(
                                                      FontSizes.statements),
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              _formatValue(value),
                                              style: TextStyle(
                                                fontFamily: 'Open Sans',
                                                color: AppColors.navy,
                                                fontSize: Scale.x(
                                                    FontSizes.statements),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }).toList(),
                              SizedBox(height: Scale.x(8.0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Scale.x(22.0)),
                    Center(
                      child: Row(
                        children: [
                          Expanded(
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
                                  letterSpacing: Scale.x(1.5),
                                  fontSize: Scale.x(FontSizes.statements),
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
            ),
            Positioned(
              top: Scale.x(20),
              right: Scale.x(25),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontFamily: 'Open Sans',
                    fontSize: Scale.x(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _formatValue(dynamic value) {
  if (value == null) return 'N/A';
  if (value is bool) return value ? 'Yes' : 'No';
  return value.toString();
}

Widget _buildPopupLogo(Map institution) {
  final logo = institution['Logo'];
  if (logo == null || (logo as String).isEmpty) {
    return _logoFallback(institution['Bank']?.toString() ?? '');
  }
  return Image.asset(
    logo,
    height: Scale.x(100),
    fit: BoxFit.contain,
    errorBuilder: (_, __, ___) =>
        _logoFallback(institution['Bank']?.toString() ?? ''),
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
    width: Scale.x(80),
    height: Scale.x(80),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5F2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: Scale.x(26),
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2B6A5E),
        ),
      ),
    ),
  );
}
