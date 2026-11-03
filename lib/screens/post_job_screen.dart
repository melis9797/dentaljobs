import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../validators.dart';
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
  String _profile = 'staff';
  String _experience = 'new_grad';
  String _specialty = specialistBranches.keys.first;
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
            'district': nullIfEmpty(_district.text),
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
    final isStaff = _profile == 'staff';
    try {
      await supabase.from('jobs').insert({
        'clinic_id': _clinic!['id'],
        'title': _title.text.trim(),
        'description': nullIfEmpty(_description.text),
        'job_profile': _profile,
        'experience_level': isStaff ? _experience : null,
        'specialty': isStaff ? 'general' : _specialty,
        'employment_type': _employment,
        'city': _city,
        'district': nullIfEmpty(_district.text),
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
        const Text('İş ilanı verebilmek için önce klinik bilgilerini gir.'),
        const SizedBox(height: 16),
        TextFormField(
          controller: _clinicName,
          decoration: const InputDecoration(
            labelText: 'Klinik adı',
            border: OutlineInputBorder(),
          ),
          validator: requiredField,
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
    final isStaff = _profile == 'staff';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LabeledDropdown(
          label: 'Pozisyon',
          value: _profile,
          options: jobProfiles,
          onChanged: (v) => setState(() => _profile = v),
        ),
        const SizedBox(height: 12),
        if (isStaff)
          LabeledDropdown(
            label: 'Deneyim grubu',
            value: _experience,
            options: experienceLevels,
            onChanged: (v) => setState(() => _experience = v),
          )
        else
          LabeledDropdown(
            label: 'Branş',
            value: _specialty,
            options: specialistBranches,
            onChanged: (v) => setState(() => _specialty = v),
          ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _title,
          decoration: const InputDecoration(
            labelText: 'İlan başlığı',
            border: OutlineInputBorder(),
          ),
          validator: requiredField,
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
                validator: optionalNumber,
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
                validator: optionalNumber,
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
      appBar: AppBar(title: const Text('Yeni iş ilanı')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: _clinic == null ? _clinicForm() : _jobForm(),
            ),
    );
  }
}
