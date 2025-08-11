import 'package:flutter/material.dart';
import '../models/survey_model.dart';

class SurveyCard extends StatelessWidget {
  final Survey survey;
  const SurveyCard({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(
          "Anket ${survey.id}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          survey.questions.isNotEmpty
              ? survey.questions.first
              : "Henüz soru eklenmemiş",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          '/surveyDetail',
          arguments: {'surveyId': survey.id},
        ),
      ),
    );
  }
}
