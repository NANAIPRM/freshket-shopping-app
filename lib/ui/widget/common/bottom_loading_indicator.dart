import 'package:flutter/material.dart';

class BottomLoadingIndicator extends StatelessWidget {
  const BottomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.purple[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
