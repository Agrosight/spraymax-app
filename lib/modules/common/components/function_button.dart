import 'package:flutter/material.dart';
import 'package:spraymax/modules/common/collor.dart';
class FunctionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final double? height;

  const FunctionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = CustomColor.primaryColor,
    this.textColor = Colors.white,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedWidth = width ?? MediaQuery.of(context).size.width * 0.4;
    final double resolvedHeight = height ?? MediaQuery.of(context).size.height * 0.05;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(resolvedWidth, resolvedHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), 
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
