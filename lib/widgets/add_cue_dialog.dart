import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/cue.dart';

class AddCueDialog extends StatefulWidget {
  final String personId;

  const AddCueDialog({
    super.key,
    required this.personId,
  });

  @override
  State<AddCueDialog> createState() => _AddCueDialogState();
}

class _AddCueDialogState extends State<AddCueDialog> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  CueType _selectedType = CueType.conscious;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _addCue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<DataProvider>(context, listen: false).addCue(
        widget.personId,
        _selectedType,
        _contentController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cue added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding cue: $e'),
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
      title: const Text('Add New Cue'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cue Type:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<CueType>(
              value: _selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: CueType.values.map((type) {
                Color color;
                String label;
                switch (type) {
                  case CueType.conscious:
                    color = Colors.blue;
                    label = 'Conscious';
                    break;
                  case CueType.subconscious:
                    color = Colors.grey;
                    label = 'Subconscious';
                    break;
                  case CueType.unconscious:
                    color = const Color(0xFF6A0DAD);
                    label = 'Unconscious';
                    break;
                }
                return DropdownMenuItem(
                  value: type,
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
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Cue Content',
                hintText: 'Describe the cue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter cue content';
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
          onPressed: _isLoading ? null : _addCue,
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
