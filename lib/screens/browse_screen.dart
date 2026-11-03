import 'package:flutter/material.dart';

import 'equipment_tab.dart';
import 'jobs_tab.dart';
import 'transfers_tab.dart';

/// Public listings in three sections: jobs, clinic transfers, implants/equipment.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('İlanlar'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'İş ilanları'),
              Tab(text: 'Klinik devir'),
              Tab(text: 'İmplant / Ekipman'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [JobsTab(), TransfersTab(), EquipmentTab()],
        ),
      ),
    );
  }
}
