import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/progress_model.dart';
import '../models/project_model.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedProjectId;
  List<ProjectModel> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final authService = AuthService();
    final user = await authService.currentUser.first;
    if (user != null) {
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
    }
  }

  void _showAddProgressDialog() {
    final weekController = TextEditingController();
    final tasksController = TextEditingController();
    final nextWeekController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Weekly Progress'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: weekController,
                  decoration: const InputDecoration(
                    labelText: 'Week Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter week number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: tasksController,
                  decoration: const InputDecoration(
                    labelText: 'Tasks Completed',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter tasks completed' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nextWeekController,
                  decoration: const InputDecoration(
                    labelText: 'Next Week Plan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter next week plan' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext);
                final progress = ProgressModel(
                  id: const Uuid().v4(),
                  projectId: _selectedProjectId!,
                  weekNumber: weekController.text,
                  tasksCompleted: tasksController.text,
                  nextWeekPlan: nextWeekController.text,
                  status: 'pending',
                  date: DateTime.now(),
                );
                await _firestoreService.addProgress(progress);
                if (!mounted) return;
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress added successfully!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        backgroundColor: const Color(0xFF3E6478),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timeline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No projects found. Create a project first.',
                    style: TextStyle(fontSize: 16),
                  ),
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
                Expanded(
                  child: _selectedProjectId != null
                      ? StreamBuilder<List<ProgressModel>>(
                          stream: _firestoreService.getProjectProgress(
                            _selectedProjectId!,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final progresses = snapshot.data!;
                            if (progresses.isEmpty) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No progress reports yet. Add your first weekly report.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: progresses.length,
                              itemBuilder: (context, index) {
                                final progress = progresses[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Week ${progress.weekNumber}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    progress.status ==
                                                        'approved'
                                                    ? Colors.green.withValues(
                                                        alpha: 0.2,
                                                      )
                                                    : Colors.orange.withValues(
                                                        alpha: 0.2,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                progress.status.toUpperCase(),
                                                style: TextStyle(
                                                  color:
                                                      progress.status ==
                                                          'approved'
                                                      ? Colors.green
                                                      : Colors.orange,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Tasks Completed:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(progress.tasksCompleted),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Next Week Plan:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(progress.nextWeekPlan),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Submitted: ${_formatDate(progress.date)}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : const Center(
                          child: Text('Select a project to view progress'),
                        ),
                ),
              ],
            ),
      floatingActionButton: _projects.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddProgressDialog,
              backgroundColor: const Color(0xFF3E6478),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
