import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/data_provider.dart';
import '../models/asset.dart';
import 'add_asset_dialog.dart';

class AssetsSection extends StatelessWidget {
  final String personId;

  const AssetsSection({
    super.key,
    required this.personId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final assets = dataProvider.assets;

        return Column(
          children: [
            Expanded(
              child: assets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No assets added yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first asset',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        return AssetCard(
                          asset: asset,
                          onProgressUpdate: (progress) {
                            dataProvider.updateAssetProgress(asset.id, progress);
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddAssetDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Asset'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddAssetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddAssetDialog(personId: personId),
    );
  }
}

class AssetCard extends StatelessWidget {
  final Asset asset;
  final Function(double) onProgressUpdate;

  const AssetCard({
    super.key,
    required this.asset,
    required this.onProgressUpdate,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    switch (asset.status) {
      case AssetStatus.yetToAcquire:
        statusColor = Colors.red;
        statusLabel = 'Yet to acquire';
        break;
      case AssetStatus.onEmi:
        statusColor = Colors.orange;
        statusLabel = 'On EMI';
        break;
      case AssetStatus.owned:
        statusColor = Colors.green;
        statusLabel = 'Owned';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    asset.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (asset.totalAmount != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current: ₹${asset.currentAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Total: ₹${asset.totalAmount!.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 64,
              lineHeight: 20.0,
              percent: asset.progress / 100,
              center: Text(
                '${asset.progress.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.grey[300],
              progressColor: statusColor,
              barRadius: const Radius.circular(10),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Added ${_formatDate(asset.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                if (asset.status != AssetStatus.owned)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showProgressDialog(context),
                    tooltip: 'Update Progress',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context) {
    final progressController = TextEditingController(
      text: asset.progress.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Progress - ${asset.name}'),
        content: TextField(
          controller: progressController,
          decoration: const InputDecoration(
            labelText: 'Progress (%)',
            border: OutlineInputBorder(),
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final progress = double.tryParse(progressController.text);
              if (progress != null && progress >= 0 && progress <= 100) {
                onProgressUpdate(progress);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
