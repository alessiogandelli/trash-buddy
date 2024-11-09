import 'package:flutter/material.dart';
import 'package:trashbuddu/add_monnezza.dart';

import 'package:flutter/material.dart';
import 'package:trashbuddu/add_monnezza.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String leftButtonImage;
  final String rightButtonImage;

  const CustomBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.leftButtonImage,
    required this.rightButtonImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.green,
                Colors.green.withOpacity(0.8),
                Colors.green.withOpacity(0.4),
                Colors.green.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () => onItemSelected(0),
                  child: Image.asset(
                    leftButtonImage,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () => onItemSelected(1),
                  child: Image.asset(
                    rightButtonImage,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}