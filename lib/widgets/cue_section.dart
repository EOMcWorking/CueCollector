import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/cue.dart';
import 'add_cue_dialog.dart';
import 'voice_recorder_widget.dart';

class CueSection extends StatelessWidget {
  final String personId;

  const CueSection({
    super.key,
    required this.personId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final cues = dataProvider.cues;

        return Scaffold(
          body: Column(
            children: [
              // Voice Recording Controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: VoiceRecorderWidget(personId: personId),
              ),
              // Cue Cards
              Expanded(
                child: cues.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No cues added yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your first cue',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cues.length,
                        itemBuilder: (context, index) {
                          final cue = cues[index];
                          return CueCard(cue: cue);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddCueDialog(context, personId),
            child: const Icon(Icons.add),
            tooltip: 'Add Cue',
          ),
        );
      },
    );
  }

  void _showAddCueDialog(BuildContext context, String personId) {
    showDialog(
      context: context,
      builder: (context) => AddCueDialog(personId: personId),
    );
  }
}

class CueCard extends StatelessWidget {
  final Cue cue;

  const CueCard({
    super.key,
    required this.cue,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    String typeLabel;

    switch (cue.type) {
      case CueType.conscious:
        cardColor = Colors.blue;
        typeLabel = 'Conscious';
        break;
      case CueType.subconscious:
        cardColor = Colors.grey;
        typeLabel = 'Subconscious';
        break;
      case CueType.unconscious:
        cardColor = const Color(0xFF6A0DAD); // Deep Violet
        typeLabel = 'Unconscious';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    typeLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (cue.audioPath != null)
                  Icon(
                    Icons.mic,
                    color: cardColor,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              cue.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(cue.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
