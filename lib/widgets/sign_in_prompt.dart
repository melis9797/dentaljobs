import 'package:flutter/material.dart';

import '../screens/auth_screen.dart';

class SignInPrompt extends StatelessWidget {
  const SignInPrompt({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              ),
              child: const Text('Giriş yap / Kayıt ol'),
            ),
          ],
        ),
      ),
    );
  }
}
