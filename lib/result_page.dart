import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResultPage extends StatelessWidget {
  ResultPage(
      {super.key,
      required this.userPolylineCoordinates,
      required this.totalDistance,
      required this.elapsedTime,
      required this.elapsedTimeString});
  final List<LatLng> userPolylineCoordinates;
  final double totalDistance;
  final Duration elapsedTime;
  final String elapsedTimeString;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  @override
  Widget build(BuildContext context) {
    final averageSpeed = ((totalDistance / 100000) / elapsedTime.inSeconds);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Result",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              mapType: MapType.terrain,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      userPolylineCoordinates[
                              userPolylineCoordinates.length - 1]
                          .latitude,
                      userPolylineCoordinates[
                              userPolylineCoordinates.length - 1]
                          .longitude),
                  zoom: 14.5),
              polylines: {
                Polyline(
                    polylineId: const PolylineId("route"),
                    points: userPolylineCoordinates,
                    color: Colors.red,
                    width: 6),
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Time",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            elapsedTimeString,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Distance",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "${(totalDistance / 100000).toStringAsFixed(2)} Km",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Avg Speed",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "${averageSpeed.toStringAsFixed(averageSpeed > 0.01 ? 2 : 3)} Kmph",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
