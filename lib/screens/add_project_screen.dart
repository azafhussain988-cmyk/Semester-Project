import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/project_model.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _technologiesController = TextEditingController();

  String? _selectedSupervisorId;
  String? _selectedSupervisorName;
  List<Map<String, dynamic>> _supervisors = [];
  bool _isLoadingSupervisors = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSupervisors();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }

  // Fetch all supervisors from Firebase automatically
  Future<void> _fetchSupervisors() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'supervisor')
          .get();

      setState(() {
        _supervisors = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id, // This is the UID - automatically used!
            'name': doc.data()['name'],
            'email': doc.data()['email'],
          };
        }).toList();
        _isLoadingSupervisors = false;
      });
    } catch (e) {
      debugPrint('Error fetching supervisors: $e');
      setState(() => _isLoadingSupervisors = false);
    }
  }

  Future<void> _handleAddProject() async {
    if (_formKey.currentState!.validate() && _selectedSupervisorId != null) {
      setState(() => _isLoading = true);

      final firestoreService = FirestoreService();
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.currentUser.first;

      final project = ProjectModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        technologies: _technologiesController.text,
        supervisorId: _selectedSupervisorId!, // Auto-assigned from dropdown
        supervisorName: _selectedSupervisorName!, // Auto-assigned from dropdown
        studentId: user!.uid,
        studentName: user.name,
        progressStatus: 'pending', // Initial status: pending
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestoreService.addProject(project);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project submitted for supervisor approval!'),
          ),
        );
        Navigator.pop(context);
      }
    } else if (_selectedSupervisorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supervisor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Project'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Project Title',
                icon: Icons.title,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter project title' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter project description' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _technologiesController,
                label: 'Technologies (comma separated)',
                icon: Icons.code,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter technologies used' : null,
              ),
              const SizedBox(height: 16),

              // Supervisor Dropdown - Auto-fetches from Firebase
              _isLoadingSupervisors
                  ? const Center(child: CircularProgressIndicator())
                  : _supervisors.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          Text('No supervisors available!'),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Supervisor',
                        prefixIcon: const Icon(Icons.supervisor_account),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      initialValue: _selectedSupervisorId,
                      items: _supervisors.map((supervisor) {
                        return DropdownMenuItem<String>(
                          value: supervisor['id'] as String,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supervisor['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                supervisor['email'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupervisorId = value;
                          final selected = _supervisors.firstWhere(
                            (s) => s['id'] == value,
                          );
                          _selectedSupervisorName = selected['name'] as String;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a supervisor' : null,
                    ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Submit Project',
                onPressed: _handleAddProject,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
