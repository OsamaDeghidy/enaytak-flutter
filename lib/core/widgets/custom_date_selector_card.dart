import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:intl/intl.dart';

class CustomDateSelectorCard extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Color backgroundColor;
  final Color textColor;
  final Color activeColor;

  const CustomDateSelectorCard({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.backgroundColor = const Color.fromARGB(25, 0, 128, 128),
    this.textColor = Colors.black,
    this.activeColor = Constant.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Constant.primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Text(
                selectedDate == null
                    ? 'Select Date'
                    : DateFormat('yMMMd').format(selectedDate!),
                style: TextStyle(
                  color: selectedDate == null ? Colors.black : activeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            EasyDateTimeLine(
              initialDate: selectedDate ?? DateTime.now(),
              onDateChange: onDateSelected,
              activeColor: activeColor,
              headerProps: EasyHeaderProps(
                selectedDateStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                ),
                monthStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                ),
                monthPickerType: MonthPickerType.dropDown,
                dateFormatter: const DateFormatter.fullDateDMY(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
