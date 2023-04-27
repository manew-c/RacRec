import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //ใช้แปะtimestamp
import 'package:flutter_application_1/Pages/allvariable.dart';
import 'package:flutter_application_1/Pages/inputpointdatapage.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'dart:async';

class Maps2Page extends StatefulWidget {
  const Maps2Page({super.key});
  @override
  State<Maps2Page> createState() => _Maps2PageState();
}

class _Maps2PageState extends State<Maps2Page> {
  late Position userlocation;
  late GoogleMapController mapController;

  DocumentReference<Map<String, dynamic>> detectordatabase = FirebaseFirestore
      .instance
      .collection('หัววัดall')
      .doc(start.selecteddetector);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDetectorName() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await detectordatabase.get();
    return snapshot;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    userlocation = await Geolocator.getCurrentPosition();
    //เอาใส่นี้
    return userlocation;
  }

  Future<Position> _updatelocation() async {
    userlocation = await Geolocator.getCurrentPosition();
    return userlocation;
  }

  distance(double? lat1, double? lat2, double? lon1, double? lon2) {
    if (lat1 == null || lon1 == null) {
      return 'ยังไม่ได้บันทึกจุด';
    } else if (lat1 != null && lat2 != null && lon2 != null && lon1 != null) {
      lon1 = radians(lon1);
      lon2 = radians(lon2);
      lat1 = radians(lat1);
      lat2 = radians(lat2);
      double dlon = lon2 - lon1;
      double dlat = lat2 - lat1;
      double a =
          pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
      double c = 2 * asin(sqrt(a));
      double r = 6371; //Radius of earth in kilometers. Use 3956 for miles
      return (c * r * 100).toStringAsFixed(3); // Stream.value(c * r * 100);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position wantposition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = wantposition;
      });
      _listenForLocationUpdates();
    } catch (e) {
      print(e);
    }
  }

  late Position _position;
  late StreamSubscription<Position> _positionStreamSubscription;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _positionStreamSubscription.cancel();
  }

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0, //100คือทีละ10เมตร
  );
  void _listenForLocationUpdates() {
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((wantposition) {
      setState(() {
        _position = wantposition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Column(
            children: <Widget>[
              Text('ไซต์งาน ${start.selectedworksite} '),
              Text(
                  'ผู้ใช้ ${start.selectedusername} หัววัด ${start.selecteddetector}'),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: _getLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return GoogleMap(
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(userlocation.latitude, userlocation.longitude),
                zoom: 15,
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  CircularProgressIndicator(),
                  Text('กำลังโหลด'),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              _updatelocation();
              mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(userlocation.latitude, userlocation.longitude), 18));
              //อันนี้ปุ่มบันทึกโดส เก็บค่าgpsใหม่ส่งหน้าถัดไป
              userloca.lat = userlocation.latitude;
              userloca.long = userlocation.longitude;
              debugPrint(userloca.lat.toString());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const inputpointpage(), //เปลี่ยนหน้autoตรงนนี้จ้า
                  ));
            },
            label: const Text("บันทึกค่าdose"),
            //icon: const Icon(Icons.near_me),
          ),
          //const SizedBox(width: 5),
          //อันนี้อันใหม่จ้า
          /*Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes wantposition of shadow
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Latitude: ${_position.latitude}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Longitude: ${_position.longitude}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),*/
          FutureBuilder(
              future: _updatelocation(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: 100,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: const Offset(
                              0, 3), // changes wantposition of shadow
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ระยะห่างจากจุดก่อนหน้าที่บันทึก เมตร',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        //อันนี้คือออโต้'Latitude: ${_position.latitude}', 'Longitude: ${_position.longitude}',
                        //อันนี้กดบันทึก userloca.lat userloca.long,
                        /*Text(
                          'userloca.lat ${userloca.lat}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' userloca.long ${userloca.long}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '_position.latitude${_position.latitude}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '_position.longitude ${_position.longitude}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),*/

                        Text(
                          '${distance(latlongsave().latsave, _position.latitude, latlongsave().longsave, _position.longitude)} ',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              })
          /*FutureBuilder(
              future: _updatelocation(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  userlocation = snapshot.data!;
                  return StreamBuilder<double>(
                    stream: distance(
                      userloca.lat.toDouble(),
                      userlocation.latitude,
                      userloca.long.toDouble(),
                      userlocation.longitude,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final distanceInKm = snapshot.toString();
                        return Container(
                          width: 100,
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Text(
                            'Distance: ${userlocation.longitude} km', //${distanceInKm.toStringAsFixed(3)}
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              }),*/
        ],
      ),
    );
  }
}
