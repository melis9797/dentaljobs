import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';
import '../widgets/form_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _signUp = false;
  bool _loading = false;
  String _role = 'dentist';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_signUp) {
        final res = await supabase.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          data: {'role': _role, 'full_name': _name.text.trim()},
        );
        if (res.session == null) {
          _snack('Kayıt oluşturuldu. E-postanı doğrulayıp giriş yap.');
          if (mounted) setState(() => _signUp = false);
          return;
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Bir hata oluştu. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_signUp ? 'Kayıt ol' : 'Giriş yap')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_signUp) ...[
              LabeledDropdown(
                label: 'Hesap türü',
                value: _role,
                options: const {
                  'dentist': 'İş arıyorum (hekim, asistan, teknisyen)',
                  'clinic': 'Klinik / hastane (eleman arıyorum)',
                },
                onChanged: (v) => setState(() => _role = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: _role == 'clinic' ? 'Yetkili adı' : 'Ad soyad',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Gerekli' : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Geçerli e-posta gir' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'En az 6 karakter' : null,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_signUp ? 'Kayıt ol' : 'Giriş yap'),
            ),
            TextButton(
              onPressed: () => setState(() => _signUp = !_signUp),
              child: Text(_signUp
                  ? 'Zaten hesabım var, giriş yap'
                  : 'Hesabın yok mu? Kayıt ol'),
            ),
          ],
        ),
      ),
    );
  }
}
