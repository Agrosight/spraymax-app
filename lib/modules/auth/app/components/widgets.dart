import 'package:flutter/material.dart';
import 'package:spraymax/modules/common/consts.dart';

class IconWithNameWidget extends StatelessWidget {
  const IconWithNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 20, left: 20),
      child: Image.asset(
        imageIconLogin,
        fit: BoxFit.contain,
      ),
    );
  }
}
