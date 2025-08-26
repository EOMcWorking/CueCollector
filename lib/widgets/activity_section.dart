import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/activity.dart';
import 'add_activity_dialog.dart';

class ActivitySection extends StatelessWidget {
  final String personId;

  const ActivitySection({
    super.key,
    required this.personId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final activities = dataProvider.activities;
        final currentActivity = activities.where((a) => a.isCurrent).firstOrNull;

        return Column(
          children: [
            if (currentActivity != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentActivity.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentActivity.startedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Started: ${_formatTime(currentActivity.startedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            Expanded(
              child: activities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_run_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No activities added yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first activity',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return ActivityCard(
                          activity: activity,
                          onTap: () {
                            if (!activity.isCurrent) {
                              dataProvider.setCurrentActivity(personId, activity.id);
                            }
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
                  onPressed: () => _showAddActivityDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Activity'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddActivityDialog(personId: personId),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = activity.isCurrent;
    
    return Card(
      elevation: isCurrent ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent ? Colors.green : Colors.grey[300]!,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isCurrent ? Colors.green[50] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getActivityIcon(activity.name),
                size: 32,
                color: isCurrent ? Colors.green[700] : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                activity.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? Colors.green[700] : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isCurrent) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(String activityName) {
    final name = activityName.toLowerCase();
    if (name.contains('work') || name.contains('office')) {
      return Icons.work;
    } else if (name.contains('exercise') || name.contains('gym') || name.contains('workout')) {
      return Icons.fitness_center;
    } else if (name.contains('eat') || name.contains('meal') || name.contains('food')) {
      return Icons.restaurant;
    } else if (name.contains('sleep') || name.contains('rest')) {
      return Icons.bed;
    } else if (name.contains('study') || name.contains('learn')) {
      return Icons.school;
    } else if (name.contains('read')) {
      return Icons.book;
    } else if (name.contains('music') || name.contains('listen')) {
      return Icons.music_note;
    } else if (name.contains('walk') || name.contains('run')) {
      return Icons.directions_walk;
    } else if (name.contains('drive') || name.contains('travel')) {
      return Icons.directions_car;
    } else {
      return Icons.circle;
    }
  }
}
