// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:poketstore/controllers/location_controller/location_controller.dart';
// import 'package:provider/provider.dart';
// import 'package:poketstore/model/location_model/location_model.dart';
// import 'dart:convert'; // Import for JSON encoding/decoding

// class MapLocationScreen extends StatefulWidget {
//   @override
//   _MapLocationScreenState createState() => _MapLocationScreenState();
// }

// class _MapLocationScreenState extends State<MapLocationScreen> {
//   GoogleMapController? _mapController;
//   LatLng? _selectedLatLng;
//   String _selectedAddress = "Selecting location...";
//   Marker?
//   _selectedLocationMarker; // To display a marker on the selected location

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _selectedLatLng = LatLng(position.latitude, position.longitude);
//       });
//       await _updateAddress(_selectedLatLng!); // Await here
//       _addMarker(_selectedLatLng!);
//       if (_mapController != null) {
//         _mapController?.animateCamera(
//           CameraUpdate.newLatLngZoom(_selectedLatLng!, 15),
//         );
//       }
//     } catch (e) {
//       log("Error getting current location: $e");
//       // Handle error appropriately
//     }
//   }

//   Future<void> _updateAddress(LatLng latLng) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         setState(() {
//           _selectedAddress =
//               "${place.subAdministrativeArea ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''} - ${place.postalCode ?? ''}";
//         });
//         // Log the placemark data
//         log(
//           "Geocoding API Response: ${jsonEncode(place.toJson())}",
//         ); //  Log the entire placemark object
//       } else {
//         setState(() {
//           _selectedAddress = "No address found for this location.";
//         });
//         log("Geocoding API Response: No address found");
//       }
//     } catch (e) {
//       log("Error reverse geocoding: $e");
//       setState(() {
//         _selectedAddress = "Error getting address.";
//       });
//       log("Geocoding API Error: $e");
//     }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//   }

//   // New function to handle map taps
//   void _onMapTapped(LatLng latLng) async {
//     setState(() {
//       _selectedLatLng = latLng;
//     });
//     await _updateAddress(latLng); // Await here
//     _addMarker(latLng);
//   }

//   void _addMarker(LatLng location) {
//     setState(() {
//       _selectedLocationMarker = Marker(
//         markerId: MarkerId('selected_location'),
//         position: location,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locationMapController = Provider.of<LocationMapController>(
//       context,
//       listen: false,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Location'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: () {
//               if (_selectedLatLng != null) {
//                 List<String> parts = _selectedAddress.split(', ');
//                 String? place, locality, stateWithPincode;
//                 String? state, pincode;

//                 if (parts.length >= 3) {
//                   place = parts[0];
//                   locality = parts[1];
//                   stateWithPincode = parts[2];
//                   List<String> statePincodeParts = stateWithPincode.split(
//                     ' - ',
//                   );
//                   if (statePincodeParts.length == 2) {
//                     state = statePincodeParts[0];
//                     pincode = statePincodeParts[1];
//                   } else {
//                     state = stateWithPincode;
//                   }
//                 } else if (parts.length == 2) {
//                   place = parts[0];
//                   locality = parts[1];
//                 } else if (parts.length == 1) {
//                   place = parts[0];
//                 }

//                 final newLocation = LocationMapModel(
//                   place: place?.trim() ?? '',
//                   locality: locality?.trim() ?? '',
//                   state: state?.trim() ?? '',
//                   pincode: pincode?.trim() ?? '',
//                 );

//                 // Log the data before sending it.
//                 log('Sending location data: ${newLocation.toJson()}');

//                 Navigator.pop(
//                   context,
//                   newLocation,
//                 ); // Pass the LocationMapModel
//               } else {
//                 // Optionally show a message to the user to select a location
//               }
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: _selectedLatLng ?? const LatLng(0, 0),
//               zoom: 12.0,
//             ),
//             myLocationEnabled: true,
//             onTap: _onMapTapped,
//             markers:
//                 _selectedLocationMarker != null
//                     ? {_selectedLocationMarker!}
//                     : {},
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.8),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 _selectedAddress,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
