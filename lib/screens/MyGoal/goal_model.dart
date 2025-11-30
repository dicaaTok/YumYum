class GoalModel {
  final String goalType;      // Например: "Похудеть", "Набрать вес", "Больше белка"
  final int? targetCalories;  // Целевые калории в день (опционально)
  final DateTime startDate;

  GoalModel({
    required this.goalType,
    required this.startDate,
    this.targetCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      "goalType": goalType,
      "targetCalories": targetCalories,
      "startDate": startDate.toIso8601String(),
    };
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      goalType: json["goalType"],
      targetCalories: json["targetCalories"],
      startDate: DateTime.parse(json["startDate"]),
    );
  }
}
