import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../validators.dart';
import '../widgets/form_widgets.dart';

/// Post a clinic transfer (devir) listing. Any signed-in user can post.
class PostTransferScreen extends StatefulWidget {
  const PostTransferScreen({super.key});

  @override
  State<PostTransferScreen> createState() => _PostTransferScreenState();
}

class _PostTransferScreenState extends State<PostTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _district = TextEditingController();
  final _units = TextEditingController();
  final _area = TextEditingController();
  final _price = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  String _city = cities.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prefillPhone();
  }

  @override
  void dispose() {
    _title.dispose();
    _district.dispose();
    _units.dispose();
    _area.dispose();
    _price.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _prefillPhone() async {
    try {
      final profile = await fetchMyProfile();
      final phone = profile?['phone'] as String?;
      if (mounted && phone != null && _phone.text.isEmpty) _phone.text = phone;
    } catch (_) {}
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await supabase.from('clinic_transfers').insert({
        'owner_id': supabase.auth.currentUser!.id,
        'title': _title.text.trim(),
        'description': nullIfEmpty(_description.text),
        'city': _city,
        'district': nullIfEmpty(_district.text),
        'unit_count': int.tryParse(_units.text.trim()),
        'area_m2': int.tryParse(_area.text.trim()),
        'price': int.tryParse(_price.text.trim()),
        'contact_phone': cleanPhone(_phone.text),
      });
      if (mounted) Navigator.of(context).pop(true);
    } on PostgrestException {
      _snack('İlan kaydedilemedi. Bilgileri kontrol edip tekrar dene.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klinik devir ilanı')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'İlan başlığı',
                border: OutlineInputBorder(),
              ),
              validator: titleField,
            ),
            const SizedBox(height: 12),
            LabeledDropdown(
              label: 'Şehir',
              value: _city,
              options: cityOptions,
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _district,
              decoration: const InputDecoration(
                labelText: 'İlçe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _units,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ünit sayısı',
                      border: OutlineInputBorder(),
                    ),
                    validator: optionalNumberUpTo(100),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _area,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Metrekare',
                      border: OutlineInputBorder(),
                    ),
                    validator: optionalNumberUpTo(100000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fiyat (₺)',
                helperText: 'Boş bırakırsan "Fiyat görüşülür" yazar',
                border: OutlineInputBorder(),
              ),
              validator: optionalNumber,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'İletişim telefonu',
                helperText: 'İlanda herkese görünür',
                border: OutlineInputBorder(),
              ),
              validator: phoneField,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('İlanı yayınla'),
            ),
          ],
        ),
      ),
    );
  }
}
