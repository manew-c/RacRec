import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class saveuserPage extends StatefulWidget {
  const saveuserPage({super.key});

  @override
  State<saveuserPage> createState() => _saveuserPageState();
}

class _saveuserPageState extends State<saveuserPage> {
  final _formKey = GlobalKey<FormState>();
  final SERIES = TextEditingController();
  String? saveusername;
  final _setusername = <String>{};
  Future<void> fetchDatausername() async {
    await FirebaseFirestore.instance
        .collection("ชื่อคนall")
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        _setusername.add(result.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchDatausername();
    return Scaffold(
        appBar: AppBar(
          title: const Text('บันทึกข้อมูลผู้ใช้งาน'),
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
                          labelText: 'ชื่อผู้ใช้', icon: Icon(Icons.key)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your ชื่อผู้ใช้';
                        } else if (_setusername.contains(value) == true) {
                          return 'มีชื่อนี้แล้ว';
                        }
                        return null;
                      },
                      onSaved: (value) => saveusername = value!,
                      controller: SERIES,
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
                                      'บันทึกชื่อผู้ใช้  $saveusername  เรียบร้อย'),
                                  duration: const Duration(seconds: 5),
                                ));

                                FirebaseFirestore.instance
                                    .collection("ชื่อคนall")
                                    .doc(saveusername)
                                    .set({});
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
