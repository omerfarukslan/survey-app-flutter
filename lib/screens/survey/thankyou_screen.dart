import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.thumb_up, size: 72),
          const SizedBox(height: 12),
          const Text('Teşekkürler!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: const Text('Anasayfaya dön')),
        ]),
      ),
    );
  }
}
