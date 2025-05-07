import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trash_model.dart';
import '../models/personnel_model.dart';
import '../providers/trash_provider.dart';
import '../providers/personnel_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../widgets/empty_state.dart';
import '../widgets/confirmation_dialog.dart';

class TrashScreen extends StatefulWidget {
  static const String routeName = '/trash';

  const TrashScreen({Key? key}) : super(key: key);

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize trash provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trashProvider = Provider.of<TrashProvider>(context, listen: false);
      trashProvider.initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Restore a personnel from trash
  Future<void> _restorePersonnel(BuildContext context, TrashItem trashItem) async {
    setState(() => _isLoading = true);
    
    try {
      final trashProvider = Provider.of<TrashProvider>(context, listen: false);
      final personnel = await trashProvider.restorePersonnelFromTrash(trashItem.id);
      
      if (personnel != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${personnel.fullName} has been restored'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to restore personnel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Permanently delete a trash item
  Future<void> _permanentlyDeleteTrashItem(BuildContext context, TrashItem trashItem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Permanently Delete',
        content: 'This action cannot be undone. Are you sure you want to permanently delete this item?',
        confirmText: 'Delete Permanently',
        confirmColor: Colors.red,
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      final trashProvider = Provider.of<TrashProvider>(context, listen: false);
      final success = await trashProvider.permanentlyDeleteTrashItem(trashItem.id);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item permanently deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete item'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Empty the trash
  Future<void> _emptyTrash(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Empty Trash',
        content: 'This will permanently delete all items in the trash. This action cannot be undone. Are you sure?',
        confirmText: 'Empty Trash',
        confirmColor: Colors.red,
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      final trashProvider = Provider.of<TrashProvider>(context, listen: false);
      final success = await trashProvider.emptyTrash();
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trash emptied successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to empty trash'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Items'),
            Tab(text: 'Personnel'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Empty Trash',
            onPressed: () => _emptyTrash(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const LoadingIndicator()
          : Consumer<TrashProvider>(
              builder: (context, trashProvider, child) {
                if (trashProvider.isLoading) {
                  return const LoadingIndicator();
                }
                
                if (trashProvider.error != null) {
                  return ErrorMessage(
                    message: trashProvider.error!,
                    onRetry: () => trashProvider.initialize(),
                  );
                }
                
                return TabBarView(
                  controller: _tabController,
                  children: [
                    // All items tab
                    _buildTrashItemsList(
                      context,
                      trashProvider.allTrashItems,
                      'No items in trash',
                    ),
                    
                    // Personnel tab
                    _buildTrashItemsList(
                      context,
                      trashProvider.personnelTrashItems,
                      'No personnel in trash',
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildTrashItemsList(
    BuildContext context,
    List<TrashItem> trashItems,
    String emptyMessage,
  ) {
    if (trashItems.isEmpty) {
      return EmptyState(
        icon: Icons.delete_outline,
        message: emptyMessage,
      );
    }
    
    return ListView.builder(
      itemCount: trashItems.length,
      itemBuilder: (context, index) {
        final trashItem = trashItems[index];
        return _buildTrashItemTile(context, trashItem);
      },
    );
  }

  Widget _buildTrashItemTile(BuildContext context, TrashItem trashItem) {
    // Get item details based on entity type
    String title = 'Unknown Item';
    String subtitle = 'Deleted ${trashItem.deletedTimeAgo}';
    Widget? leading;
    
    if (trashItem.entityType == 'personnel') {
      final personnel = trashItem.toPersonnel();
      if (personnel != null) {
        title = '${personnel.fullName} (${personnel.armyNumber})';
        subtitle = 'Deleted ${trashItem.deletedTimeAgo} by ${trashItem.deletedByName}';
        
        // Show personnel photo if available
        if (personnel.photoUrl != null && personnel.photoUrl!.isNotEmpty) {
          leading = CircleAvatar(
            backgroundImage: AssetImage(personnel.photoUrl!),
            onBackgroundImageError: (_, __) => const Icon(Icons.person),
          );
        } else {
          leading = const CircleAvatar(child: Icon(Icons.person));
        }
      }
    }
    
    return Dismissible(
      key: Key(trashItem.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.restore, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Restore
          await _restorePersonnel(context, trashItem);
          return true;
        } else {
          // Delete permanently
          await _permanentlyDeleteTrashItem(context, trashItem);
          return true;
        }
      },
      child: ListTile(
        leading: leading ?? const Icon(Icons.delete_outline),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Restore',
              onPressed: () => _restorePersonnel(context, trashItem),
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Permanently',
              onPressed: () => _permanentlyDeleteTrashItem(context, trashItem),
            ),
          ],
        ),
      ),
    );
  }
}
