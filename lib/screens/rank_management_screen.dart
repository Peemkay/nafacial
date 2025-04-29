import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';
import '../models/personnel_model.dart';

class RankManagementScreen extends StatefulWidget {
  const RankManagementScreen({Key? key}) : super(key: key);

  @override
  State<RankManagementScreen> createState() => _RankManagementScreenState();
}

class _RankManagementScreenState extends State<RankManagementScreen> {
  final List<Map<String, dynamic>> _ranks = [
    {'rank': Rank.private, 'level': 1, 'isActive': true},
    {'rank': Rank.corporal, 'level': 2, 'isActive': true},
    {'rank': Rank.sergeant, 'level': 3, 'isActive': true},
    // Add more ranks as needed
  ];

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Rank Management'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRankHeader(),
          Expanded(
            child: ReorderableListView(
              onReorder: _reorderRanks,
              children: _ranks.map((rank) => _buildRankTile(rank)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRankDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRankHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Rank',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Level',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 48), // Space for actions
        ],
      ),
    );
  }

  Widget _buildRankTile(Map<String, dynamic> rank) {
    return Card(
      key: ValueKey(rank['rank']),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(Icons.military_tech),
        title: Text(rank['rank'].displayName),
        subtitle: Text('Level ${rank['level']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rank['isActive'],
              onChanged: (value) {
                setState(() {
                  rank['isActive'] = value;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditRankDialog(context, rank),
            ),
          ],
        ),
      ),
    );
  }

  void _reorderRanks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _ranks.removeAt(oldIndex);
      _ranks.insert(newIndex, item);
      
      // Update levels after reordering
      for (int i = 0; i < _ranks.length; i++) {
        _ranks[i]['level'] = i + 1;
      }
    });
  }

  void _showAddRankDialog(BuildContext context) {
    // Implement add rank dialog
  }

  void _showEditRankDialog(BuildContext context, Map<String, dynamic> rank) {
    // Implement edit rank dialog
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rank Management Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Drag and drop ranks to reorder hierarchy'),
              Text('• Toggle switches to activate/deactivate ranks'),
              Text('• Edit ranks to modify their properties'),
              Text('• Add new ranks using the + button'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}