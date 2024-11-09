// lib/blocs/monnezza/monnezza_event.dart

// lib/models/monnezza_model.dart

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trashbuddu/monnezza_repository.dart';


class Monnezza {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final File image;
  final DateTime createdAt;
  final String description = '';
  final String? type = '';

  Monnezza({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.image,
    required this.createdAt,
  });

factory Monnezza.fromJson(Map<String, dynamic> json) {
  return Monnezza(
    id: json['id'] ?? '123',
    latitude: json['latitude'] ?? 11.2,
    longitude: json['longitude'] ?? 42.1,
    address: json['address'] ?? 'casa',
    image: File(json['image']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}
}


abstract class MonnezzaEvent {}

class AddMonnezzaEvent extends MonnezzaEvent {
  final double latitude;
  final double longitude;
  final String address;
  final File image;

  AddMonnezzaEvent({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.image,
  });
}

class LoadMonnezzaEvent extends MonnezzaEvent {}

// lib/blocs/monnezza/monnezza_state.dart
abstract class MonnezzaState {}

class MonnezzaInitial extends MonnezzaState {}

class MonnezzaLoading extends MonnezzaState {}

class MonnezzaLoaded extends MonnezzaState {
  final List<Monnezza> monnezzaList;

  MonnezzaLoaded(this.monnezzaList);
}

class MonnezzaAdded extends MonnezzaState {
  final Monnezza monnezza;

  MonnezzaAdded(this.monnezza);
}

class MonnezzaError extends MonnezzaState {
  final String message;

  MonnezzaError(this.message);
}

// lib/blocs/monnezza/monnezza_bloc.dart


class MonnezzaBloc extends Bloc<MonnezzaEvent, MonnezzaState> {
  final MonnezzaRepository repository;

  MonnezzaBloc({required this.repository}) : super(MonnezzaInitial()) {
    on<LoadMonnezzaEvent>(_onLoadMonnezza);
    on<AddMonnezzaEvent>(_onAddMonnezza);
  }

  Future<void> _onLoadMonnezza(
    LoadMonnezzaEvent event,
    Emitter<MonnezzaState> emit,
  ) async {
    print('loading monnezza');
    emit(MonnezzaLoading());
    try {
      final monnezzaList = await repository.getMonnezzaList();
      print('loaded $monnezzaList');
      emit(MonnezzaLoaded(monnezzaList));
    } catch (e) {
      print('error $e');
      emit(MonnezzaError(e.toString()));
    }
  }

  Future<void> _onAddMonnezza(
    AddMonnezzaEvent event,
    Emitter<MonnezzaState> emit,
  ) async {
    print('Adding monnezza... ${event.image}, ${event.longitude}');
    try {
      await repository.addMonnezza(
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
        image: event.image,
      );
      add(LoadMonnezzaEvent());
    } catch (e) {
      emit(MonnezzaError(e.toString()));
    }
  }
}