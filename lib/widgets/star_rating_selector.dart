import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StarRatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final int maxStars;

  const StarRatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;

        return GestureDetector(
          onTap: () => onChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 25.sp,
              color: isFilled ? const Color(0xFFE7C35A) : const Color(0xFF8A8F98),
            ),
          ),
        );
      }),
    );
  }
}
