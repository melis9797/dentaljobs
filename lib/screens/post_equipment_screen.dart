import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/location_fields.dart';

/// Post an implant or clinic equipment sale listing. Any signed-in user can post.
class PostEquipmentScreen extends StatefulWidget {
  const PostEquipmentScreen({super.key});

  @override
  State<PostEquipmentScreen> createState() => _PostEquipmentScreenState();
}

class _PostEquipmentScreenState extends State<PostEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _brand = TextEditingController();
  final _price = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  String _type = 'equipment';
  String _condition = 'used';
  String? _city;
  String? _district;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prefillPhone();
  }

  @override
  void dispose() {
    _title.dispose();
    _brand.dispose();
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
    final locationProblem =
        locationError(_city, _district, districtRequired: false);
    if (locationProblem != null) {
      _snack(locationProblem);
      return;
    }
    setState(() => _saving = true);
    try {
      await supabase.from('equipment_listings').insert({
        'owner_id': supabase.auth.currentUser!.id,
        'title': _title.text.trim(),
        'description': nullIfEmpty(_description.text),
        'item_type': _type,
        'condition': _condition,
        'brand': nullIfEmpty(_brand.text),
        'city': _city,
        'district': _district,
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
      appBar: AppBar(title: const Text('İmplant / ekipman satış ilanı')),
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
              label: 'Tür',
              value: _type,
              options: itemTypes,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 12),
            LabeledDropdown(
              label: 'Durum',
              value: _condition,
              options: itemConditions,
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brand,
              decoration: const InputDecoration(
                labelText: 'Marka',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            LocationFields(
              city: _city,
              district: _district,
              districtRequired: false,
              onChanged: (city, district) => setState(() {
                _city = city;
                _district = district;
              }),
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
