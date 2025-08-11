import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/survey_model.dart';

class SurveyDetailScreen extends StatefulWidget {
  final String surveyId;
  const SurveyDetailScreen({super.key, required this.surveyId});

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen> {
  Survey? _survey;
  final Map<int, String> _answers = {};
  bool _loading = false;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final s = await fs.getSurveyById(widget.surveyId);
    setState(() => _survey = s);
  }

  void _submit() async {
    setState(() => _loading = true);
    try {
      final fs = Provider.of<FirestoreService>(context, listen: false);
      final userName = currentUser?.email ?? "isimsiz";

      // answers mapini index->cevap olarak, string->dynamic map'e çeviriyoruz
      final answersMap = <String, dynamic>{};
      _answers.forEach((key, value) {
        answersMap['q${key + 1}'] = value;
      });

      await fs.submitResponse(widget.surveyId, userName, answersMap);
      Navigator.pushReplacementNamed(context, '/thankyou');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gönderilemedi: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_survey == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('Anket Detayları')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            /*
            Text(_survey!.createdBy,
                style: const TextStyle(fontWeight: FontWeight.bold)),
             */
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _survey!.questions.length,
                itemBuilder: (context, i) {
                  final question = _survey!.questions[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soru ${i + 1}: $question',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _answers[i] = value.toUpperCase();
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Cevabınızı yazınız',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child:
                  _loading
                      ? const CircularProgressIndicator()
                      : const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
