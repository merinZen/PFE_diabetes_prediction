import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictService {
  final String _baseUrl = 'http://127.0.0.1:5000/predict'; // Replace with your IP if using real device

  Future<int?> predictRisk(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['prediction']; // 0 or 1
      } else {
        print('API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling API: $e');
    }
    return null;
  }
}
