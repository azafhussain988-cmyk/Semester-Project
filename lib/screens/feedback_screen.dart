import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/feedback_model.dart';
import '../models/project_model.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedProjectId;
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  String? _userRole;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = AuthService();
    final user = await authService.currentUser.first;
    if (user != null) {
      setState(() => _userRole = user.role);
      if (user.role == 'student') {
        final projects = await _firestoreService
            .getStudentProjects(user.uid)
            .first;
        setState(() {
          _projects = projects;
          _isLoading = false;
          if (_projects.isNotEmpty) {
            _selectedProjectId = _projects[0].id;
          }
        });
      } else {
        final projects = await _firestoreService
            .getSupervisorProjects(user.uid)
            .first;
        setState(() {
          _projects = projects;
          _isLoading = false;
          if (_projects.isNotEmpty) {
            _selectedProjectId = _projects[0].id;
          }
        });
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter feedback')));
      return;
    }

    final authService = AuthService();
    final user = await authService.currentUser.first;

    final feedback = FeedbackModel(
      id: const Uuid().v4(),
      projectId: _selectedProjectId!,
      supervisorId: user!.uid,
      supervisorName: user.name,
      feedback: _feedbackController.text,
      submissionId: _selectedProjectId!,
      approved: false,
      timestamp: DateTime.now(),
    );

    await _firestoreService.addFeedback(feedback);
    if (!mounted) return;
    _feedbackController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: _userRole == 'supervisor' ? Colors.green : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feedback_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No projects found', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedProjectId,
                    decoration: InputDecoration(
                      labelText: 'Select Project',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _projects.map((project) {
                      return DropdownMenuItem(
                        value: project.id,
                        child: Text(project.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectId = value;
                      });
                    },
                  ),
                ),
                if (_userRole == 'supervisor') ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: 'Write your feedback here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Submit Feedback'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(child: FeedbackList(projectId: _selectedProjectId!)),
              ],
            ),
    );
  }
}

class FeedbackList extends StatelessWidget {
  final String projectId;

  const FeedbackList({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return FutureBuilder(
      future: AuthService().currentUser.first,
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userSnapshot.data!;

        return StreamBuilder<List<FeedbackModel>>(
          stream: firestoreService.getProjectFeedback(projectId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final feedbacks = snapshot.data ?? [];

            if (feedbacks.isEmpty) {
              return const Center(child: Text('No feedback available yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              user.role == 'student'
                                  ? Icons.supervisor_account
                                  : Icons.person,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              feedback.supervisorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(feedback.timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(feedback.feedback),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
