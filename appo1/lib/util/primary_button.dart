import 'package:flutter/material.dart';

class myButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const myButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color.fromARGB(97, 33, 51, 59)
            : const Color.fromARGB(125, 166, 190, 230),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // controls button size
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? const Color.fromARGB(169, 189, 209, 231)
              : const Color.fromARGB(179, 55, 61, 70),
        ),
      ),
    );
  }
}
