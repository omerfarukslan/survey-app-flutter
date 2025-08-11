import 'package:cloud_firestore/cloud_firestore.dart';

class Survey {
  final String id;
  final String createdBy;
  final List<String> questions;
  final Timestamp? createdAt;

  Survey({
    required this.id,
    required this.createdBy,
    required this.questions,
    this.createdAt,
  });

  factory Survey.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Geçersiz veri yapısı');
    }
    
    final questions = List<String>.from(data['questions'] ?? []);

    return Survey(
      id: doc.id,
      createdBy: data['createdBy'] ?? '',
      questions: questions,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
