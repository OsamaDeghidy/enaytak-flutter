import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/CustomTextStyle.dart';

class CustomDropdownField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final List<String> items;
  final String? selectedValue;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onTap;

  const CustomDropdownField({
    super.key,
    required this.labelText,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.icon,
    this.hintText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: CustomDropdown<String>(
          initialItem: selectedValue ?? items.first,
          items: items,
          hintText:
              hintText ?? 'Select', // Use the hintText or default to 'Select'
          closedHeaderPadding: const EdgeInsets.all(15),
          maxlines: 2,
          listItemBuilder: (context, item, isSelected, onItemSelect) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              color: isSelected ? Colors.transparent : Colors.transparent,
              child: Text(
                item.toString(),
                style: const CustomTextStyle(
                  fontsize: 14,
                  fontWeight: FontWeight.normal,
                ).getTextStyle(context: context),
              ),
            );
          },
          decoration: CustomDropdownDecoration(
            closedFillColor: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            expandedFillColor: isDarkMode ? Colors.grey[700] : Colors.grey[400],
            hintStyle: const CustomTextStyle(
              fontsize: 14,
              fontWeight: FontWeight.normal,
            ).getTextStyle(context: context),
            headerStyle: const CustomTextStyle(
              fontsize: 14,
              fontWeight: FontWeight.normal,
            ).getTextStyle(context: context),
            noResultFoundStyle: const CustomTextStyle(
              fontsize: 14,
              fontWeight: FontWeight.normal,
            ).getTextStyle(context: context),
            closedSuffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            expandedSuffixIcon: const Icon(
              Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
          ),
          onChanged: (String? value) {
            if (value != null) {
              onChanged(value); // Trigger the onChanged callback
            }
          },
        ),
      ),
    );
  }
}
