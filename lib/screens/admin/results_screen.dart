import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/survey_model.dart';

class ResultsScreen extends StatelessWidget {
  final String surveyId;
  const ResultsScreen({super.key, required this.surveyId});

  Future<Survey> _loadSurvey(BuildContext context) async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    return await fs.getSurveyById(surveyId);
  }

  Future<Map<int, Map<String, int>>> _loadAnswersCount(BuildContext context) async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    return await fs.getAnswersCountGroupedByQuestion(surveyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anket Sonuçları')),
      body: FutureBuilder<Survey>(
        future: _loadSurvey(context),
        builder: (context, surveySnapshot) {
          if (surveySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (surveySnapshot.hasError) {
            return Center(child: Text('Hata: ${surveySnapshot.error}'));
          }
          final survey = surveySnapshot.data!;
          return FutureBuilder<Map<int, Map<String, int>>>(
            future: _loadAnswersCount(context),
            builder: (context, answersCountSnapshot) {
              if (answersCountSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (answersCountSnapshot.hasError) {
                return Center(child: Text('Hata: ${answersCountSnapshot.error}'));
              }
              final answersCount = answersCountSnapshot.data ?? {};

              return ListView.builder(
                itemCount: survey.questions.length,
                itemBuilder: (context, index) {
                  final question = survey.questions[index];
                  final countsForQuestion = answersCount[index] ?? {};

                  // En çok verilen cevap
                  String mostGivenAnswer = 'Henüz cevap yok';
                  if (countsForQuestion.isNotEmpty) {
                    final sorted = countsForQuestion.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    mostGivenAnswer = sorted.first.key;
                  }

                  return ListTile(
                    title: Text('Soru ${index + 1}: $question'),
                    subtitle: Text('En çok verilen cevap: $mostGivenAnswer'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
