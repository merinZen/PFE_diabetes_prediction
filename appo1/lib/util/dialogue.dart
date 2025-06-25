import 'package:appo1/util/primary_button.dart'; // myButton
import 'package:appo1/util/secondary_button.dart'; // bottn
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class dialb extends StatelessWidget {
  final TextEditingController thename;
  final TextEditingController theage;
  final TextEditingController theheight;
  final TextEditingController theweight;

  final int? thegender;
  final int? thestress;
  final int? thehistory;
  final int? thehr;

  final VoidCallback onCancel;
  final void Function(int gender, int stress, int history, double bmi) onSave;
  final VoidCallback? onCheckRisk;

  final ValueNotifier<int> selectedGender;
  final ValueNotifier<int> selectedStress;
  final ValueNotifier<int> selectedHistory;

  dialb({
    super.key,
    required this.thename,
    required this.theage,
    required this.theheight,
    required this.theweight,
    required this.onSave,
    required this.onCancel,
    this.thegender,
    this.thestress,
    this.thehistory,
    this.thehr,
    this.onCheckRisk,
  })  : selectedGender = ValueNotifier<int>(thegender ?? 1),
        selectedStress = ValueNotifier<int>(thestress ?? 2),
        selectedHistory = ValueNotifier<int>(thehistory ?? 2);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: const Color.fromARGB(239, 188, 216, 239),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "USER DETAILS",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(160, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (thehr != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "HEART RATE: $thehr",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(160, 0, 0, 0),
                  ),
                ),
              ),
            const SizedBox(height: 30),

            _buildTextField(thename, "NAME", "Enter your name.."),
            const SizedBox(height: 10),
            _buildGenderSelector(),
            const SizedBox(height: 10),
            _buildNumberField(theage, "AGE", "Enter your age.."),
            const SizedBox(height: 10),
            _buildNumberField(theheight, "HEIGHT", "Enter your height (in cm).."),
            const SizedBox(height: 10),
            _buildNumberField(theweight, "WEIGHT", "Enter your weight (in kg).."),
            const SizedBox(height: 10),
            _buildStressSelector(),
            const SizedBox(height: 10),
            _buildHistorySelector(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                bottn(text: "cancel", onPressed: onCancel),
                const SizedBox(width: 8),
                bottn(
                  text: "save",
                  onPressed: () {
                    _handleSaveOnly();
                  },
                ),
                const SizedBox(width: 8),
             
              ],
            ),
               Container(
                //position
                alignment: Alignment.bottomRight,
                 child: bottn(
                    text: "check risk",
                    onPressed: () {
                      _handleSaveOnly();
                      if (onCheckRisk != null) onCheckRisk!();
                      
                      
                    },
                  ),
               ),
          ],
        ),
      ),
    );
  }

  void _handleSaveOnly() {
    double? h = double.tryParse(theheight.text);
    double? w = double.tryParse(theweight.text);
    double bmi = 0;
    if (h != null && w != null && h > 0) {
      bmi = w / ((h / 100) * (h / 100));
    }
    onSave(
      selectedGender.value,
      selectedStress.value,
      selectedHistory.value,
      bmi,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 78, 122, 166),
            width: 2,
          ),
        ),
        labelText: label,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 78, 122, 166),
          fontWeight: FontWeight.bold,
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromARGB(77, 21, 21, 21)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 78, 122, 166),
            width: 2,
          ),
        ),
        labelText: label,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 78, 122, 166),
          fontWeight: FontWeight.bold,
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromARGB(77, 21, 21, 21)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedGender,
      builder: (context, value, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            myButton(
              text: "female",
              isSelected: value == 1,
              onPressed: () => selectedGender.value = 1,
            ),
            const SizedBox(width: 20),
            myButton(
              text: "male",
              isSelected: value == 2,
              onPressed: () => selectedGender.value = 2,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStressSelector() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedStress,
      builder: (context, value, _) {
        return Column(
          children: [
            const Text("STRESS LEVEL"),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: myButton(
                    text: "Low",
                    isSelected: value == 1,
                    onPressed: () => selectedStress.value = 1,
                  ),
                ),
                Flexible(
                  child: myButton(
                    text: "Moderate",
                    isSelected: value == 2,
                    onPressed: () => selectedStress.value = 2,
                  ),
                ),
                Flexible(
                  child: myButton(
                    text: "High",
                    isSelected: value == 3,
                    onPressed: () => selectedStress.value = 3,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistorySelector() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedHistory,
      builder: (context, value, _) {
        return Column(
          children: [
            const Text("FAMILY HISTORY WITH DISEASES"),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myButton(
                  text: "Yes",
                  isSelected: value == 1,
                  onPressed: () => selectedHistory.value = 1,
                ),
                const SizedBox(width: 20),
                myButton(
                  text: "No",
                  isSelected: value == 2,
                  onPressed: () => selectedHistory.value = 2,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
