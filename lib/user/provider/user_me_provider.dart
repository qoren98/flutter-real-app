import 'package:flutter_real_app/common/const/data.dart';
import 'package:flutter_real_app/user/model/user_model.dart';
import 'package:flutter_real_app/user/repository/user_me_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {
  final UserMeRepository repository;
  final FlutterSecureStorage storage;

  UserMeStateNotifier({
    required this.repository,
    required this.storage,
  }) : super(UserModelLoading()) {
    getMe();
  }

  getMe() async {
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    if (refreshToken == null || accessToken == null) {
      return;
    }

    await repository.getMe();
  }
}
