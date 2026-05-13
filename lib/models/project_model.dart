import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  String id;
  String title;
  String description;
  String technologies;
  String supervisorName;
  String supervisorId;
  String studentId;
  String studentName;
  String
  progressStatus; // 'not_started', 'in_progress', 'submitted', 'approved', 'rejected'
  DateTime createdAt;
  DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.supervisorName,
    required this.supervisorId,
    required this.studentId,
    required this.studentName,
    required this.progressStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'technologies': technologies,
    'supervisorName': supervisorName,
    'supervisorId': supervisorId,
    'studentId': studentId,
    'studentName': studentName,
    'progressStatus': progressStatus,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    technologies: json['technologies'],
    supervisorName: json['supervisorName'],
    supervisorId: json['supervisorId'],
    studentId: json['studentId'],
    studentName: json['studentName'],
    progressStatus: json['progressStatus'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    updatedAt: (json['updatedAt'] as Timestamp).toDate(),
  );
}
