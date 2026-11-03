import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/form_widgets.dart';

/// Lets a clinic account create its clinic (once) and then post jobs.
class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicName = TextEditingController();
  final _title = TextEditingController();
  final _district = TextEditingController();
  final _salaryMin = TextEditingController();
  final _salaryMax = TextEditingController();
  final _description = TextEditingController();

  Map<String, dynamic>? _clinic;
  bool _loading = true;
  bool _saving = false;
  String _specialty = 'general';
  String _employment = 'full_time';
  String _city = cities.first;

  @override
  void initState() {
    super.initState();
    _loadClinic();
  }

  @override
  void dispose() {
    _clinicName.dispose();
    _title.dispose();
    _district.dispose();
    _salaryMin.dispose();
    _salaryMax.dispose();
    _description.dispose();
    super.dispose();
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String? _nullIfEmpty(String text) {
    final t = text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _loadClinic() async {
    try {
      final clinic = await supabase
          .from('clinics')
          .select()
          .eq('owner_id', supabase.auth.currentUser!.id)
          .limit(1)
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _clinic = clinic;
        final city = clinic?['city'] as String?;
        if (city != null && cities.contains(city)) _city = city;
        _district.text = (clinic?['district'] as String?) ?? '';
      });
    } catch (_) {
      _snack('Klinik bilgisi yüklenemedi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createClinic() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final clinic = await supabase
          .from('clinics')
          .insert({
            'owner_id': supabase.auth.currentUser!.id,
            'name': _clinicName.text.trim(),
            'city': _city,
            'district': _nullIfEmpty(_district.text),
          })
          .select()
          .single();
      if (!mounted) return;
      setState(() => _clinic = clinic);
    } on PostgrestException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await supabase.from('jobs').insert({
        'clinic_id': _clinic!['id'],
        'title': _title.text.trim(),
        'description': _nullIfEmpty(_description.text),
        'specialty': _specialty,
        'employment_type': _employment,
        'city': _city,
        'district': _nullIfEmpty(_district.text),
        'salary_min': int.tryParse(_salaryMin.text.trim()),
        'salary_max': int.tryParse(_salaryMax.text.trim()),
      });
      if (mounted) Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      _snack(e.code == '23514'
          ? 'Maksimum maaş minimumdan küçük olamaz.'
          : 'İlan kaydedilemedi.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Gerekli' : null;

  String? _numberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim()) == null ? 'Sayı gir' : null;
  }

  Widget _saveButton(String label, VoidCallback onPressed) {
    return FilledButton(
      onPressed: _saving ? null : onPressed,
      child: _saving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }

  Widget _clinicForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('İlan verebilmek için önce klinik bilgilerini gir.'),
        const SizedBox(height: 16),
        TextFormField(
          controller: _clinicName,
          decoration: const InputDecoration(
            labelText: 'Klinik adı',
            border: OutlineInputBorder(),
          ),
          validator: _requiredValidator,
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
        const SizedBox(height: 20),
        _saveButton('Kliniği kaydet', _createClinic),
      ],
    );
  }

  Widget _jobForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _title,
          decoration: const InputDecoration(
            labelText: 'İlan başlığı',
            border: OutlineInputBorder(),
          ),
          validator: _requiredValidator,
        ),
        const SizedBox(height: 12),
        LabeledDropdown(
          label: 'Branş / pozisyon',
          value: _specialty,
          options: specialties,
          onChanged: (v) => setState(() => _specialty = v),
        ),
        const SizedBox(height: 12),
        LabeledDropdown(
          label: 'Çalışma şekli',
          value: _employment,
          options: employmentTypes,
          onChanged: (v) => setState(() => _employment = v),
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
                controller: _salaryMin,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Min maaş (₺)',
                  border: OutlineInputBorder(),
                ),
                validator: _numberValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _salaryMax,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max maaş (₺)',
                  border: OutlineInputBorder(),
                ),
                validator: _numberValidator,
              ),
            ),
          ],
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
        _saveButton('İlanı yayınla', _createJob),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni ilan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: _clinic == null ? _clinicForm() : _jobForm(),
            ),
    );
  }
}
