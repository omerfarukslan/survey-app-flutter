import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddSurveyScreen extends StatefulWidget {
  const AddSurveyScreen({super.key});

  @override
  State<AddSurveyScreen> createState() => _AddSurveyScreenState();
}

class _AddSurveyScreenState extends State<AddSurveyScreen> {
  final List<TextEditingController> _questionControllers = [TextEditingController()];

  void addQuestionField() {
    setState(() {
      _questionControllers.add(TextEditingController());
    });
  }

  Future<void> saveSurvey() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      List<String> questions = _questionControllers
          .map((controller) => controller.text.trim())
          .where((q) => q.isNotEmpty)
          .toList();

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir soru girin')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('surveys').add({
        'questions': questions,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anket Sorusu Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questionControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: _questionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Soru ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: addQuestionField,
                  icon: const Icon(Icons.add),
                  label: const Text('Soru Ekle'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: saveSurvey,
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
