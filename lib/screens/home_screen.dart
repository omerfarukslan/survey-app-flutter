import 'package:anket/screens/admin/addsurvey_screen.dart';
import 'package:anket/screens/survey/survey_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  bool isAdmin = false;
  String userName = '';

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!mounted) return; // Widget hala aktif mi kontrolü
      setState(() {
        isAdmin = (doc.data()?['isAdmin'] ?? false) == true;
        userName = (doc.data()?['name'] ?? '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anketler')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName.isNotEmpty ? userName : 'Kullanıcı'),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            ListTile(
              title: const Text('Profil'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            if (isAdmin)
              ListTile(
                title: const Text('Anket Sorusu Ekle'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddSurveyScreen()),
                  );
                },
              ),
            if (isAdmin)
              ListTile(
              title: const Text('Yönetici - Sonuçlar'),
              onTap: () => Navigator.pushNamed(
                context,
                '/results',
                arguments: {'surveyId': ''},
              ),
            ),
            ListTile(
              title: const Text('Çıkış'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: const SurveyListScreen(),
    );
  }
}
