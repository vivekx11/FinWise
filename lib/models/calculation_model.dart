// dart 


import 'dart:convert';

class CalculationModel {
  final String id;
  final String type;
  final String title;
  final String result;
  final Map<String, String> details;
  final DateTime timestamp;
  final int iconCode;
  final int colorValue;

  CalculationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.result,
    required this.details,
    required this.timestamp,
    required this.iconCode,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'result': result,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'iconCode': iconCode,
      'colorValue': colorValue,
    };
  }

  factory CalculationModel.fromJson(Map<String, dynamic> json) {
    return CalculationModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      result: json['result'],
      details: Map<String, String>.from(json['details']),
      timestamp: DateTime.parse(json['timestamp']),
      iconCode: json['iconCode'],
      colorValue: json['colorValue'],
    );
  }

  static String encode(List<CalculationModel> calculations) {
    return jsonEncode(calculations.map((c) => c.toJson()).toList());
  }

  static List<CalculationModel> decode(String jsonString) {
    if (jsonString.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => CalculationModel.fromJson(item)).toList();
  }
}
