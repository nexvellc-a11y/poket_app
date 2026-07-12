// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// const kGoogleApiKey = "AIzaSyCQpixZAg-OgbyP51tEb-Y1rtjSef91eiM";

// class LocationPickerScreen extends StatefulWidget {
//   @override
//   _LocationPickerScreenState createState() => _LocationPickerScreenState();
// }

// class _LocationPickerScreenState extends State<LocationPickerScreen> {
//   LatLng? _pickedLocation;
//   late GoogleMapController _mapController;
//   LatLng _initialPosition = LatLng(10.8505, 76.2711); // default to Kerala

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _handleSearch() async {
//     final result = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: kGoogleApiKey,
//       mode: Mode.overlay,
//       language: 'en',
//       components: [Component(Component.country, 'in')],
//     );

//     if (result != null) {
//       displayPrediction(result);
//     }
//   }

//   Future<void> displayPrediction(Prediction prediction) async {
//     final places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
//     final detail = await places.getDetailsByPlaceId(prediction.placeId!);
//     final lat = detail.result.geometry!.location.lat;
//     final lng = detail.result.geometry!.location.lng;

//     final searchedLocation = LatLng(lat, lng);

//     setState(() {
//       _pickedLocation = searchedLocation;
//     });

//     _mapController.animateCamera(
//       CameraUpdate.newLatLngZoom(searchedLocation, 15),
//     );
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         log("❌ Location services are disabled.");
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           log("❌ Location permission denied.");
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         log("❌ Location permission permanently denied.");
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         _initialPosition = LatLng(position.latitude, position.longitude);
//         _pickedLocation = _initialPosition;
//       });

//       _mapController.animateCamera(
//         CameraUpdate.newLatLngZoom(_initialPosition, 15),
//       );

//       log("📍 Current location: ${position.latitude}, ${position.longitude}");
//     } catch (e) {
//       log("❌ Error getting current location: $e");
//     }
//   }

//   void _onTap(LatLng position) {
//     setState(() {
//       _pickedLocation = position;
//     });
//     log(
//       "📍 Map Tap - Location picked: Lat: ${position.latitude}, Lng: ${position.longitude}",
//     );
//   }

//   Future<void> _confirmLocation() async {
//     if (_pickedLocation == null) {
//       log("⚠️ No location selected to confirm.");
//       return;
//     }

//     try {
//       final placemarks = await placemarkFromCoordinates(
//         _pickedLocation!.latitude,
//         _pickedLocation!.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         final first = placemarks.first;
//         final place = first.locality ?? '';
//         final pincode = first.postalCode ?? '';
//         final subLocality = first.subLocality ?? ''; // Extract subLocality

//         log(
//           "✅ Placemark data: Locality: $place, SubLocality: $subLocality, Pincode: $pincode, Full: ${first.toJson()}",
//         );

//         Navigator.pop(context, {
//           'place': place,
//           'pincode': pincode,
//           'subLocality': subLocality, // Pass subLocality
//         });
//       } else {
//         log("❌ No placemark data found.");
//       }
//     } catch (error) {
//       log("❌ Error fetching placemark: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Select Location"),
//         actions: [
//           IconButton(icon: Icon(Icons.search), onPressed: _handleSearch),
//         ],
//       ),
//       body: GoogleMap(
//         onMapCreated: (controller) {
//           _mapController = controller;
//           log("🗺️ Map created");
//         },
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition,
//           zoom: 10,
//         ),
//         onTap: _onTap,
//         markers:
//             _pickedLocation != null
//                 ? {
//                   Marker(
//                     markerId: MarkerId("picked"),
//                     position: _pickedLocation!,
//                   ),
//                 }
//                 : {},
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _confirmLocation,
//         child: Icon(Icons.check),
//       ),
//     );
//   }
// }
