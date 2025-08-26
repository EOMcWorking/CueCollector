import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/cue.dart';
import '../models/asset.dart';
import '../models/activity.dart';
import '../services/database_service.dart';

class DataProvider extends ChangeNotifier {
  List<Person> _people = [];
  Person? _selectedPerson;
  List<Cue> _cues = [];
  List<Asset> _assets = [];
  List<Activity> _activities = [];
  
  List<Person> get people => _people;
  Person? get selectedPerson => _selectedPerson;
  List<Cue> get cues => _cues;
  List<Asset> get assets => _assets;
  List<Activity> get activities => _activities;

  Future<void> loadPeople() async {
    _people = await DatabaseService.instance.getAllPeople();
    notifyListeners();
  }

  Future<void> addPerson(String name) async {
    final person = Person(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await DatabaseService.instance.createPerson(person);
    await loadPeople();
  }

  Future<void> selectPerson(String personId) async {
    _selectedPerson = await DatabaseService.instance.getPerson(personId);
    if (_selectedPerson != null) {
      await loadPersonData(personId);
    }
    notifyListeners();
  }

  Future<void> loadPersonData(String personId) async {
    _cues = await DatabaseService.instance.getCuesForPerson(personId);
    _assets = await DatabaseService.instance.getAssetsForPerson(personId);
    _activities = await DatabaseService.instance.getActivitiesForPerson(personId);
    notifyListeners();
  }

  Future<void> addCue(String personId, CueType type, String content, {String? audioPath}) async {
    final cue = Cue(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      personId: personId,
      type: type,
      content: content,
      audioPath: audioPath,
      createdAt: DateTime.now(),
    );
    
    await DatabaseService.instance.createCue(cue);
    await loadPersonData(personId);
  }

  Future<void> addAsset(String personId, String name, AssetStatus status, {double? totalAmount}) async {
    final asset = Asset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      personId: personId,
      name: name,
      status: status,
      progress: status == AssetStatus.owned ? 100.0 : 0.0,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
    );
    
    await DatabaseService.instance.createAsset(asset);
    await loadPersonData(personId);
  }

  Future<void> updateAssetProgress(String assetId, double progress) async {
    final asset = _assets.firstWhere((a) => a.id == assetId);
    final updatedAsset = Asset(
      id: asset.id,
      personId: asset.personId,
      name: asset.name,
      status: asset.status,
      progress: progress,
      totalAmount: asset.totalAmount,
      currentAmount: asset.totalAmount != null ? (asset.totalAmount! * progress / 100) : 0,
      createdAt: asset.createdAt,
    );
    
    await DatabaseService.instance.updateAsset(updatedAsset);
    await loadPersonData(asset.personId);
  }

  Future<void> addActivity(String personId, String name) async {
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      personId: personId,
      name: name,
      createdAt: DateTime.now(),
    );
    
    await DatabaseService.instance.createActivity(activity);
    await loadPersonData(personId);
  }

  Future<void> setCurrentActivity(String personId, String activityId) async {
    await DatabaseService.instance.setCurrentActivity(personId, activityId);
    await loadPersonData(personId);
  }
}
