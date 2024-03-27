import 'package:flutter/material.dart';

class RoundTitle extends StatelessWidget {
  final String imagePath;
  const RoundTitle({
    super.key,
    required this.imagePath,  
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[100],
      ),
      child: Image.asset(
        imagePath,
        height: 30,
      ),
    );
  }
}
