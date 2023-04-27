import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Pages/map2.dart';
import 'package:flutter_application_1/Pages/allvariable.dart';
import 'package:geolocator/geolocator.dart';

class newuserpage extends StatefulWidget {
  const newuserpage({Key? key}) : super(key: key);

  @override
  _newuserpageState createState() => _newuserpageState();
}

class _newuserpageState extends State<newuserpage> {
  String? _selectedusername;
  String? _selecteddetector;
  String? _selectedworksite;

  late var _dropdownusername = <String>{};
  late var _dropdowndetector = <String>{};
  late var _dropdownworksite = <String>{};
  final _textControllerusername = TextEditingController();
  final _textControllerdetector = TextEditingController();
  final _textControllerdetectinfo = TextEditingController();
  CollectionReference worksitedatabase =
      FirebaseFirestore.instance.collection('allworksite');
  CollectionReference detectordatabase =
      FirebaseFirestore.instance.collection('หัววัดall');

  @override
  void initState() {
    super.initState();
    fetchDatausername();
    fetchDatadetector();
    fetchDataworksite();
  }

  Future<void> fetchDatausername() async {
    await FirebaseFirestore.instance
        .collection("ชื่อคนall")
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        _dropdownusername.add(result.id);
      }
    });
  }

/*  .collection("ไซต์งาน").doc(Point.worksite).collection('ผู้วัดรังสี').doc(user.username).collection('หัววัด')
                              .doc(user.detector)
                              .collection('ชื่อจุด')
                              .doc(pointname) */
  Future<void> fetchDatadetector() async {
    await FirebaseFirestore.instance
        .collection("หัววัดall")
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        _dropdowndetector.add(result.id);
      }
    });
  }

  Future<void> fetchDataworksite() async {
    await FirebaseFirestore.instance
        .collection("allworksite")
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        _dropdownworksite.add(result.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('เลือกไซต์งาน ผู้วัด และหัววัด'),
        ),
        body: Container(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: (TextField(
                        decoration: const InputDecoration(
                          labelText: 'ไซต์งาน',
                          border: OutlineInputBorder(),
                        ),
                        controller: _textControllerdetectinfo,
                        onChanged: (value) async {
                          Set<String> filteredOptions = _dropdownworksite
                              .where((option) => option.startsWith(value))
                              .toSet();
                          setState(() {
                            _dropdownworksite = filteredOptions;
                          });
                        },
                      )),
                    ),
                    const SizedBox(width: 10),
                    FutureBuilder(
                      future: fetchDataworksite(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return DropdownButton(
                            value: _selectedworksite,
                            items: _dropdownworksite
                                .map((option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(option),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedworksite = newValue!;
                                _textControllerdetectinfo.text = newValue;
                              });
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: worksitedatabase.doc(_selectedworksite).snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text("Loading...");
                    } else if (!snapshot.hasData) {
                      return const Text("Document does not exist");
                    } else if (snapshot.hasData &&
                        snapshot.data!.data() != null) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            title: Text('จังหวัด' + ' ' + data['จังหวัด']),
                            subtitle: Text('หมายเหตุ' + ' ' + data['note']),
                          )
                        ],
                      );
                    } else {
                      return const Text("กรุณาเลือกไซต์งาน ");
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: (TextField(
                        decoration: const InputDecoration(
                          labelText: 'ชื่อผู้วัด',
                          border: OutlineInputBorder(),
                        ),
                        controller: _textControllerusername,
                        onChanged: (value) async {
                          Set<String> filteredOptions = _dropdownusername
                              .where((option) => option.startsWith(value))
                              .toSet();
                          setState(() {
                            _dropdownusername = filteredOptions;
                            //_selectedusername = value;//นี่คือส่วนที่เพิ่มมมาเองไม่งั้นมันnullแต่ก็errorพอลบทิ้งก็nullแต่ดันไปหน้าต่อไปได้wtf
                          });
                        },
                      )),
                    ),
                    const SizedBox(width: 10),
                    FutureBuilder(
                      future: fetchDatausername(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return DropdownButton(
                            value: _selectedusername,
                            items: _dropdownusername
                                .map((option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(option),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedusername = newValue!;
                                _textControllerusername.text = newValue;
                              });
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: (TextField(
                        decoration: const InputDecoration(
                          labelText: 'หัววัด',
                          border: OutlineInputBorder(),
                        ),
                        controller: _textControllerdetector,
                        onChanged: (value) async {
                          Set<String> filteredOptions = _dropdowndetector
                              .where((option) => option.startsWith(value))
                              .toSet();
                          setState(() {
                            _dropdowndetector = filteredOptions;
                          });
                        },
                      )),
                    ),
                    const SizedBox(width: 10),
                    FutureBuilder(
                      future: fetchDatadetector(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return DropdownButton(
                            value: _selecteddetector,
                            items: _dropdowndetector
                                .map((option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(option),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selecteddetector = newValue!;
                                _textControllerdetector.text = newValue;
                              });
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: detectordatabase.doc(_selecteddetector).snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text("Loading...");
                    } else if (!snapshot.hasData) {
                      return const Text("Document does not exist");
                    } else if (snapshot.hasData &&
                        snapshot.data!.data() != null) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 245, 207, 41),
                                width: 5)),
                        child: Column(
                          children: <Widget>[
                            Text('ค่าconversion factor' +
                                ' ' +
                                data['conversionfactor'].toString()),
                            Text('ประเภทหัววัด' + ' ' + data['type']),
                            Text('หมายเหตุ' + ' ' + data['note']),
                          ],
                        ),
                      );
                    } else {
                      return const Text("กรุณาเลือกหัววัด ");
                    }
                  },
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  child: Text(
                      'หากไม่มีข้อมูลในตัวเลือกสามารถไปบันทึกได้ที่หน้าบันทึกข้อมูล'),
                ),
                ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    if (_selectedusername?.isNotEmpty == true &&
                        _selecteddetector?.isNotEmpty == true &&
                        _selectedworksite?.isNotEmpty == true) {
                      FirebaseFirestore.instance
                          .collection("ไซต์งาน")
                          .doc(_selectedworksite)
                          .collection('ผู้วัดรังสี')
                          .doc(_selectedusername)
                          .collection('หัววัด')
                          .doc(_selecteddetector)
                          .set({});

                      start.selectedworksite = _selectedworksite!;
                      start.selectedusername = _selectedusername!;
                      start.selecteddetector = _selecteddetector!;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Maps2Page(),
                        ),
                      ); //navigator

                    } else {
                      // show an error message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'โปรดเลือกไซต์งาน ชื่อผู้วัดและหัววัดให้ครบทั้งสามอัน'),
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

//กุเหนื่อยแค่กล่องใส่ข้อความกล่องเดียว วิธีแก้คือเปลี่ยนจากlistเป็นset อหหหหหหหหหหหหหห เหน่ย
/*class _pointclasstest {
  String usernamet;
  String detectort;
  String detectinfot;
  _pointclasstest(
      {required this.usernamet,
      required this.detectort,
      required this.detectinfot});
}

_pointclasstest Pointtest =
    _pointclasstest(usernamet: '', detectort: '', detectinfot: '');*/
