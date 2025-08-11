import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/survey_model.dart';
import 'results_screen.dart';

class ResultsListScreen extends StatelessWidget {
  const ResultsListScreen({super.key});

  Future<int> _getResponseCount(BuildContext context, String surveyId) async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    if (surveyId.isEmpty) return 0;
    final snapshot = await fs.responsesForSurvey(surveyId).first;
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Anket Sonuçları')),
      body: StreamBuilder<List<Survey>>(
        stream: fs.surveysStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata oluştu: ${snapshot.error}'));
          }
          final surveys = snapshot.data ?? [];
          if (surveys.isEmpty) {
            return const Center(child: Text('Henüz anket bulunmamaktadır.'));
          }

          return ListView.builder(
            itemCount: surveys.length,
            itemBuilder: (context, index) {
              final survey = surveys[index];
              final surveyId = survey.id;
              if (surveyId.isEmpty) return const SizedBox.shrink();

              return FutureBuilder<int>(
                future: _getResponseCount(context, surveyId),
                builder: (context, responseSnapshot) {
                  if (responseSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Anket ${index + 1}'),
                      subtitle: const Text('Yükleniyor...'),
                    );
                  }

                  final responseCount = responseSnapshot.data ?? 0;
                  return ListTile(
                    title: Text('Anket ${index + 1}'),
                    subtitle: Text('${survey.questions.length} soru, $responseCount cevap'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultsScreen(surveyId: surveyId),
                        ),
                      );
                    },
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
