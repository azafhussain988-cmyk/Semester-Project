import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../models/progress_model.dart';
import '../models/feedback_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CRUD Operations for Projects
  Future<void> addProject(ProjectModel project) async {
    await _firestore.collection('projects').doc(project.id).set(project.toJson());
  }

  Future<ProjectModel?> getProject(String id) async {
    DocumentSnapshot doc = await _firestore.collection('projects').doc(id).get();
    if (doc.exists) {
      return ProjectModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateProject(ProjectModel project) async {
    await _firestore.collection('projects').doc(project.id).update(project.toJson());
  }

  Future<void> deleteProject(String id) async {
    await _firestore.collection('projects').doc(id).delete();
  }

  // FIXED: No .orderBy() - uses client-side sorting
  Stream<List<ProjectModel>> getStudentProjects(String studentId) {
    return _firestore
        .collection('projects')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          List<ProjectModel> projects = snapshot.docs
              .map((doc) => ProjectModel.fromJson(doc.data()))
              .toList();
          
          // Sort on client side - works immediately!
          projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return projects;
        });
  }

  // FIXED: No .orderBy() - uses client-side sorting
  Stream<List<ProjectModel>> getSupervisorProjects(String supervisorId) {
    return _firestore
        .collection('projects')
        .where('supervisorId', isEqualTo: supervisorId)
        .snapshots()
        .map((snapshot) {
          List<ProjectModel> projects = snapshot.docs
              .map((doc) => ProjectModel.fromJson(doc.data()))
              .toList();
          
          // Sort on client side - works immediately!
          projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return projects;
        });
  }

  // Progress Tracking
  Future<void> addProgress(ProgressModel progress) async {
    await _firestore.collection('progress').doc(progress.id).set(progress.toJson());
  }

  Stream<List<ProgressModel>> getProjectProgress(String projectId) {
    return _firestore
        .collection('progress')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          List<ProgressModel> progresses = snapshot.docs
              .map((doc) => ProgressModel.fromJson(doc.data()))
              .toList();
          
          progresses.sort((a, b) => b.date.compareTo(a.date));
          return progresses;
        });
  }

  // Feedback
  Future<void> addFeedback(FeedbackModel feedback) async {
    await _firestore.collection('feedback').doc(feedback.id).set(feedback.toJson());
  }

  Stream<List<FeedbackModel>> getProjectFeedback(String projectId) {
    return _firestore
        .collection('feedback')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          List<FeedbackModel> feedbacks = snapshot.docs
              .map((doc) => FeedbackModel.fromJson(doc.data()))
              .toList();
          
          feedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return feedbacks;
        });
  }
}