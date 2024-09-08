import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CarService {
  // Define the method channel for communicating with native Android code
  static const MethodChannel _channel =
      MethodChannel('dev.haradama.flutter_aaos_car_property_example/car');

  // Method to initialize the CarPropertyManager
  Future<void> initializeCarManager() async {
    try {
      // Invoke the method on the native side to initialize the car manager
      await _channel.invokeMethod('initializeCarManager');
    } catch (e) {
      // Log the error in debug mode if initialization fails
      if (kDebugMode) {
        print('Error initializing Car Manager: $e');
      }
    }
  }

  // Generic method to get a car property based on its propertyId and areaId
  Future<dynamic> getCarProperty(int propertyId, int areaId) async {
    try {
      // Invoke the native method to get the car property value
      final dynamic value = await _channel.invokeMethod(
          'getCarProperty', {'propertyId': propertyId, 'areaId': areaId});
      return value; // Return the value retrieved from the native side
    } catch (e) {
      // Log the error in debug mode if retrieving the property fails
      if (kDebugMode) {
        print('Error getting car property: $e');
      }
      return null; // Return null in case of an error
    }
  }

  // Generic method to set a car property based on its propertyId, areaId, and value
  Future<void> setCarProperty(int propertyId, int areaId, dynamic value) async {
    try {
      // Invoke the native method to set the car property value
      final dynamic result = await _channel.invokeMethod('setCarProperty',
          {'propertyId': propertyId, 'areaId': areaId, 'value': value});
      if (kDebugMode) {
        // Log the result in debug mode
        print(result);
      }
    } catch (e) {
      // Log the error in debug mode if setting the property fails
      if (kDebugMode) {
        print('Error setting car property: $e');
      }
    }
  }
}
