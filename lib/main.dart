import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocationTestApp(),
    );
  }
}

class LocationTestApp extends StatefulWidget {
  const LocationTestApp({Key? key}) : super(key: key);

  @override
  State<LocationTestApp> createState() => _LocationTestAppState();
}

class _LocationTestAppState extends State<LocationTestApp> {
  String location = '';
  double standardLat = 37.491462;
  double standardLon = 127.010938;
  int standardDistance = 50;

  double? distance;
  bool isLoading = false;
  bool canWork = false;

  Future<void> _getLocation() async {
    setState(() {
      isLoading = true;
    });
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        location = 'Service is Not enabled';
      });

      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
          location = 'Permission is denied';
        });

        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
        location = 'Permission is denied forever';
      });

      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      isLoading = false;
      location = '$position';
      distance = Geolocator.distanceBetween(standardLat, standardLon, position.latitude, position.longitude);
      canWork = standardDistance > distance!;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController standardDistanceController = TextEditingController(text: '$standardDistance');

    return MaterialApp(
      home: Scaffold(
        backgroundColor: canWork ? Colors.green.shade300 : Colors.white,
        appBar: AppBar(title: const Text('KSD Geolocation Test App')),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('기준좌표 : 한국공간데이터 본사'),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('기준거리 : '),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 40,
                          child: TextField(
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                standardDistance = int.tryParse(value) ?? 0;
                              }
                            },
                            keyboardType: TextInputType.number,
                            controller: standardDistanceController,
                          ),
                        ),
                        const Text('m'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                resultWidget(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _getLocation(),
          child: const Icon(Icons.location_on_outlined),
        ),
      ),
    );
  }

  Widget resultWidget() {
    if (isLoading) {
      return const CupertinoActivityIndicator();
    }

    return Column(
      children: [
        Text(location.replaceAll(', ', '\n')),
        const SizedBox(height: 12),
        Text('기준점으로부터 ${distance?.round() ?? 'Unknown'}m 이내에 있습니다.'),
      ],
    );
  }
}
