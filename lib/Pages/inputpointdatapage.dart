import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //ใช้แปะtimestamp
import 'package:string_validator/string_validator.dart'; //เป็นเครื่องเช็ค
import 'package:url_launcher/url_launcher_string.dart'; //ใช้ลิ้งเว็บ
import 'package:flutter_application_1/Pages/allvariable.dart';
import 'package:toggle_switch/toggle_switch.dart'; //ปุ่มแบบtoggle
import 'package:image_picker/image_picker.dart'; //อัพรูปภาพ
import 'dart:io'; //ใช้ fileได้
import 'package:firebase_storage/firebase_storage.dart'; //อัพรรูป
import 'package:flutter_application_1/main.dart';
import 'dart:math' as math;

class inputpointpage extends StatefulWidget {
  const inputpointpage({super.key});

  @override
  State<inputpointpage> createState() => _inputpointPageState();
}

class _inputpointPageState extends State<inputpointpage> {
  final _formKey = GlobalKey<FormState>();
  late GoogleMapController mapController;
  String? _selectedunit5cm = 'µSv/h';
  String? _selectedunit1m = 'µSv/h';
  XFile? _pickedImage; // State variable to store the picked file
  String? _pickedImageName; // State variable to store the file name
  Future<File?>? _Image;
  Future<File?> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = XFile(pickedFile.path);
        _pickedImageName = pickedFile.path.split('/').last;
      });
      return File(_pickedImage!.path);
    }
  }

  final _setpointname = <String>{};
  Future<void> fetchDatapointname() async {
    try {
      await FirebaseFirestore.instance
          .collection('ไซต์งาน')
          .doc(start.selectedworksite)
          .collection('ผู้วัดรังสี')
          .doc(start.selectedusername)
          .collection('หัววัด')
          .doc(start.selecteddetector)
          .collection('ชื่อจุด')
          .get()
          .then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          _setpointname.add(result.id);
        }
      });
    } catch (e) {
      debugPrint('หาชื่อจุดไม่ได้');
    }
  }

  findLatestandMaxNumber(s) {
    List sx = s.toList();
    List<int> a = [];
    if (sx.isNotEmpty) {
      for (var i in sx) {
        if (i is int) {
          a.add(i);
        } else if (isFloat(i)) {
          a.add(int.parse(i));
        }
      }
      int maxNumber = (a.reduce(math.max));
      debugPrint(maxNumber.toString());
      return maxNumber;
    } else {
      debugPrint('ไม่เจอเซ็ต เซ็ตว่าง');
      return 0; //Stream.value(0);
    }
  }

  void updateoldpoint(x) {
    MyData().listoldpoint.add(x);
    if (MyData().listoldpoint.length > 3) {
      MyData().listoldpoint.removeAt(0);
    }
  }

  DocumentReference<Map<String, dynamic>> detectordatabase = FirebaseFirestore
      .instance
      .collection('หัววัดall')
      .doc(start.selecteddetector);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDetectorName() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await detectordatabase.get();
    return snapshot;
  }

  @override
  void initState() {
    super.initState();
    fetchDatapointname();
    debugPrint('เซ็ตชื่่อจุด1' +
        _setpointname.toString()); // call fetchDatapointname function here
  }

  @override
  Widget build(BuildContext context) {
    //fetchDatapointname();
    //debugPrint('เซ็ตชื่่อจุด1' + _setpointname.toString());
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
      //'Your location!\nlat: ${userlocation.latitude} long: ${userlocation.longitude} '),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Your location!\nlat: ${userloca.lat} long: ${userloca.long}  ',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  /*Text(
                    'long: ${userloca.long} ',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.left,
                  ),*/
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'กรอกชื่อจุด',
                      labelText: 'ชื่อจุด',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: COUTERS().counter.toString(),
                    validator: (value) {
                      if (value! == '') {
                        return 'Please enter ชื่อจุด';
                      }
                      if (_setpointname.contains(value) == true) {
                        fetchDatapointname();
                        debugPrint('fecthในvalidator');
                        String x =
                            findLatestandMaxNumber(_setpointname).toString();

                        return 'มีชื่อจุดนี้แล้ว จุดล่าสุดคือ' + x;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      MAP.pointname = (value!);
                    },
                  ),

                  const SizedBox(height: 10),
                  /*Text(
                    'หากกรอกชื่อจุดซ้ำจะเป็นการเขียนข้อมูลทับอันเก่า',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),*/

                  /*Text('ชื่อจุดที่กรอกเรียงจากเก่าไปใหม่' +
                      _setpointname.toString()),*/
                  /* ElevatedButton(
                    onPressed: () {
                      fetchDatapointname();
                    },
                    child: const Text('ดูค่าที่กรอก'),
                  ),*/
                  /*FutureBuilder(
                    future: findLatestandMaxNumber(_setpointname),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text('จุดล่าสุด' + snapshot.data.toString());
                      }
                    },
                  ),*/
                  /*StreamBuilder<int>(
                    stream: findLatestandMaxNumber(_setpointname),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text('จุดล่าสุด' + snapshot.data.toString());
                      }
                    },
                  ),*/

                  const SizedBox(height: 10),

                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'กรอกค่าDoseที่ 5 cm ',
                      labelText: 'Dose ที่ 5 cm',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      //อันนี้ไม่ใส่ค่าก็ได้
                      if (value == '') {
                        return null;
                      } else if (isFloat(value!) == false) {
                        return 'ค่าที่กรอกไม่ใช่ตัวเลข';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value!.isNotEmpty == true) {
                        MAP.dose5cm = double.parse(value);
                      } else {
                        MAP.dose5cm = 0;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  //ใส่dropอันที่1
                  ToggleSwitch(
                    initialLabelIndex: 0,
                    totalSwitches: 2,
                    labels: const ['µSv/h', 'nSv/h'],
                    onToggle: (index) {
                      if (index == 0) {
                        _selectedunit5cm = 'µSv/h';
                      } else {
                        _selectedunit5cm = 'nSv/h';
                      }
                      debugPrint('unit5cm to: $_selectedunit5cm');
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'กรอกค่าDoseที่ 1 m',
                      labelText: 'Dose ที่1m',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == '') {
                        return 'โปรดใส่ค่า Doseที่ 1 m';
                      } else if (isFloat(value!) == false) {
                        return 'ค่าที่กรอกไม่ใช่ตัวเลข';
                      }
                      return null;
                    },
                    onSaved: (value) => MAP.dose1m = double.parse(value!),
                  ),
                  const SizedBox(height: 10),
                  ToggleSwitch(
                    initialLabelIndex: 0,
                    totalSwitches: 2,
                    labels: const ['µSv/h', 'nSv/h'],
                    onToggle: (index) {
                      if (index == 0) {
                        _selectedunit1m = 'µSv/h';
                      } else {
                        _selectedunit1m = 'nSv/h';
                      }
                      debugPrint('unit1m to: $_selectedunit1m');
                    },
                  ),

                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'กรอกหมายเหตุ',
                      labelText: 'หมายเหตุ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value! == '') {
                        return null;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value!.isNotEmpty == true) {
                        MAP.note = value;
                      } else {
                        MAP.note = 'ไม่ได้กรอกหมายเหตุ';
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _Image = _getImage();
                          });
                        },
                        child: const Text('ถ่ายรูป'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _Image = null;
                          });
                        },
                        child: const Text('ลบรูป'),
                      ),
                    ],
                  ),

                  //paddingมันกินพท.ข้างใน เช่นกล่องสูง10 padding8 มันกินเหลือพท.2
                  //Expanded ลองละใช้ไม่ได้เลยยยย
                  FutureBuilder(
                    future: _Image,
                    builder:
                        (BuildContext context, AsyncSnapshot<File?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Image(
                          image: FileImage(snapshot.data!),
                          fit: BoxFit.contain,
                          height: 200,
                        );
                      } else {
                        return const Center(child: Text('ยังไม่ได้ถ่ายรูปภาพ'));
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      fetchDatapointname();
                      debugPrint('เซ็ตชื่่อจุด2' + _setpointname.toString());
                      //findLatestandMaxNumber(_setpointname);

                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final DocumentSnapshot<Map<String, dynamic>> snapshot =
                            await getDetectorName();
                        final Map<String, dynamic>? dato = snapshot.data();
                        final double conversion =
                            dato!['conversionfactor'].toDouble();
                        CollectionReference siteandprovind =
                            FirebaseFirestore.instance.collection('ไซต์งาน');
                        if (_pickedImage?.path != null) {
                          siteandprovind
                              .doc(start.selectedworksite)
                              .collection('ผู้วัดรังสี')
                              .doc(start.selectedusername)
                              .collection('หัววัด')
                              .doc(start.selecteddetector)
                              .collection('ชื่อจุด')
                              .doc(MAP.pointname)
                              .set({
                            'dose1m': MAP.dose1m,
                            'conversion_dose1m': MAP.dose1m * conversion,
                            'doseunit1m': _selectedunit1m,
                            'dose5cm': MAP.dose5cm * conversion,
                            'conversion_dose5cm': MAP.dose5cm * conversion,
                            'doseunit5cm': _selectedunit5cm,
                            'lat': userloca.lat,
                            'long': userloca.long,
                            'note': MAP.note,
                            'time': Timestamp.now(),
                            'picpath':
                                'gs://nuclear-app-cf4ef.appspot.com/image/$_pickedImageName',
                          }); //gs://nuclear-app-cf4ef.appspot.com/image/511193c3-7dd0-42ca-879f-85e354dbe4802863001179732899831.jpg

                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child('image/$_pickedImageName');

                          try {
                            final UploadTask uploadTask =
                                storageRef.putFile(File(_pickedImage!.path));
                            await uploadTask;
                            final String downloadUrl =
                                await storageRef.getDownloadURL();
                            debugPrint(
                                'Upload successful! Download URL: $downloadUrl');
                            debugPrint('ส่งรูปแล้ว');
                          } catch (e) {
                            debugPrint('ส่งรูปไม่ได้');
                          }
                        } //<-จบifอันเล็ก
                        //ข้างล่างไม่มีรูป
                        else if (_pickedImage?.path == null) {
                          siteandprovind
                              .doc(start.selectedworksite)
                              .collection('ผู้วัดรังสี')
                              .doc(start.selectedusername)
                              .collection('หัววัด')
                              .doc(start.selecteddetector)
                              .collection('ชื่อจุด')
                              .doc(MAP.pointname)
                              .set({
                            'dose1m': MAP.dose1m,
                            'conversion_dose1m': MAP.dose1m * conversion,
                            'doseunit1m': _selectedunit1m,
                            'dose5cm': MAP.dose5cm * conversion,
                            'conversion_dose5cm': MAP.dose5cm * conversion,
                            'doseunit5cm': _selectedunit5cm,
                            'lat': userloca.lat,
                            'long': userloca.long,
                            'note': MAP.note,
                            'time': Timestamp.now(),
                            'picpath': 'ไม่ได้ถ่ายรูป',
                          });
                        } //<-จบ if อันที่2 ข้างล่างคือifใหญ่
                        updateoldpoint(MAP.pointname); //แสดงชื่อจุดที่เคยกรอก
                        debugPrint(
                            'ชื่อจุด' + MyData().listoldpoint.toString());
                        latlongsave().latsave = userloca.lat;
                        latlongsave().longsave = userloca.long;

                        _formKey.currentState!.reset();

                        setState(() {
                          if (isFloat(MAP.pointname) == true) {
                            COUTERS().counter = int.parse(MAP.pointname);
                            COUTERS().incrementCounter();
                          }
                        }); //ชื่อจุดบวก1เรื่อยๆ

                        ScaffoldMessenger.of((context)).showSnackBar(SnackBar(
                          content: Text(
                              'บันทึกจุด${MAP.pointname}เรียบร้อย  Doseที่5cm ${MAP.dose5cm}  Doseที่1m ${MAP.dose1m}'),
                          duration: const Duration(seconds: 5),
                        ));
                      } //นี้คือจบifอันใหญ่สุด
                      debugPrint('ละติจูดที่บันทึก' + userloca.lat.toString());
                      debugPrint(
                          'ลองจิจูดที่บันทึก' + userloca.long.toString());
                      debugPrint(
                          'unit5cm ที่เลือกจะเปลี่ยนไหม $_selectedunit5cm');
                    }, //อันนี้ในonpress
                    child: const Center(child: Text("Submit")),
                  ),
                  const Text(
                    'หลังกดsubmitกรุณารอแจ้งเตือนบันทึกสำเร็จแล้วจึงกดกลับได้',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          const url = 'https://nuclear-app-cf4ef.web.app/';
                          final uri = Uri.encodeFull(url);
                          if (await canLaunchUrlString(uri)) {
                            await launchUrlString(uri);
                          } else {
                            throw 'Could not launch $uri';
                          }
                        },
                        child: const Text('กดดูcontour map'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          //pushReplacement .pushAndRemoveUntil popUntil

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage()),
                            ModalRoute.withName('/'),
                          );
                        },
                        child: const Text('ไปหน้าแรก'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
