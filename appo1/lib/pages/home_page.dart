// ignore_for_file: unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appo1/util/dialogue.dart';
import 'package:appo1/util/tile.dart';
import 'package:appo1/data/databasebox.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:appo1/api/predict_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FeatureBox db;
  bool isLoading = true;

  final name = TextEditingController();
  final age = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();

  int? currentHR;

  @override
  void initState() {
    super.initState();
    _initFeatureBox();
  }

  Future<void> _initFeatureBox() async {
    db = FeatureBox();
    await db.init();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void deletepr(int index) async {
    db.features.removeAt(index);
    await db.updateData();
    setState(() {});
  }

  void _clearInputs() {
    name.clear();
    age.clear();
    height.clear();
    weight.clear();
  }

  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        backgroundColor: const Color.fromARGB(164, 234, 236, 237),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }
    Future<int?> fetchHeartRate() async {
      try {
        final firestore = FirebaseFirestore.instance;

        final docSnapshot = await firestore
            .collection('sensorDate')
            .doc('latest')
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          final hr = data?['hr'];
          return hr;
        } else {
          print("⚠️ No HR data yet.");
        }
      } catch (e) {
        print('❌ Error fetching HR: $e');
      }
      return null;
    }
      

  void savepr(int gender, int stress, int history, double bmi) async {
    if ([name.text, age.text, height.text, weight.text].any((e) => e.isEmpty)) {
      _showAlert('Warning', 'Please fill all fields before saving.');
      return;
    }

    db.features.add([
      name.text,
      int.parse(age.text),
      int.parse(height.text),
      int.parse(weight.text),
      gender,
      stress,
      history,
      currentHR ?? 0,
      bmi,
    ]);

    await db.updateData();
    _clearInputs();
    setState(() {});
    Navigator.pop(context);
  }

  void create({int hr = 0}) {
    showDialog(
      context: context,
      builder: (_) => dialb(
        theage: age,
        thename: name,
        theheight: height,
        theweight: weight,
        thegender: 1,
        thestress: 2,
        thehistory: 2,
        thehr: hr,
        onSave: savepr,
        onCancel: () {
          Navigator.pop(context);
          _clearInputs();
        },
      ),
    );
  }

   Future<void> createFirst() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Get your Measurements'),
      content: const Text('Require your heart rate from the sensors?'),
      backgroundColor: const Color.fromARGB(164, 234, 236, 237),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Get')),
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
      ],
    ),
  );

  if (confirmed == true) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Color.fromARGB(164, 234, 236, 237),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Measuring heart rate..."),
          ],
        ),
      ),
    );

    // Give time for the dialog to appear before waiting
    await Future.delayed(const Duration(milliseconds: 300));

    final hr = await fetchHeartRate();
    currentHR = hr ?? 0;

    // Hide loading
    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    // Reset state to false once we're done checking
    await FirebaseFirestore.instance
        .collection('sensorCommands')
        .doc('startMeasurement')
        .set({'state': false});
    print("✅ Reset startMeasurement state to false in Firestore");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sensor Data'),
        content: Text('Heart Rate: ${hr ?? "N/A"}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              create(hr: hr ?? 0);
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  } else {
    create();
  }
}

  // AI connection
  void runAICheck(int index) async {
    final feature = db.features[index];

    final inputData = {
      "Gender": feature[4],
      "Age": feature[1],
      "Height": feature[2],
      "Weight": feature[3],
      "Stress_Level": feature[5],
      "Family_History": feature[6],
      "Heart_Rate": feature[7],
      "BMI": feature[8],
    };

    final prediction = await PredictService().predictRisk(inputData);

    _showAlert(
      "Prediction Result",
      prediction == 1 ? "⚠️ High Diabetes Risk" : "✅ Low Diabetes Risk",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 234, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 76, 109),
        elevation: 0,
        title: const Text(
          "DIABETES RISK CHECK",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 121, 138, 166),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color.fromARGB(255, 121, 138, 166)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color.fromARGB(164, 234, 236, 237),
                  title: const Text("About This App"),
                  
                  








                  content: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(
                          text:
                              "This app helps track user health data including heart rate and BMI to assess potential diabetes risk. "
                              "Sensor values are retrieved in real-time and stored locally. AI-based risk prediction is integrated.\n\n",
                        ),
                        TextSpan(
                          text: "GitHub source  code:\nhttps://github.com/merinZen/PFE_diabetes_prediction",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final url = Uri.parse("https://github.com/merinZen/PFE_diabetes_prediction");
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                        ),
                      ],
                    ),
                  ),



                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createFirst,
        backgroundColor: const Color.fromARGB(255, 42, 76, 109),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: db.features.length,
        itemBuilder: (context, index) {
          final feature = db.features[index];
          return Tile(
            name: feature[0],
            deleteFunction: (_) => deletepr(index),
            onTap: () {
              name.text = feature[0];
              age.text = feature[1].toString();
              height.text = feature[2].toString();
              weight.text = feature[3].toString();

              int gender = feature.length > 4 ? feature[4] : 1;
              int stress = feature.length > 5 ? feature[5] : 2;
              int history = feature.length > 6 ? feature[6] : 2;
              int hr = feature.length > 7 ? feature[7] : 0;
              double bmi = feature.length > 8 ? feature[8] : 0;

              showDialog(
                context: context,
                builder: (_) => dialb(
                  theage: age,
                  thename: name,
                  theheight: height,
                  theweight: weight,
                  thegender: gender,
                  thestress: stress,
                  thehistory: history,
                  thehr: hr,
                  onSave: (g, s, h, b) async {
                    if ([name.text, age.text, height.text, weight.text].any((e) => e.isEmpty)) {
                      _showAlert('Warning', 'Please fill all fields before saving.');
                      return;
                    }

                    setState(() {
                      feature[0] = name.text;
                      feature[1] = int.parse(age.text);
                      feature[2] = int.parse(height.text);
                      feature[3] = int.parse(weight.text);
                      feature.length > 4 ? feature[4] = g : feature.add(g);
                      feature.length > 5 ? feature[5] = s : feature.add(s);
                      feature.length > 6 ? feature[6] = h : feature.add(h);
                      feature.length > 7 ? feature[7] = hr : feature.add(hr);
                      feature.length > 8 ? feature[8] = b : feature.add(b);
                    });

                    await db.updateData();
                    Navigator.pop(context);
                    _clearInputs();
                  },
                  onCancel: () {
                    Navigator.pop(context);
                    _clearInputs();
                  },
                ),
              );
            },
            onCheck: () => runAICheck(index),
          );
        },
      ),
    );
  }
}
