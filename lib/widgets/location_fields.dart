import 'package:flutter/material.dart';

import '../turkey_locations.dart';

/// Dropdown you can type into. Typing "istanbul" also finds "İstanbul".
class SearchableDropdown extends StatelessWidget {
  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
    this.allLabel,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  /// When set, an extra first entry clears the selection (used by filters).
  final String? allLabel;

  @override
  Widget build(BuildContext context) {
    final selected = options.contains(value) ? value : null;
    // The key makes the menu rebuild when the selection is reset from outside
    // (for example the district after the city changes).
    final menuKey = ValueKey(
      '$label|$selected|${options.length}|${options.isEmpty ? '' : options.first}',
    );
    return DropdownMenu<String?>(
      key: menuKey,
      initialSelection: selected,
      label: allLabel == null ? Text(label) : null,
      hintText: allLabel,
      enabled: enabled,
      enableFilter: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 320,
      filterCallback: (entries, filter) {
        final query = normalizeTr(filter.trim());
        if (query.isEmpty) return entries;
        return entries
            .where((e) => normalizeTr(e.label).contains(query))
            .toList();
      },
      dropdownMenuEntries: [
        if (allLabel != null)
          DropdownMenuEntry<String?>(value: null, label: allLabel!),
        for (final o in options) DropdownMenuEntry<String?>(value: o, label: o),
      ],
      onSelected: onChanged,
    );
  }
}

/// City and district pickers for forms. Picking a city lists its districts.
class LocationFields extends StatelessWidget {
  const LocationFields({
    super.key,
    required this.city,
    required this.district,
    required this.onChanged,
    this.districtRequired = true,
  });

  final String? city;
  final String? district;
  final void Function(String? city, String? district) onChanged;
  final bool districtRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchableDropdown(
          label: 'Şehir',
          value: city,
          options: provinces,
          onChanged: (c) => onChanged(c, null),
        ),
        const SizedBox(height: 12),
        SearchableDropdown(
          label: districtRequired ? 'İlçe' : 'İlçe (isteğe bağlı)',
          value: district,
          options: districtsOf(city),
          enabled: city != null,
          onChanged: (d) => onChanged(city, d),
        ),
      ],
    );
  }
}

/// City and district filters for the listing tabs ("all" when empty).
class LocationFilter extends StatelessWidget {
  const LocationFilter({
    super.key,
    required this.city,
    required this.district,
    required this.onChanged,
  });

  final String? city;
  final String? district;
  final void Function(String? city, String? district) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchableDropdown(
            label: 'Şehir',
            allLabel: 'Tüm şehirler',
            value: city,
            options: provinces,
            onChanged: (c) => onChanged(c, null),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SearchableDropdown(
            label: 'İlçe',
            allLabel: 'Tüm ilçeler',
            value: district,
            options: districtsOf(city),
            enabled: city != null,
            onChanged: (d) => onChanged(city, d),
          ),
        ),
      ],
    );
  }
}

/// Error message when the location is incomplete, otherwise null.
String? locationError(
  String? city,
  String? district, {
  bool districtRequired = true,
}) {
  if (city == null) return 'Şehir seç';
  if (districtRequired && district == null) return 'İlçe seç';
  return null;
}
