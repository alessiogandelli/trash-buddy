import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:trashbuddu/add_monnezza.dart';

class Bubble extends StatelessWidget {
  const Bubble({super.key});

  void _handleReportTap(BuildContext context) {
    showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  width: double.infinity,
                 //height: MediaQuery.of(context).size.height * 0.3,
                  child: AddMonnezza(),
                );
                
              },
            );
              
            }

  void _handleCleanTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          // Add your bottom sheet content here
          child: Text('Clean bottom sheet'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What are we doing?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: Color.fromRGBO(168, 37, 91, 1)
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButtonWithCaption(
                  context: context,
                  image: './assets/trashbtn.png',
                  caption: 'Report',
                  apex: '+ 1',
                  onTap: () => _handleReportTap(context),
                ),
                _buildButtonWithCaption(
                  context: context,
                  image: './assets/cleanbtn.png',
                  caption: 'Clean',
                  apex: '+ 2',
                  onTap: () => _handleCleanTap(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonWithCaption({
    required BuildContext context,
    required String image,
    required String caption,
    required String apex,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    image,
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  apex,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          )
        ),
      ],
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}