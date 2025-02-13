import 'package:flutter/material.dart';

class TimeHeader extends StatelessWidget {
  final String time;

  const TimeHeader({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}
