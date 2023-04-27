import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_application_1/Pages/saveuser.dart';
import 'package:flutter_application_1/Pages/saveworksite.dart';
import 'package:flutter_application_1/Pages/newuserpage.dart';
import 'package:flutter_application_1/Pages/savedetector.dart';
import 'Provider/Transaction_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  return runApp(const MainPage());
}

//สร้าง widget
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (Buildcontext) {
            return Transaction_provider();
          })
        ],
        child: MaterialApp(
          title: "Radiation Recording",
          home: const MyHomePage(),
          theme: ThemeData(primarySwatch: Colors.amber),
          debugShowCheckedModeBanner: false,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*Future<void> _saveAsFile(
    BuildContext context,
    PdfPageFormat pageFormat,
  ) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File('$appDocPath/instruction.pdf');
    if (!await file.exists()) {
      final bytes = await file.readAsBytes();
      await file.writeAsBytes(bytes, flush: true);

      debugPrint('Save as file ${file.path} ...');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color.fromARGB(255, 248, 184, 45)])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Radiation Recording"),
            //actions: const [Icon(Icons.album_outlined)],
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntrinsicWidth(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('         ยินดีต้อนรับ',
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 30),
                      SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const saveworksitePage(), //เปลี่ยนหน้าloadตรงนนี้จ้า
                                    ));
                              },
                              child: const Text(
                                'บันทึกข้อมูลไซต์งาน',
                                style: TextStyle(fontSize: 18),
                              ))), //อันนี้คือให้มันเว้นช่อง
                      const SizedBox(height: 30),
                      SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const saveuserPage(), //เปลี่ยนหน้userตรงนนี้จ้า
                                    ));
                              },
                              child: const Text(
                                'บันทึกชื่อผู้ใช้งาน',
                                style: TextStyle(fontSize: 18),
                              ))), //อันนี้คือให้มันเว้นช่อง
                      const SizedBox(height: 30),
                      SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const savedetectorPage(), //เปลี่ยนหน้าdetectorตรงนี้จ้า
                                    ));
                              },
                              child: const Text(
                                'บันทึกข้อมูลหัววัดรังสี',
                                style: TextStyle(fontSize: 18),
                              ))), //อันนี้คือให้มันเว้นช่อง
                      const SizedBox(height: 30),
                      SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const newuserpage(), //เปลี่ยนหน้autoตรงนนี้จ้า
                                    ));
                              },
                              child: const Text(
                                'เริ่มต้นวัดรังสี',
                                style: TextStyle(fontSize: 18),
                              ))), //อันนี้คือให้มันเว้นช่อง
                      const SizedBox(height: 30),
                      SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () async {
                                const url =
                                    'https://nuclear-app-cf4ef.web.app/';
                                final uri = Uri.encodeFull(url);
                                if (await canLaunchUrlString(uri)) {
                                  await launchUrlString(uri);
                                } else {
                                  throw 'Could not launch $uri';
                                }
                              },
                              child: const Text(
                                'ไปหน้าเว็บไซต์',
                                style: TextStyle(fontSize: 18),
                              ))),
                      const SizedBox(height: 30), //อันนี้คือให้มันเว้นช่อง
                      /*SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () async {
                              if (Platform.isAndroid) {
                                var status = await Permission.storage.status;
                                if (status != PermissionStatus.granted) {
                                  status = await Permission.storage.request();
                                }
                                /*if (status.isGranted) {
                                  //_saveAsFile;
                                  final appDocDir =
                                      await getApplicationDocumentsDirectory();
                                  final appDocPath = appDocDir.path;
                                  final file =
                                      File('$appDocPath/instruction.pdf');
                                  /*XFile pdfxfile =
                                  '$appDocPath/instruction.pdf' as XFile;*/
                                 
                                  Share.shareFiles(
                                      ['${appDocDir.path}/instruction.pdf']);
                                  //Share.shareXFiles([pdfxfile]);
                                }*/
                              }
                            },
                            child: const Text("คู่มือการใช้งาน",
                                style: TextStyle(fontSize: 18))),
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
