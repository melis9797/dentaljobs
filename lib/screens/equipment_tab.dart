import 'package:flutter/material.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/async_list.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/location_fields.dart';
import 'listing_detail_screen.dart';

class EquipmentTab extends StatefulWidget {
  const EquipmentTab({super.key});

  @override
  State<EquipmentTab> createState() => _EquipmentTabState();
}

class _EquipmentTabState extends State<EquipmentTab>
    with AutomaticKeepAliveClientMixin {
  String? _city;
  String? _district;
  String? _type;
  String? _condition;

  @override
  bool get wantKeepAlive => true;

  Future<List<Map<String, dynamic>>> _load() async {
    var query =
        supabase.from('equipment_listings').select().eq('status', 'open');
    if (_city != null) query = query.eq('city', _city!);
    if (_district != null) query = query.eq('district', _district!);
    if (_type != null) query = query.eq('item_type', _type!);
    if (_condition != null) query = query.eq('condition', _condition!);
    final data = await query.order('created_at', ascending: false).limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          LocationFilter(
            city: _city,
            district: _district,
            onChanged: (city, district) => setState(() {
              _city = city;
              _district = district;
            }),
          ),
          Row(
            children: [
              Expanded(
                child: FilterDropdown(
                  allLabel: 'İmplant ve ekipman',
                  value: _type,
                  options: itemTypes,
                  onChanged: (v) => setState(() => _type = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilterDropdown(
                  allLabel: 'Sıfır ve ikinci el',
                  value: _condition,
                  options: itemConditions,
                  onChanged: (v) => setState(() => _condition = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AsyncList(
      reloadKey: '$_city|$_district|$_type|$_condition',
      load: _load,
      header: _filters(),
      emptyText: 'Bu filtrelere uygun ilan yok.',
      itemBuilder: (context, item, _) => _EquipmentTile(item: item),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final brand = item['brand'] as String?;
    final district = item['district'] as String?;
    final place = '${item['city']}${district == null ? '' : ' / $district'}';
    final kind = [
      itemTypes[item['item_type']] ?? '',
      itemConditions[item['condition']] ?? '',
      if (brand != null) brand,
    ];
    final price = priceText(item['price'] as int?);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        isThreeLine: true,
        title: Text(item['title'] as String),
        subtitle: Text('${kind.join(' · ')}\n$place · $price'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(
              title: item['title'] as String,
              subtitle: place,
              chips: [...kind, price],
              description: item['description'] as String?,
              phone: item['contact_phone'] as String,
            ),
          ),
        ),
      ),
    );
  }
}
