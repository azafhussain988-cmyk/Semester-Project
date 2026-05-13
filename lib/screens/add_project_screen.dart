import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
  final _supervisorNameController = TextEditingController();
  final _supervisorIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAddProject() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final firestoreService = FirestoreService();
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.currentUser.first;
      
      final project = ProjectModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        technologies: _technologiesController.text,
        supervisorName: _supervisorNameController.text,
        supervisorId: _supervisorIdController.text,
        studentId: user!.uid,
        studentName: user.name,
        progressStatus: 'not_started',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await firestoreService.addProject(project);
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project added successfully!')),
        );
        Navigator.pop(context);
      }
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
                validator: (value) => value!.isEmpty ? 'Please enter project title' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Please enter project description' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _technologiesController,
                label: 'Technologies (comma separated)',
                icon: Icons.code,
                validator: (value) => value!.isEmpty ? 'Please enter technologies used' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _supervisorNameController,
                label: 'Supervisor Name',
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? 'Please enter supervisor name' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _supervisorIdController,
                label: 'Supervisor ID',
                icon: Icons.badge,
                validator: (value) => value!.isEmpty ? 'Please enter supervisor ID' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Add Project',
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