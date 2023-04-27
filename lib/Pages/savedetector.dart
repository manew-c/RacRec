import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:toggle_switch/toggle_switch.dart';

class savedetectorPage extends StatefulWidget {
  const savedetectorPage({super.key});

  @override
  State<savedetectorPage> createState() => _savedetectorPageState();
}

class _savedetectorPageState extends State<savedetectorPage> {
  final _formKey = GlobalKey<FormState>();
  final SERIES = TextEditingController();
  String? savedetectorname;
  String? savedetectortype = 'Gas-filled';
  double? saveconvertionfactor;
  String? savenote;
  final _setdetector = <String>{};
  Future<void> fetchDatadetector() async {
    await FirebaseFirestore.instance
        .collection("หัววัดall")
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        _setdetector.add(result.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchDatadetector();
    return Scaffold(
        appBar: AppBar(
          title: const Text('บันทึกข้อมูลหัววัดรังสี'),
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: 'ชื่อหัววัด', icon: Icon(Icons.key)),
                      validator: (value1) {
                        if (value1!.isEmpty) {
                          return 'Please enter your หัววัด';
                        } else if (_setdetector.contains(value1) == true) {
                          debugPrint('มีหัววัดนี้แล้ว$value1');
                          return 'มีหัววัดนี้แล้ว';
                        }
                        return null;
                      },
                      onSaved: (value1) => savedetectorname = value1!,
                      //controller: SERIES,
                    ),
                    const SizedBox(height: 20),
                    //ประเภทหัววัด
                    const SizedBox(
                      child: Text(
                        'เลือกชนิดหัววัด',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ToggleSwitch(
                      //customWidths: const [120.0, 120.0, 120.0],
                      minWidth: 150.0,
                      initialLabelIndex: 0,
                      isVertical: true,
                      totalSwitches: 3,
                      labels: const [
                        'Gas-filled',
                        'Scintillation',
                        'Semiconductor'
                      ],
                      onToggle: (index) {
                        if (index == 0) {
                          savedetectortype = 'Gas-filled';
                        } else if (index == 1) {
                          savedetectortype = 'Scintillation';
                        } else if (index == 2) {
                          savedetectortype = 'Semiconductor';
                        }
                        debugPrint('detector to: $savedetectortype');
                      },
                    ),
                    const SizedBox(height: 10),
                    /*TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: 'ประเภทหัววัด', icon: Icon(Icons.key)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your ประเภทหัววัด';
                        }
                        return null;
                      },
                      onSaved: (value) => savedetectortype = value!,
                      //controller: SERIES,
                    ),*/

                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: 'ค่าconversion factor',
                          icon: Icon(Icons.key)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'หากไม่มีโปรดใส่ค่าเท่ากับ 1';
                        } else if (isFloat(value) == false) {
                          return 'ค่าที่กรอกไม่ใช่ตัวเลข';
                        }
                        return null;
                      },
                      onSaved: (value) =>
                          saveconvertionfactor = double.parse(value!),
                      //controller: SERIES,
                    ),
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          labelText: 'รายละเอียดอื่นๆ',
                          icon: Icon(Icons.key),
                          hintText: 'เช่น รหัสเครื่อง ชื่อรุ่น เป็นต้น'),
                      validator: (value3) {
                        if (value3!.isEmpty) {
                          return 'หากไม่มีโปรดใส่เครื่องหมาย - ';
                        }
                        return null;
                      },
                      onSaved: (value3) => savenote = value3!,
                      //autofocus: true,
                      //controller: SERIES,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState?.save();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'บันทึกหัววัด  $savedetectorname  เรียบร้อย'),
                                  duration: const Duration(seconds: 5),
                                ));

                                FirebaseFirestore.instance
                                    .collection("หัววัดall")
                                    .doc(savedetectorname)
                                    .set({
                                  'type': savedetectortype,
                                  'conversionfactor': saveconvertionfactor,
                                  'note': savenote
                                });
                                _formKey.currentState!.reset();
                              }
                            }, //อย่าลืมเปลี่ยนpageกลับมาเหมือนเดิมนาจาาา
                            child: const Text('บันทึก'),
                          ),
                        ],
                      ),
                    )
                  ],
                ))));
  }
}
