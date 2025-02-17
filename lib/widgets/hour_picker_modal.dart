import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class HourPickerModal extends StatefulWidget {
  final int initialValue;
  final Function(int) onValueSelected;

  const HourPickerModal({
    Key? key,
    required this.initialValue,
    required this.onValueSelected,
  }) : super(key: key);

  @override
  _HourPickerModalState createState() => _HourPickerModalState();
}

class _HourPickerModalState extends State<HourPickerModal> {
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue; // Store initial value
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            "Select Hour Interval",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Center(
              child: NumberPicker(
                value: selectedValue,
                minValue: 1,
                maxValue: 24,
                selectedTextStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 11, 24, 66)),
                textStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                onChanged: (newValue) {
                  setState(() {
                    selectedValue = newValue; // Update state
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onValueSelected(selectedValue); // Pass the final value
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 11, 24, 66),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("Confirm", style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
