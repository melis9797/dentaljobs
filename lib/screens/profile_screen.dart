import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/form_widgets.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  String? _city;
  String? _specialty;
  String _role = 'dentist';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await fetchMyProfile();
    if (!mounted) return;
    setState(() {
      if (profile != null) {
        _role = (profile['role'] as String?) ?? 'dentist';
        _name.text = (profile['full_name'] as String?) ?? '';
        _phone.text = (profile['phone'] as String?) ?? '';
        _bio.text = (profile['bio'] as String?) ?? '';
        _city = profile['city'] as String?;
        _specialty = profile['specialty'] as String?;
      }
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await supabase.from('profiles').update({
        'full_name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'bio': _bio.text.trim(),
        'city': _city,
        'specialty': _specialty,
      }).eq('id', supabase.auth.currentUser!.id);
      _snack('Profil kaydedildi.');
    } on PostgrestException {
      _snack('Profil kaydedilemedi.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    if (supabase.auth.currentUser == null) return const AuthScreen();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          TextButton(
            onPressed: () => supabase.auth.signOut(),
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _role == 'clinic' ? 'Klinik hesabı' : 'İş arayan hesabı',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: _role == 'clinic' ? 'Yetkili adı' : 'Ad soyad',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    helperText: 'Başvurduğun kliniklerin sana ulaşabilmesi için',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                LabeledDropdown(
                  label: 'Şehir',
                  value: _city,
                  options: cityOptions,
                  onChanged: (v) => setState(() => _city = v),
                ),
                if (_role != 'clinic') ...[
                  const SizedBox(height: 12),
                  LabeledDropdown(
                    label: 'Branş / pozisyon',
                    value: _specialty,
                    options: specialties,
                    onChanged: (v) => setState(() => _specialty = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bio,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Kısa özgeçmiş',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Kaydet'),
                ),
              ],
            ),
    );
  }
}
