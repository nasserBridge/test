import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

void showFilterDetails(
  BuildContext context,
  Map<String, Map<String, bool>> currentFilters,
  void Function(Map<String, Map<String, bool>>) onFilterUpdate,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: AppColors.white,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                top: Scale.x(40),
                left: Scale.x(30),
                right: Scale.x(30),
                bottom: Scale.x(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: currentFilters.entries.map((section) {
                          return CustomCheckboxSection(
                            title: section.key,
                            filters: section.value,
                            onChanged: (label, value) {
                              setState(() {
                                section.value[label] = value;
                              });
                              onFilterUpdate(Map.from(currentFilters));
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: Scale.x(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            for (final section in currentFilters.values) {
                              for (final key in section.keys) {
                                section[key] = false;
                              }
                            }
                          });
                          onFilterUpdate(Map.from(currentFilters));
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          side: const BorderSide(
                            color: AppColors.navy,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            color: AppColors.navy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: Scale.x(12)),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class CustomCheckboxSection extends StatelessWidget {
  final String title;
  final Map<String, bool> filters;
  final void Function(String, bool) onChanged;

  const CustomCheckboxSection({
    super.key,
    required this.title,
    required this.filters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        CustomCheckboxFlow(
          items: filters,
          onChanged: onChanged,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class CustomCheckboxTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomCheckboxTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.8,
            child: Theme(
              data: Theme.of(context).copyWith(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Checkbox(
                activeColor: AppColors.navy,
                focusColor: AppColors.green,
                hoverColor: AppColors.green,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: value,
                onChanged: (bool? newValue) => onChanged(newValue ?? false),
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class CustomCheckboxFlow extends StatelessWidget {
  final Map<String, bool> items;
  final void Function(String, bool) onChanged;

  const CustomCheckboxFlow({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> rows = [];
        List<Widget> currentRow = [];
        double rowWidth = 0;

        for (var entry in items.entries) {
          final checkbox = Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 0),
            child: CustomCheckboxTile(
              label: entry.key,
              value: entry.value,
              onChanged: (val) => onChanged(entry.key, val),
            ),
          );

          final textWidth = _calculateTextWidth(
            entry.key,
            const TextStyle(fontSize: 13),
          );
          final estimatedWidth = textWidth + 50;

          if (rowWidth + estimatedWidth > constraints.maxWidth &&
              currentRow.isNotEmpty) {
            rows.add(Row(children: currentRow));
            currentRow = [checkbox];
            rowWidth = estimatedWidth;
          } else {
            currentRow.add(checkbox);
            rowWidth += estimatedWidth;
          }
        }

        if (currentRow.isNotEmpty) {
          rows.add(Row(children: currentRow));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }

  double _calculateTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp.width;
  }
}
