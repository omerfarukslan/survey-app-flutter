import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/survey_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Anketleri oluşturulma tarihine göre yeni -> eski olarak sıralayarak getiriyoruz
  Stream<List<Survey>> surveysStream() {
    return _db
        .collection('surveys')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Survey.fromDoc(d)).toList());
  }

  Future<Survey> getSurveyById(String id) async {
    final doc = await _db.collection('surveys').doc(id).get();
    return Survey.fromDoc(doc);
  }

  Future<void> submitResponse(String surveyId, String userId, Map<String, dynamic> answers) async {
    await _db.collection('responses').add({
      'surveyId': surveyId,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'answers': answers,
    });
  }

  Stream<QuerySnapshot> responsesForSurvey(String surveyId) {
    return _db.collection('responses').where('surveyId', isEqualTo: surveyId).snapshots();
  }

  /// Anket cevaplarını, soru bazında gruplayarak,
  /// her cevap için kaç kişinin verdiğini sayan fonksiyon

  Future<Map<int, Map<String, int>>> getAnswersCountGroupedByQuestion(String surveyId) async {
    final snapshot = await _db.collection('responses').where('surveyId', isEqualTo: surveyId).get();

    // questionIndex -> {cevap -> adet}
    final Map<int, Map<String, int>> result = {};

    for (var doc in snapshot.docs) {
      final answers = Map<String, dynamic>.from(doc.data()['answers'] ?? {});
      answers.forEach((key, value) {
        // key q1, q2, ... formatında, index için -1 çıkaracağız
        final questionIndex = int.tryParse(key.replaceAll('q', '')) ?? -1;
        if (questionIndex == -1) return;

        final answerStr = (value ?? '').toString();

        if (!result.containsKey(questionIndex - 1)) {
          result[questionIndex - 1] = {};
        }
        result[questionIndex - 1]![answerStr] = (result[questionIndex - 1]![answerStr] ?? 0) + 1;
      });
    }

    return result;
  }

}
