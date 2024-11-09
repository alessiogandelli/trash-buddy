import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trashbuddu/bubble.dart';
import 'package:trashbuddu/custom_painter.dart';
import 'package:trashbuddu/feed_page';
import 'package:trashbuddu/header.dart';
import 'package:trashbuddu/leaderboard_page.dart';

import 'package:trashbuddu/monnezza_bloc.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  LatLng? currentLocation;
  final MapController mapController = MapController();

  bool showBubble = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _showMonnezzaDetails(Monnezza monnezza) {
    print(monnezza.image.path);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              monnezza.image.path,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(monnezza.address),
                  const SizedBox(height: 8),
                  Text(
                    'Reported on:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${monnezza.createdAt.day}/${monnezza.createdAt.month}/${monnezza.createdAt.year}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      Geolocator.getPositionStream().listen((Position position) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
        mapController.move(
          LatLng(position.latitude, position.longitude),
          mapController.camera.zoom,
        );
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonnezzaBloc, MonnezzaState>(
      builder: (context, state) {
        return Stack(
          children: [
            // Map Layer
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter:
                    currentLocation ?? const LatLng(46.4786, 11.3326),
                initialZoom: 17,
                onTap: (_, __) {
                  if (showBubble) {
                    setState(() {
                      showBubble = false;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    if (currentLocation != null)
                      Marker(
                        point: currentLocation!,
                        width: 100,
                        height: 100,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showBubble = !showBubble;
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                                key: UniqueKey(),
                                child: Image.asset(
                                  'assets/Avatar.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                      ),
                    if (state is MonnezzaLoaded)
                      ...state.monnezzaList.map(
                        (monnezza) => Marker(
                          point: LatLng(monnezza.latitude, monnezza.longitude),
                          width: 60,
                          height: 60,
                          child: GestureDetector(
                            onTap: () => _showMonnezzaDetails(monnezza),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Bubble Layer
            if (showBubble && currentLocation != null)
              Positioned(
                top: 145,
                left: 20,
                right: 20,
                child: CustomPaint(
                  painter: BubblePainter(),
                  child: const Bubble(),
                ),
              ),
            // Location Button Layer
            Positioned(
              right: 16,
              bottom: 115,
              child: FloatingActionButton(
                onPressed: () {
                  _getCurrentLocation();
                  if (currentLocation != null) {
                    mapController.move(currentLocation!, 16);
                  }
                },
                child: const Icon(Icons.my_location),
              ),
            ),
              Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Header(points: 500, width: MediaQuery.of(context).size.width),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Image.asset(
                'assets/Bar.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  // Add your right button action here
                  print('Right button tapped');
                  //navigate to LEaderboardPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedPage()),
                  );
                },
                child: Image.asset(
                  height: 70,
                  
                  'assets/Tasto_dx.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  // Add your left button action here
                  print('Left button tapped');
                  //navigate to LEaderboardPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaderboardPage()),
                  );
                },
                child: Image.asset(
                  'assets/Tasto_sx.png',
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
