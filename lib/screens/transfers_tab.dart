import 'package:flutter/material.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';
import '../widgets/location_fields.dart';
import 'listing_detail_screen.dart';

class TransfersTab extends StatefulWidget {
  const TransfersTab({super.key});

  @override
  State<TransfersTab> createState() => _TransfersTabState();
}

class _TransfersTabState extends State<TransfersTab>
    with AutomaticKeepAliveClientMixin {
  String? _city;
  String? _district;

  @override
  bool get wantKeepAlive => true;

  Future<List<Map<String, dynamic>>> _load() async {
    var query = supabase.from('clinic_transfers').select().eq('status', 'open');
    if (_city != null) query = query.eq('city', _city!);
    if (_district != null) query = query.eq('district', _district!);
    final data = await query.order('created_at', ascending: false).limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AsyncList(
      reloadKey: '$_city|$_district',
      load: _load,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: LocationFilter(
          city: _city,
          district: _district,
          onChanged: (city, district) => setState(() {
            _city = city;
            _district = district;
          }),
        ),
      ),
      emptyText: 'Bu filtrelere uygun devir ilanı yok.',
      itemBuilder: (context, item, _) => _TransferTile(item: item),
    );
  }
}

class _TransferTile extends StatelessWidget {
  const _TransferTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final district = item['district'] as String?;
    final units = item['unit_count'] as int?;
    final area = item['area_m2'] as int?;
    final facts = [
      if (units != null) '$units ünit',
      if (area != null) '$area m²',
      priceText(item['price'] as int?),
    ];
    final place = '${item['city']}${district == null ? '' : ' / $district'}';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        isThreeLine: true,
        title: Text(item['title'] as String),
        subtitle: Text('$place\n${facts.join(' · ')}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(
              title: item['title'] as String,
              subtitle: 'Klinik devir · $place',
              chips: facts,
              description: item['description'] as String?,
              phone: item['contact_phone'] as String,
            ),
          ),
        ),
      ),
    );
  }
}
