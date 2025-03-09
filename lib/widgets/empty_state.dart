import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
            child: ClipOval(child: Image.asset('assets/giphy.gif', fit: BoxFit.cover)),
          ),
          const SizedBox(height: 20),
          const Text('Manage Your Meds', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text(
            'Add your meds to be reminded on time \nand track your health',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
