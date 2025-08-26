import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/cue.dart';
import '../providers/data_provider.dart';
import '../widgets/add_cue_dialog.dart';
import '../widgets/numeric_input_dialog.dart';

class FloatingWindowService {
  static bool _isOverlayActive = false;
  static String? _currentPersonId;

  static bool get isOverlayActive => _isOverlayActive;

  static Future<bool> requestOverlayPermission() async {
    if (await Permission.systemAlertWindow.isGranted) {
      return true;
    }
    
    final status = await Permission.systemAlertWindow.request();
    return status == PermissionStatus.granted;
  }

  static Future<void> showFloatingWindow({String? personId}) async {
    if (_isOverlayActive) return;

    final hasPermission = await requestOverlayPermission();
    if (!hasPermission) return;

    _currentPersonId = personId;
    _isOverlayActive = true;

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: "Cue Collector",
      overlayContent: 'Quick Access',
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      width: 100,
      height: 100,
    );
  }

  static Future<void> hideFloatingWindow() async {
    if (!_isOverlayActive) return;

    await FlutterOverlayWindow.closeOverlay();
    _isOverlayActive = false;
    _currentPersonId = null;
  }

  static Future<void> toggleFloatingWindow({String? personId}) async {
    if (_isOverlayActive) {
      await hideFloatingWindow();
    } else {
      await showFloatingWindow(personId: personId);
    }
  }
}

// Floating Window Widget
class FloatingWindowWidget extends StatefulWidget {
  const FloatingWindowWidget({super.key});

  @override
  State<FloatingWindowWidget> createState() => _FloatingWindowWidgetState();
}

class _FloatingWindowWidgetState extends State<FloatingWindowWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(_isExpanded ? 12 : 50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isExpanded ? _buildExpandedView() : _buildCollapsedView(),
      ),
    );
  }

  Widget _buildCollapsedView() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 100,
        height: 100,
        child: const Icon(
          Icons.psychology,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Access',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            icon: Icons.psychology,
            label: 'Cue',
            onTap: () => _showCueOptions(),
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.account_balance_wallet,
            label: 'Assets',
            onTap: () => _showNumericInput(),
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.directions_run,
            label: 'Activity',
            onTap: () => _showActivitySelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCueOptions() {
    // Show cue type selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCueTypeButton(CueType.conscious, 'Conscious', Colors.blue),
            const SizedBox(height: 8),
            _buildCueTypeButton(CueType.subconscious, 'Subconscious', Colors.grey),
            const SizedBox(height: 8),
            _buildCueTypeButton(CueType.unconscious, 'Unconscious', const Color(0xFF6A0DAD)),
          ],
        ),
      ),
    );
  }

  Widget _buildCueTypeButton(CueType type, String label, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _addQuickCue(type);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _addQuickCue(CueType type) {
    // Add a quick cue with timestamp
    final personId = FloatingWindowService._currentPersonId ?? _generateTempPersonId();
    final content = 'Quick ${type.name} cue - ${DateTime.now().toString().substring(11, 16)}';
    
    // Here you would typically save to database
    // For now, just show a toast-like message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $content'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNumericInput() {
    // Show simplified numeric input
    showDialog(
      context: context,
      builder: (context) => const SimpleNumericInputDialog(),
    );
  }

  void _showActivitySelector() {
    // Show quick activity selector
    final activities = ['Work', 'Exercise', 'Study', 'Break', 'Meeting'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: activities.map((activity) {
            return ListTile(
              title: Text(activity),
              onTap: () {
                Navigator.pop(context);
                _setCurrentActivity(activity);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _setCurrentActivity(String activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set current activity: $activity'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _generateTempPersonId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// Simplified Numeric Input Dialog for Floating Window
class SimpleNumericInputDialog extends StatefulWidget {
  const SimpleNumericInputDialog({super.key});

  @override
  State<SimpleNumericInputDialog> createState() => _SimpleNumericInputDialogState();
}

class _SimpleNumericInputDialogState extends State<SimpleNumericInputDialog> {
  final _amountController = TextEditingController();
  bool _isPositive = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Input'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isPositive = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPositive ? Colors.green : Colors.grey,
                  ),
                  child: const Text('+'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isPositive = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isPositive ? Colors.red : Colors.grey,
                  ),
                  child: const Text('-'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = _amountController.text;
            if (amount.isNotEmpty) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added: ${_isPositive ? '+' : '-'}$amount'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
