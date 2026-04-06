import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/colors.dart';

class CustomDropdownFormField extends StatefulWidget {
  final String label;
  final IconData? prefixIcon;
  final String? selectedValue;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    this.prefixIcon,
    this.selectedValue,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CustomDropdownFormField> createState() =>
      CustomDropdownFormFieldState();
}

class CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      readOnly: true,
      onTap: () {
        _showDropdownMenu(context);
      },
      decoration: InputDecoration(
        labelText: "State",
        hintText: _selectedValue ?? 'State',
        hintStyle:
            const TextStyle(color: AppColors.navy, fontFamily: 'Open Sans'),
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, color: AppColors.navy),
        labelStyle:
            const TextStyle(color: AppColors.navy, fontFamily: 'Open Sans'),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.green, width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.navy, width: 2),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Raleway',
        color: AppColors.navy,
        fontSize: 16,
      ),
      controller: TextEditingController(text: _selectedValue),
    );
  }

  void _showDropdownMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: AppColors.white,
          height: 200,
          child: ListView(
            children: widget.items.map((item) {
              return ListTile(
                title:
                    Text(item, style: const TextStyle(color: AppColors.navy)),
                onTap: () {
                  setState(() {
                    _selectedValue = item;
                  });
                  widget.onChanged?.call(item);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
