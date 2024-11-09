// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trashbuddu/monnezza_bloc.dart';
import 'package:trashbuddu/monnezza_repository.dart';
import 'package:trashbuddu/my_app_bar.dart';
import 'package:trashbuddu/my_map.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => MonnezzaBloc(
        repository: MonnezzaRepository(),
      )..add(LoadMonnezzaEvent()),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCameraPressed() {
    // Add camera functionality here
    print('Camera button pressed');
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: Scaffold(
        body: MyMap(),
      //   bottomNavigationBar: CustomBottomBar(
      //   selectedIndex: _selectedIndex,
      //   onItemSelected: _onItemSelected,
      //   leftButtonImage: 'assets/trashbtn.png',
      //   rightButtonImage: 'assets/trashbtn.png',
      // )
      ),
    );
  }
}