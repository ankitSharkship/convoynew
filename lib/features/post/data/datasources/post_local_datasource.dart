import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  Future<PostModel> submitPost({
    required String truckType,
    required String capacity,
    required String origin,
    required String destination,
    required String vehicleNumber,
  });
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  static const _postsKey = 'posted_trucks';
  final SharedPreferences _prefs;

  PostLocalDataSourceImpl(this._prefs);

  @override
  Future<PostModel> submitPost({
    required String truckType,
    required String capacity,
    required String origin,
    required String destination,
    required String vehicleNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final post = PostModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      truckType: truckType,
      capacity: capacity,
      origin: origin,
      destination: destination,
      vehicleNumber: vehicleNumber,
      createdAt: DateTime.now(),
    );

    final existing = _prefs.getStringList(_postsKey) ?? [];
    existing.add(post.toJsonString());
    await _prefs.setStringList(_postsKey, existing);

    return post;
  }
}
