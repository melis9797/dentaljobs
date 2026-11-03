import 'package:flutter/material.dart';

/// Compact dropdown for list filters; `null` means "all".
class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.allLabel,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String allLabel;
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String?>(
      isExpanded: true,
      value: options.containsKey(value) ? value : null,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(allLabel)),
        for (final e in options.entries)
          DropdownMenuItem<String?>(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
