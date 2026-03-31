import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_model.dart';

class HistoryService {
  static const String _historyKey = 'calculation_history';
  static HistoryService? _instance;
  
  HistoryService._();
  
  static HistoryService get instance {
    _instance ??= HistoryService._();
    return _instance!;
  }

  Future<void> saveCalculation(CalculationModel calculation) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Add new calculation at the beginning
    history.insert(0, calculation);
    
    // Keep only last 50 calculations to prevent storage bloat
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    await prefs.setString(_historyKey, CalculationModel.encode(history));
  }

  Future<List<CalculationModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey) ?? '';
    return CalculationModel.decode(jsonString);
  }

  Future<void> deleteCalculation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.removeWhere((calc) => calc.id == id);
    await prefs.setString(_historyKey, CalculationModel.encode(history));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
