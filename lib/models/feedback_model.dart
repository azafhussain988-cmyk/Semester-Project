import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  String id;
  String projectId;
  String supervisorId;
  String supervisorName;
  String feedback;
  String submissionId;
  bool approved;
  DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.projectId,
    required this.supervisorId,
    required this.supervisorName,
    required this.feedback,
    required this.submissionId,
    required this.approved,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'supervisorId': supervisorId,
    'supervisorName': supervisorName,
    'feedback': feedback,
    'submissionId': submissionId,
    'approved': approved,
    'timestamp': timestamp,
  };

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
    id: json['id'],
    projectId: json['projectId'],
    supervisorId: json['supervisorId'],
    supervisorName: json['supervisorName'],
    feedback: json['feedback'],
    submissionId: json['submissionId'],
    approved: json['approved'],
    timestamp: (json['timestamp'] as Timestamp).toDate(),
  );
}