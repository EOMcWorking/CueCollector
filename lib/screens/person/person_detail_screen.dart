import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/cue_section.dart';
import '../../widgets/assets_section.dart';
import '../../widgets/activity_section.dart';
import '../../widgets/review_section.dart';
import '../../widgets/numeric_input_dialog.dart';

class PersonDetailScreen extends StatefulWidget {
  final String personId;

  const PersonDetailScreen({
    super.key,
    required this.personId,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false)
          .selectPerson(widget.personId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final person = dataProvider.selectedPerson;
        
        if (person == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(person.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _showNumericInputDialog(context),
                tooltip: 'Add Numeric Input',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.psychology),
                  text: 'Cue',
                ),
                Tab(
                  icon: Icon(Icons.account_balance_wallet),
                  text: 'Assets',
                ),
                Tab(
                  icon: Icon(Icons.directions_run),
                  text: 'Activity',
                ),
                Tab(
                  icon: Icon(Icons.timeline),
                  text: 'Review',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              CueSection(personId: widget.personId),
              AssetsSection(personId: widget.personId),
              ActivitySection(personId: widget.personId),
              ReviewSection(personId: widget.personId),
            ],
          ),
        );
      },
    );
  }

  void _showNumericInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NumericInputDialog(personId: widget.personId),
    );
  }
}
