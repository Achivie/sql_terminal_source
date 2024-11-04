import 'package:flutter/material.dart';

import '../services/styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onTap,
    required this.head,
  });

  final VoidCallback onTap;
  final String head;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50,
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            head,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
