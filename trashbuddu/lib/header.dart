import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final int points;
  final int maxPoints;
  final double width; // Add width parameter

  const Header({
    super.key,
    required this.points,
    required this.width, // Make width required
    this.maxPoints = 1000,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox( // Wrap with SizedBox to constrain width
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [

            Image.asset(
              'assets/Icon_profile.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Points: $points/$maxPoints',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: points / maxPoints,
                      minHeight: 10,
                      backgroundColor: const Color.fromARGB(255, 142, 68, 68),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}