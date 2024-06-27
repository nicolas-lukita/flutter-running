import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen(
      {super.key,
      required this.isTracking,
      required this.userPolyLineCoordinates,
      required this.onChangeUserPolyLineCoordinates,
      required this.totalDistance,
      required this.calculateTotalDistance});
  final bool isTracking;
  final List<LatLng> userPolyLineCoordinates;
  final double totalDistance;
  final Function(LatLng) onChangeUserPolyLineCoordinates;
  final Function(List<LatLng>) calculateTotalDistance;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  // List<LatLng> polylineCoordinates = [];
  List<LatLng> routePolylineCoordinates = [];
  LocationData? currentLocation;
  Location location = Location();
  bool isCameraFollowsLocation = true;
  bool isTrackingPolyline = true;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon =
      BitmapDescriptor.defaultMarkerWithHue(300);

  void getCurrentLocation() async {
    try {
      currentLocation = await location.getLocation();
      setState(() {});

      location.onLocationChanged.listen((newLocation) {
        setState(() {
          currentLocation = newLocation;

          if (widget.isTracking) {
            widget.onChangeUserPolyLineCoordinates(
                LatLng(newLocation.latitude!, newLocation.longitude!));
            widget.calculateTotalDistance(widget.userPolyLineCoordinates);
          }
        });
        isCameraFollowsLocation ? _updateCameraPosition(newLocation) : null;
      });
    } catch (e) {
      throw ("getCurrentLocation error: $e");
    }
  }

  void _updateCameraPosition(LocationData newLocation) async {
    final GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(newLocation.latitude!, newLocation.longitude!),
          zoom: 15,
        ),
      ),
    );
  }

  void panCameraToCurrentLocation() async {
    try {
      currentLocation = await location.getLocation();
      location.onLocationChanged.listen((newLocation) {
        _updateCameraPosition(newLocation);
      });
    } catch (e) {
      throw ("panCameraToCurrentLocation error: $e");
    }
  }

  void getPolyPoints(LatLng start, LatLng finish) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        FlutterConfig.get('GOOGLE_MAPS_API_KEY'),
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(finish.latitude, finish.longitude));
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        routePolylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    } else {
      throw ("getPolyPoints error");
    }
  }

  @override
  void initState() {
    getPolyPoints(sourceLocation, destination);
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.terrain,
            initialCameraPosition: CameraPosition(
                target: (currentLocation != null)
                    ? LatLng(
                        currentLocation!.latitude!, currentLocation!.longitude!)
                    : sourceLocation,
                zoom: 14.5),
            markers: {
              // const Marker(
              //   markerId: MarkerId("source"),
              //   position: sourceLocation,
              // ),
              // const Marker(
              //   markerId: MarkerId("destination"),
              //   position: destination,
              // ),
              // if (currentLocation != null)
              //   Marker(
              //       markerId: const MarkerId("currentLocation"),
              //       icon: currentLocationIcon,
              //       position: LatLng(currentLocation!.latitude!,
              //           currentLocation!.longitude!))
            },
            polylines: {
              Polyline(
                  polylineId: const PolylineId("route"),
                  points: routePolylineCoordinates,
                  color: Colors.red,
                  width: 6),
              if (widget.userPolyLineCoordinates.isNotEmpty)
                Polyline(
                    polylineId: const PolylineId("current-location"),
                    points: widget.userPolyLineCoordinates,
                    color: Colors.blue,
                    width: 2),
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ],
      ),
    );
  }
}
