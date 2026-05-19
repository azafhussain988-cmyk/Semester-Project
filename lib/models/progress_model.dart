import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  String id;
  String projectId;
  String weekNumber;
  String tasksCompleted;
  String nextWeekPlan;
  String status;
  DateTime date;

  ProgressModel({
    required this.id,
    required this.projectId,
    required this.weekNumber,
    required this.tasksCompleted,
    required this.nextWeekPlan,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'weekNumber': weekNumber,
    'tasksCompleted': tasksCompleted,
    'nextWeekPlan': nextWeekPlan,
    'status': status,
    'date': date,
  };

  factory ProgressModel.fromJson(Map<String, dynamic> json) => ProgressModel(
    id: json['id'],
    projectId: json['projectId'],
    weekNumber: json['weekNumber'],
    tasksCompleted: json['tasksCompleted'],
    nextWeekPlan: json['nextWeekPlan'],
    status: json['status'],
    date: (json['date'] as Timestamp).toDate(),
  );
}
