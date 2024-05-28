import 'package:flutter/material.dart';

class TouchCard extends StatelessWidget {
  final String title;
  final String target;
  final Function(String) onTap;

  const TouchCard({
    super.key,
    required this.title,
    required this.target,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(target),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
