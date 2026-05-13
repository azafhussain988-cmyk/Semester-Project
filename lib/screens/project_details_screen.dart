import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_button.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;
  final bool isSupervisor;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
    this.isSupervisor = false,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _technologiesController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(
      text: widget.project.description,
    );
    _technologiesController = TextEditingController(
      text: widget.project.technologies,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }

  Future<void> _updateProject() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updatedProject = ProjectModel(
        id: widget.project.id,
        title: _titleController.text,
        description: _descriptionController.text,
        technologies: _technologiesController.text,
        supervisorName: widget.project.supervisorName,
        supervisorId: widget.project.supervisorId,
        studentId: widget.project.studentId,
        studentName: widget.project.studentName,
        progressStatus: widget.project.progressStatus,
        createdAt: widget.project.createdAt,
        updatedAt: DateTime.now(),
      );

      final firestoreService = FirestoreService();
      await firestoreService.updateProject(updatedProject);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project updated successfully!')),
      );
    }
  }

  Future<void> _deleteProject() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              final firestoreService = FirestoreService();
              await firestoreService.deleteProject(widget.project.id);

              if (!context.mounted) return;
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project deleted successfully!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);

    final updatedProject = ProjectModel(
      id: widget.project.id,
      title: widget.project.title,
      description: widget.project.description,
      technologies: widget.project.technologies,
      supervisorName: widget.project.supervisorName,
      supervisorId: widget.project.supervisorId,
      studentId: widget.project.studentId,
      studentName: widget.project.studentName,
      progressStatus: newStatus,
      createdAt: widget.project.createdAt,
      updatedAt: DateTime.now(),
    );

    final firestoreService = FirestoreService();
    await firestoreService.updateProject(updatedProject);
    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Project status updated to $newStatus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Project' : 'Project Details'),
        backgroundColor: widget.isSupervisor ? Colors.green : Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!widget.isSupervisor && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!widget.isSupervisor && !_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProject,
            ),
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'Student Name',
                              widget.project.studentName,
                              Icons.person,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              'Supervisor',
                              widget.project.supervisorName,
                              Icons.supervisor_account,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              'Created',
                              _formatDate(widget.project.createdAt),
                              Icons.calendar_today,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              'Last Updated',
                              _formatDate(widget.project.updatedAt),
                              Icons.update,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Project Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: widget.isSupervisor
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isEditing)
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Project Title',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter title' : null,
                              )
                            else
                              _buildDetailRow('Title', widget.project.title),
                            const SizedBox(height: 16),
                            if (_isEditing)
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 4,
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter description' : null,
                              )
                            else
                              _buildDetailRow(
                                'Description',
                                widget.project.description,
                              ),
                            const SizedBox(height: 16),
                            if (_isEditing)
                              TextFormField(
                                controller: _technologiesController,
                                decoration: const InputDecoration(
                                  labelText: 'Technologies',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Enter technologies'
                                    : null,
                              )
                            else
                              _buildDetailRow(
                                'Technologies',
                                widget.project.technologies,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Project Status',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: widget.isSupervisor
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  widget.project.progressStatus,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(
                                      widget.project.progressStatus,
                                    ),
                                    color: _getStatusColor(
                                      widget.project.progressStatus,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.project.progressStatus
                                        .toUpperCase()
                                        .replaceAll('_', ' '),
                                    style: TextStyle(
                                      color: _getStatusColor(
                                        widget.project.progressStatus,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.isSupervisor) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Update Status:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildStatusButton('approved', Colors.green),
                                  _buildStatusButton('rejected', Colors.red),
                                  _buildStatusButton(
                                    'in_progress',
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Save Changes',
                        onPressed: _updateProject,
                        isLoading: _isLoading,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildStatusButton(String status, Color color) {
    return ElevatedButton(
      onPressed: () => _updateStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(status.toUpperCase()),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'submitted':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'submitted':
        return Icons.pending;
      case 'in_progress':
        return Icons.engineering;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
