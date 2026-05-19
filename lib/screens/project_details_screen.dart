import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

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
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

  static const Color _studentColor = Color(0xFF3E6478);
  static const Color _supervisorColor = Color(0xFF16A34A);
  static const Color _surfaceColor = Color(0xFFF3F8F9);
  static const Color _textColor = Color(0xFF172033);

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
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

    await _firestoreService.updateProject(updatedProject);

    if (!mounted) return;

    setState(() {
      widget.project.progressStatus = newStatus;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project status updated to ${_getStatusText(newStatus)}'),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter feedback')));
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthService();
    final user = await authService.currentUser.first;

    await FirebaseFirestore.instance.collection('feedback').add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'projectId': widget.project.id,
      'supervisorId': user!.uid,
      'supervisorName': user.name,
      'feedback': feedback,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    _feedbackController.clear();
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted successfully')),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'in_progress':
        return const Color(0xFF3E6478);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'in_progress':
        return Icons.engineering;
      case 'pending':
        return Icons.pending_actions;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isSupervisor ? _supervisorColor : _studentColor;

    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: AppBar(
        title: const Text('Project Details'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryHeader(accentColor),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 760;
                        if (!isWide) {
                          return Column(
                            children: [
                              _buildProjectInfoCard(),
                              const SizedBox(height: 16),
                              _buildStatusCard(accentColor),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildProjectInfoCard()),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildStatusCard(accentColor),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFeedbackListCard(),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.55),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.project.technologies,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildStatusPill(widget.project.progressStatus, onDark: true),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    return _Panel(
      title: 'Project Information',
      icon: Icons.article_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile('Student', widget.project.studentName, Icons.person),
          const SizedBox(height: 10),
          _buildInfoTile(
            'Supervisor',
            widget.project.supervisorName,
            Icons.supervisor_account,
          ),
          const SizedBox(height: 10),
          _buildInfoTile(
            'Technologies',
            widget.project.technologies,
            Icons.code,
          ),
          const SizedBox(height: 18),
          const Text(
            'Description',
            style: TextStyle(
              color: _textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.project.description,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Color accentColor) {
    return _Panel(
      title: widget.isSupervisor ? 'Review Project' : 'Project Status',
      icon: Icons.fact_check_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusPill(widget.project.progressStatus),
          if (widget.isSupervisor) ...[
            const SizedBox(height: 18),
            const Text(
              'Update Status',
              style: TextStyle(
                color: _textColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  'Approve',
                  const Color(0xFF16A34A),
                  Icons.check,
                  'approved',
                ),
                _buildActionButton(
                  'Reject',
                  const Color(0xFFDC2626),
                  Icons.close,
                  'rejected',
                ),
                _buildActionButton(
                  'In Progress',
                  const Color(0xFF3E6478),
                  Icons.engineering,
                  'in_progress',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 18),
            const Text(
              'Give Feedback',
              style: TextStyle(
                color: _textColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _feedbackController,
              minLines: 4,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write feedback for this student',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitFeedback,
                icon: const Icon(Icons.send),
                label: const Text('Submit Feedback'),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackListCard() {
    return _Panel(
      title: 'Feedback',
      icon: Icons.feedback_outlined,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .where('projectId', isEqualTo: widget.project.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(
              'Unable to load feedback right now.',
              style: TextStyle(color: Colors.red.shade700),
            );
          }

          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final feedbacks = [...snapshot.data!.docs];
          feedbacks.sort((a, b) {
            final aTime = a.data()['timestamp'];
            final bTime = b.data()['timestamp'];
            final aDate = aTime is Timestamp
                ? aTime.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = bTime is Timestamp
                ? bTime.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

          if (feedbacks.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F8F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC8DDDF)),
              ),
              child: const Text(
                'No feedback has been submitted for this project yet.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            );
          }

          return Column(
            children: feedbacks.map((doc) {
              final data = doc.data();
              final timestamp = data['timestamp'];

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F8F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC8DDDF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data['supervisorName']?.toString() ?? 'Supervisor',
                            style: const TextStyle(
                              color: _textColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          timestamp is Timestamp
                              ? _formatFeedbackDate(timestamp.toDate())
                              : 'Just now',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['feedback']?.toString() ?? '',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F9),
        border: Border.all(color: const Color(0xFFC8DDDF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status, {bool onDark = false}) {
    final statusColor = _getStatusColor(status);
    final foreground = onDark ? Colors.white : statusColor;
    final background = onDark
        ? Colors.white.withValues(alpha: 0.16)
        : statusColor.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.2)
              : statusColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), color: foreground, size: 18),
          const SizedBox(width: 8),
          Text(
            _getStatusText(status).toUpperCase(),
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    String status,
  ) {
    return FilledButton.icon(
      onPressed: () => _updateStatus(status),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatFeedbackDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hour:$minute';
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Panel({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8DDDF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF475569), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _ProjectDetailsScreenState._textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
