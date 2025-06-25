import 'package:hive_flutter/hive_flutter.dart';

class FeatureBox {
  List<List<dynamic>> features = [];
  late Box mbox;

  Future<void> init() async {
    mbox = Hive.box('mybox');
    if (mbox.get('FEATURES') == null) {
      await createDefaultData();
    } else {
      await loadData();
    }
  }

  Future<void> createDefaultData() async {
    features = [
      // [name, age, height, weight, gender, stress, history, hr, bmi]
      ['person 1', 25, 180, 70, 2, 1, 1, 72, _calculateBMI(180, 70)],
      ['person 2', 30, 175, 65, 2, 3, 2, 80, _calculateBMI(175, 65)],
      ['person 3', 35, 160, 80, 2, 2, 2, 77, _calculateBMI(160, 80)],
    ];
    await updateData();
  }

  Future<void> loadData() async {
    final raw = mbox.get('FEATURES');
    if (raw != null) {
      features = List<List<dynamic>>.from(
        raw.map<List<dynamic>>((e) => List<dynamic>.from(e)),
      );
    } else {
      features = [];
    }
  }

  Future<void> updateData() async {
    await mbox.put('FEATURES', features);
  }

  double _calculateBMI(int height, int weight) {
    if (height == 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  void addEntry({
    required String name,
    required int age,
    required int height,
    required int weight,
    required int gender,
    required int stress,
    required int history,
    required int hr,
  }) {
    double bmi = _calculateBMI(height, weight);
    features.add([name, age, height, weight, gender, stress, history, hr, bmi]);
    updateData();
  }

  void deleteEntry(int index) {
    features.removeAt(index);
    updateData();
  }
}
