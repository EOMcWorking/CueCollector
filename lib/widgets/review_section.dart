import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class ReviewSection extends StatefulWidget {
  final String personId;

  const ReviewSection({
    super.key,
    required this.personId,
  });

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Cue', 'Assets', 'Activity'];

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return Column(
          children: [
            // Filter Options
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Filter:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterOptions.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Charts and Timeline
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Activity Timeline Chart
                    _buildActivityChart(dataProvider),
                    const SizedBox(height: 24),
                    // Asset Progress Chart
                    _buildAssetChart(dataProvider),
                    const SizedBox(height: 24),
                    // Cue Distribution Chart
                    _buildCueChart(dataProvider),
                    const SizedBox(height: 24),
                    // Recent Actions Timeline
                    _buildRecentActions(dataProvider),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityChart(DataProvider dataProvider) {
    final activities = dataProvider.activities;
    
    if (activities.isEmpty) {
      return _buildEmptyChart('No activity data available');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _generateActivitySections(activities),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetChart(DataProvider dataProvider) {
    final assets = dataProvider.assets;
    
    if (assets.isEmpty) {
      return _buildEmptyChart('No asset data available');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < assets.length) {
                            return Text(
                              assets[value.toInt()].name.length > 8
                                  ? '${assets[value.toInt()].name.substring(0, 8)}...'
                                  : assets[value.toInt()].name,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateAssetBars(assets),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCueChart(DataProvider dataProvider) {
    final cues = dataProvider.cues;
    
    if (cues.isEmpty) {
      return _buildEmptyChart('No cue data available');
    }

    final cueTypeCounts = <String, int>{};
    for (final cue in cues) {
      final type = cue.type.name;
      cueTypeCounts[type] = (cueTypeCounts[type] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cue Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _generateCueSections(cueTypeCounts),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActions(DataProvider dataProvider) {
    final recentActions = <Map<String, dynamic>>[];
    
    // Add recent cues
    for (final cue in dataProvider.cues.take(5)) {
      recentActions.add({
        'type': 'Cue',
        'title': cue.content,
        'subtitle': cue.type.name,
        'time': cue.createdAt,
        'icon': Icons.psychology,
        'color': Colors.blue,
      });
    }
    
    // Add recent assets
    for (final asset in dataProvider.assets.take(3)) {
      recentActions.add({
        'type': 'Asset',
        'title': asset.name,
        'subtitle': '${asset.progress.toStringAsFixed(1)}% complete',
        'time': asset.createdAt,
        'icon': Icons.account_balance_wallet,
        'color': Colors.green,
      });
    }
    
    // Add recent activities
    for (final activity in dataProvider.activities.take(3)) {
      recentActions.add({
        'type': 'Activity',
        'title': activity.name,
        'subtitle': activity.isCurrent ? 'Currently active' : 'Inactive',
        'time': activity.createdAt,
        'icon': Icons.directions_run,
        'color': Colors.orange,
      });
    }
    
    // Sort by time
    recentActions.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recentActions.isEmpty)
              const Center(
                child: Text('No recent actions'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final action = recentActions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: action['color'],
                      child: Icon(
                        action['icon'],
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(action['title']),
                    subtitle: Text(action['subtitle']),
                    trailing: Text(
                      _formatActionTime(action['time']),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateActivitySections(List activities) {
    final Map<String, int> activityCounts = {};
    for (final activity in activities) {
      activityCounts[activity.name] = (activityCounts[activity.name] ?? 0) + 1;
    }

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    int colorIndex = 0;

    return activityCounts.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _generateAssetBars(List assets) {
    return assets.asMap().entries.map((entry) {
      final index = entry.key;
      final asset = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: asset.progress,
            color: _getAssetColor(asset.status),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> _generateCueSections(Map<String, int> cueTypeCounts) {
    final colors = {
      'conscious': Colors.blue,
      'subconscious': Colors.grey,
      'unconscious': const Color(0xFF6A0DAD),
    };

    return cueTypeCounts.entries.map((entry) {
      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getAssetColor(status) {
    switch (status.toString()) {
      case 'AssetStatus.yetToAcquire':
        return Colors.red;
      case 'AssetStatus.onEmi':
        return Colors.orange;
      case 'AssetStatus.owned':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatActionTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
