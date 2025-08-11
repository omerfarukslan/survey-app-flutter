import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isAdmin = false;
  String _displayName = 'Anonim';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _isAdmin = data['isAdmin'] == true;
          _displayName = data['name'] ?? 'Anonim';
        });
      } else {
        // Eğer users koleksiyonunda doküman yoksa fallback olarak FirebaseAuth.displayName kullan
        final authUser = FirebaseAuth.instance.currentUser;
        setState(() {
          _displayName = authUser?.displayName ?? 'Anonim';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final firstLetter = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                firstLetter,
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_isAdmin)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      '(Admin)',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            Text(auth.user?.email ?? ''),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Çıkış yap'),
            ),
          ],
        ),
      ),
    );
  }
}
