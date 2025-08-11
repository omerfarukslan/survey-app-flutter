import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/survey_model.dart';
import 'survey_detail_screen.dart'; // Detay sayfasını import et

class SurveyListScreen extends StatelessWidget {
  const SurveyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    return StreamBuilder<List<Survey>>(
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
          return Center(child: Text('Henüz anket bulunmamaktadır.'));
        }

        return ListView.builder(
          itemCount: surveys.length,
          itemBuilder: (context, index) {
            final survey = surveys[index];
            return ListTile(
              title: Text('Anket ${index + 1}'),
              subtitle: Text('${survey.questions.length} soru içeriyor'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurveyDetailScreen(
                      surveyId: survey.id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}