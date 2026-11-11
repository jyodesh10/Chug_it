import 'package:flutter/material.dart';
import 'package:jhyapp/constants/colors.dart';
import 'package:jhyapp/constants/textstyle.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final double minHeight;
  final Color backgroundColor;
  final Color foregroundColor;
  final double radius;
  final TextStyle? textStyle;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
    this.minHeight = 54,
    this.backgroundColor = const Color(0xFFE5E7EA),
    this.foregroundColor = const Color(0xFF171A1D),
    this.radius = 14,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final buttonTextStyle = textStyle ??
        titleStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: backgroundClr,
        );

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(minHeight),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: buttonTextStyle,
        ),
      ),
    );
  }
}
