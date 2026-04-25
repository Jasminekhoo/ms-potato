import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/analysis_result.dart';
import '../models/property_input.dart';
import '../services/api_service.dart';

class PropertyProvider extends ChangeNotifier {
  PropertyProvider({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  bool isLoading = false;
  AnalysisResult? result;
  String? error;

  Future<void> analyse(PropertyInput input) async {
    print("📡 analyse() STARTED");
    
    // 1. Update UI to "Loading" state
    isLoading = true;
    error = null;
    result = null; 
    notifyListeners(); 

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:3001/api/analyse"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "propertyName": input.propertyName,
          "location": input.location,
          "askingRent": input.askingRent,
          "monthlyIncome": input.monthlyIncome,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ API SUCCESS");
        
        // 2. Decode the body and update the 'result' variable
        final Map<String, dynamic> data = jsonDecode(response.body);
        result = AnalysisResult.fromJson(data);
        
      } else {
        error = "Server error: ${response.statusCode}";
        print("❌ SERVER ERROR: $error");
      }
    } catch (e) {
      error = e.toString();
      print("❌ API ERROR: $e");
    } finally {
      // 3. Stop loading and tell Flutter to rebuild the screen
      isLoading = false;
      notifyListeners(); 
    }
  }
}