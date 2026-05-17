// fix_supervisor_ids.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

void main() async {
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  // Get all supervisors
  final supervisors = await firestore
      .collection('users')
      .where('role', isEqualTo: 'supervisor')
      .get();

  if (supervisors.docs.isEmpty) {
    debugPrint('No supervisors found!');
    return;
  }

  debugPrint('Found ${supervisors.docs.length} supervisors:');
  for (var doc in supervisors.docs) {
    debugPrint('  - ${doc.data()['name']} (${doc.id})');
  }

  // Get all projects without correct supervisorId
  final projects = await firestore.collection('projects').get();

  int fixed = 0;
  for (var doc in projects.docs) {
    final data = doc.data();
    final currentName = data['supervisorName'];

    // Find matching supervisor
    for (var sup in supervisors.docs) {
      if (sup.data()['name'] == currentName) {
        if (data['supervisorId'] != sup.id) {
          await doc.reference.update({'supervisorId': sup.id});
          debugPrint(
            'Fixed: ${data['title']} -> assigned to ${sup.data()['name']}',
          );
          fixed++;
        }
        break;
      }
    }
  }

  debugPrint('\n✅ Fixed $fixed projects!');
}
