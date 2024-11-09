import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;

  const CustomDialog({
    Key? key,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 333,
          minWidth: 200,
        ),
        margin: const EdgeInsets.only(top: 40), // Space for the tail
        child: child,
      ),
    );
  }
}
