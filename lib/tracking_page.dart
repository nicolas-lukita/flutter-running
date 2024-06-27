import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_live_map/helpers/formatters.dart';
import 'package:flutter_live_map/map_screen.dart';
import 'package:flutter_live_map/result_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  bool isTracking = false;

  List<LatLng> userPolylineCoordinates = [];
  double totalDistance = 0;

  final Stopwatch stopwatch = Stopwatch();
  Duration elapsedTime = Duration.zero;
  String? elapsedTimeString;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (stopwatch.isRunning) {
          updateElapsedTime();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void toggleStopwatch() {
    if (!stopwatch.isRunning) {
      stopwatch.start();
      updateElapsedTime();
    } else {
      stopwatch.stop();
    }
  }

  void stopStopwatch() {
    stopwatch.stop();
  }

  void resetStopwatch() {
    stopwatch.reset();
    updateElapsedTime();
  }

  void updateElapsedTime() {
    setState(() {
      elapsedTime = stopwatch.elapsed;
      elapsedTimeString = formatElapsedTime(elapsedTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: MapScreen(
          isTracking: isTracking,
          userPolyLineCoordinates: userPolylineCoordinates,
          totalDistance: totalDistance,
          onChangeUserPolyLineCoordinates: (LatLng latlng) =>
              userPolylineCoordinates.add(latlng),
          calculateTotalDistance: (List<LatLng> cList) {
            setState(() {
              for (var i = 0; i < cList.length - 1; i++) {
                totalDistance += Geolocator.distanceBetween(
                    cList[i].latitude,
                    cList[i].longitude,
                    cList[i + 1].latitude,
                    cList[i + 1].longitude);
              }
            });
          },
        )),
        const SizedBox(
          height: 14,
        ),
        Column(
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
                        elapsedTimeString ?? "--:--",
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
              height: 14,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.orange[300]!)),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          stopStopwatch();
                          resetStopwatch();
                          isTracking = false;
                          userPolylineCoordinates = [];
                          totalDistance = 0;
                        });
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Center(
                          child: Text(
                        "Reset",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[300]),
                      )),
                    )),
                const SizedBox(
                  width: 20,
                ),
                Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.circular(30)),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          toggleStopwatch();
                          isTracking = !isTracking;
                        });
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Center(
                          child: Text(
                        isTracking ? "Pause" : "Start",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      )),
                    )),
                const SizedBox(
                  width: 20,
                ),
                Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: InkWell(
                      onTap: () {
                        stopStopwatch();
                        isTracking = false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResultPage(
                                  userPolylineCoordinates:
                                      userPolylineCoordinates,
                                  totalDistance: totalDistance,
                                  elapsedTime: elapsedTime,
                                  elapsedTimeString:
                                      elapsedTimeString ?? "--:--")),
                        );
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: const Center(
                          child: Text(
                        "Finish",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      )),
                    )),
              ],
            )
          ],
        )
      ],
    );
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
