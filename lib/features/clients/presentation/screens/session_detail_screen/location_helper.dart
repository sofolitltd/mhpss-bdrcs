import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '/core/logger/app_logger.dart';

Future<Position?> getGpsPosition(String sessionId) async {
  try {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      AppLogger.warn('Location permission denied');
      return null;
    }
    if (permission == LocationPermission.deniedForever) {
      AppLogger.warn('Location permission denied forever');
      return null;
    }
  } catch (e, stack) {
    AppLogger.error('Location permission request failed', null, e, stack);
    return null;
  }

  const desiredAccuracy = 10.0;
  const maxAttempts = 5;
  Position? best;
  var latSum = 0.0;
  var lngSum = 0.0;
  var goodCount = 0;

  final locationSettings = kIsWeb
      ? const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 30),
        )
      : const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        );

  for (var i = 0; i < maxAttempts; i++) {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      final acc = pos.accuracy;
      if (best == null || best.accuracy > acc) {
        best = pos;
      }
      if (acc <= desiredAccuracy && acc > 0) {
        latSum += pos.latitude;
        lngSum += pos.longitude;
        goodCount++;
      }
      if (goodCount >= 2) break;
    } catch (e, stack) {
      AppLogger.warn('GPS attempt $i failed', {'sessionId': sessionId}, e);
      if (i == maxAttempts - 1) {
        AppLogger.error(
          'All GPS attempts exhausted',
          {'sessionId': sessionId},
          e,
          stack,
        );
      }
    }
    if (i < maxAttempts - 1)
      await Future.delayed(const Duration(milliseconds: 800));
  }

  if (goodCount >= 1) {
    return Position(
      latitude: latSum / goodCount,
      longitude: lngSum / goodCount,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  AppLogger.info('GPS location recorded', {
    'sessionId': sessionId,
    'latitude': best?.latitude,
    'longitude': best?.longitude,
    'accuracy': best?.accuracy,
    'goodReadings': goodCount,
  });

  return best;
}
