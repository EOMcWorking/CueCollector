import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/asset.dart';

class AddAssetDialog extends StatefulWidget {
  final String personId;

  const AddAssetDialog({
    super.key,
    required this.personId,
  });

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AssetStatus _selectedStatus = AssetStatus.yetToAcquire;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addAsset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final totalAmount = _amountController.text.isNotEmpty
          ? double.tryParse(_amountController.text)
          : null;

      await Provider.of<DataProvider>(context, listen: false).addAsset(
        widget.personId,
        _nameController.text.trim(),
        _selectedStatus,
        totalAmount: totalAmount,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding asset: $e'),
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
    return AlertDialog(
      title: const Text('Add New Asset'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Asset Name',
                hintText: 'e.g., Car, House, Laptop',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter asset name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Status:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<AssetStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: AssetStatus.values.map((status) {
                Color color;
                String label;
                switch (status) {
                  case AssetStatus.yetToAcquire:
                    color = Colors.red;
                    label = 'Yet to acquire';
                    break;
                  case AssetStatus.onEmi:
                    color = Colors.orange;
                    label = 'On EMI';
                    break;
                  case AssetStatus.owned:
                    color = Colors.green;
                    label = 'Owned';
                    break;
                }
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Total Amount (Optional)',
                hintText: 'e.g., 500000',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addAsset,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
