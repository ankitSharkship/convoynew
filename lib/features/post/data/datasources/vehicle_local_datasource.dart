import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle_model.dart';

abstract class VehicleLocalDataSource {
  Future<List<VehicleModel>> getVehicles();
  Future<void> saveVehicles(List<VehicleModel> vehicles);
}

class VehicleLocalDataSourceImpl implements VehicleLocalDataSource {
  static const _key = 'user_vehicles';
  final SharedPreferences _prefs;

  VehicleLocalDataSourceImpl(this._prefs);

  @override
  Future<List<VehicleModel>> getVehicles() async {
    final stored = _prefs.getStringList(_key);
    if (stored == null || stored.isEmpty) return [];
    return stored
        .map((s) => VehicleModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveVehicles(List<VehicleModel> vehicles) async {
    await _prefs.setStringList(_key, vehicles.map((v) => v.toJsonString()).toList());
  }
}
