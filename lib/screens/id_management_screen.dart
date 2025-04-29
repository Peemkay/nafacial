import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import 'package:provider/provider.dart';

class IDManagementScreen extends StatefulWidget {
  const IDManagementScreen({Key? key}) : super(key: key);

  @override
  State<IDManagementScreen> createState() => _IDManagementScreenState();
}

class _IDManagementScreenState extends State<IDManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('ID Management'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _showPrintDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => _showBatchGenerateDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<PersonnelProvider>(
              builder: (context, personnelProvider, child) {
                final personnel = personnelProvider.allPersonnel
                    .where((p) => _filterPersonnel(p))
                    .toList();

                return ListView.builder(
                  itemCount: personnel.length,
                  itemBuilder: (context, index) {
                    return _buildPersonnelIDCard(personnel[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIDGenerationDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or army number',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildPersonnelIDCard(Personnel personnel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: personnel.photoUrl != null
              ? NetworkImage(personnel.photoUrl!)
              : null,
          child: personnel.photoUrl == null
              ? Text(personnel.initials.substring(0, 2))
              : null,
        ),
        title: Text('${personnel.rank.displayName} ${personnel.fullName}'),
        subtitle: Text(personnel.armyNumber),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.badge),
              onPressed: () => _previewID(context, personnel),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showIDOptions(context, personnel),
            ),
          ],
        ),
      ),
    );
  }

  bool _filterPersonnel(Personnel personnel) {
    if (_searchQuery.isEmpty) return true;

    final query = _searchQuery.toLowerCase();
    return personnel.fullName.toLowerCase().contains(query) ||
        personnel.armyNumber.toLowerCase().contains(query);
  }

  void _showIDGenerationDialog(BuildContext context) {
    // Implement ID generation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate New ID'),
        content: const Text('Select ID generation options'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement ID generation logic
              Navigator.pop(context);
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _previewID(BuildContext context, Personnel personnel) {
    // Implement ID preview
  }

  void _showIDOptions(BuildContext context, Personnel personnel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print ID'),
            onTap: () {
              Navigator.pop(context);
              // Implement print logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Generate QR Code'),
            onTap: () {
              Navigator.pop(context);
              // Implement QR code generation
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Mark as Invalid'),
            onTap: () {
              Navigator.pop(context);
              // Implement invalidation logic
            },
          ),
        ],
      ),
    );
  }

  void _showPrintDialog(BuildContext context) {
    // Implement print dialog
  }

  void _showBatchGenerateDialog(BuildContext context) {
    // Implement batch generation dialog
  }
}
