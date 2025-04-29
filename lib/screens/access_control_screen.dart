import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';

class AccessControlScreen extends StatefulWidget {
  const AccessControlScreen({Key? key}) : super(key: key);

  @override
  State<AccessControlScreen> createState() => _AccessControlScreenState();
}

class _AccessControlScreenState extends State<AccessControlScreen> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Access Control'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            'Access Points',
            [
              _buildControlItem('Main Gate', true),
              _buildControlItem('Admin Building', true),
              _buildControlItem('Restricted Area', false),
            ],
          ),
          const Divider(),
          _buildSection(
            'Access Levels',
            [
              _buildControlItem('Level 1 - Basic Access', true),
              _buildControlItem('Level 2 - Extended Access', true),
              _buildControlItem('Level 3 - Admin Access', false),
            ],
          ),
          const Divider(),
          _buildSection(
            'Time Restrictions',
            [
              _buildControlItem('Working Hours (8AM-5PM)', true),
              _buildControlItem('After Hours Access', false),
              _buildControlItem('Weekend Access', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildControlItem(String title, bool isEnabled) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) {
          setState(() {
            // Implement actual state management here
          });
        },
      ),
    );
  }
}
