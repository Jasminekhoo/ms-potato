import 'package:flutter/foundation.dart';

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
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      result = await _api.analyse(input);
    } catch (e) {
      error = 'Unable to analyse this property right now.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
