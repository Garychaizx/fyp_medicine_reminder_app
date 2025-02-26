// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class NearbyPharmacyPage extends StatefulWidget {
//   @override
//   State<NearbyPharmacyPage> createState() => _NearbyPharmacyPageState();
// }

// class _NearbyPharmacyPageState extends State<NearbyPharmacyPage> {
//   final LatLng _initialCameraPosition = const LatLng(37.7749, -122.4194);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Map'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: _initialCameraPosition,
//           zoom: 12,
//         ),
//         markers: {
//           Marker(
//             markerId: MarkerId('1'),
//             position: _initialCameraPosition,
//             infoWindow: InfoWindow(title: 'Current Location'),
//           ),
//         },
//       ),
//     );
//   }
// }



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class NearbyPharmacyPage extends StatefulWidget {
//   const NearbyPharmacyPage({super.key});

//   @override
//   State<NearbyPharmacyPage> createState() => _NearbyPharmacyPageState();
// }

// class _NearbyPharmacyPageState extends State<NearbyPharmacyPage> {
//   final Completer<GoogleMapController> _controller = Completer();
//   LatLng _currentLocation = const LatLng(3.139, 101.6869); // Default: Kuala Lumpur
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//         _isLoading = false;
//       });

//       final GoogleMapController controller = await _controller.future;
//       controller.animateCamera(CameraUpdate.newLatLng(_currentLocation));
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Nearby Pharmacies")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               mapType: MapType.normal,
//               initialCameraPosition: CameraPosition(
//                 target: _currentLocation,
//                 zoom: 14.0,
//               ),
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//               markers: {
//                 Marker(
//                   markerId: const MarkerId("current_location"),
//                   position: _currentLocation,
//                   infoWindow: const InfoWindow(title: "You are here"),
//                 ),
//               },
//             ),
//     );
//   }
// }
