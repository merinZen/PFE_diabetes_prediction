import 'package:flutter/material.dart';

// ignore: must_be_immutable
class bottn extends StatelessWidget {
  final String text;
  final VoidCallback onPressed; 

  const bottn({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: const Color.fromARGB(199, 238, 242, 246),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(text,
      style: const TextStyle(
          color: Color.fromARGB(100, 0, 0, 0),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
