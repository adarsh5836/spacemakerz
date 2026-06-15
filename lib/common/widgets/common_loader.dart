import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CommonLoader extends StatelessWidget {
  final Color color;
  final double size;

  const CommonLoader({
    super.key,
    this.color = AppColors.primaryBlue,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}
