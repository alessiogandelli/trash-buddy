import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trashbuddu/monnezza_bloc.dart';

class AddMonnezza extends StatefulWidget {
  @override
  _AddMonnezzaState createState() => _AddMonnezzaState();
}

class _AddMonnezzaState extends State<AddMonnezza> {
  Position? _currentPosition;
  String? _currentAddress;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
    _getAddressFromLatLng(position);
  }

  _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      if (mounted) {
        setState(() {
          _currentAddress =
              "${place.locality}, ${place.postalCode}, ${place.country}";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }
@override
 Widget build(BuildContext context) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.all(16.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Section
          Text(
            'Location Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentPosition != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Coordinates: ${_currentPosition!.latitude.toStringAsFixed(4)}, "
                          "${_currentPosition!.longitude.toStringAsFixed(4)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (_currentAddress != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.home, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Address: $_currentAddress",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Image Section
          Text(
            'Image Upload',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          if (_image == null)
            InkWell(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 32, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add picture',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_image!.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _image = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      //print('Save Details, ${_currentPosition?.latitude}, ${_currentPosition?.longitude}, $_currentAddress, ${_image?.path}');
                      print('ciao salvo e mando');
                      BlocProvider.of<MonnezzaBloc>(context).add(
                        AddMonnezzaEvent(
                          latitude: _currentPosition?.latitude ?? 0.0,
                          longitude: _currentPosition?.longitude?? 0.0,
                          address: _currentAddress?? '',
                          image: File(_image!.path),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Details'),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
}
