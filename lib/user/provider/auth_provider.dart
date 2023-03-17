import 'package:flutter/widgets.dart';
import 'package:flutter_real_app/common/view/root_tab.dart';
import 'package:flutter_real_app/common/view/splash_screen.dart';
import 'package:flutter_real_app/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter_real_app/user/model/user_model.dart';
import 'package:flutter_real_app/user/provider/user_me_provider.dart';
import 'package:flutter_real_app/user/view/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({
    required this.ref,
  }) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          name: RootTab.routeName,
          builder: (_, __) => const RootTab(),
          routes: [
            GoRoute(
              path: 'restaurant/:rid',
              name: RestaurantDetailScreen.routeName,
              builder: (_, state) => RestaurantDetailScreen(
                id: state.params['rid']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (_, __) => const LoginScreen(),
        ),
      ];

  void logout() {
    ref.read(userMeProvider.notifier).logout();
  }

  // SplashScreen
  // 앱을 처음 시작했을 때 토큰이 존재하는지 확인하고
  // 로그인 스크린으로 보내줄지, 홈스크린으로 보내줄 지
  // 확인하는 과정이 필요
  Future<String?> redirectLogic(BuildContext _, GoRouterState state) async {
    final UserModelBase? user = ref.read(userMeProvider);
    final loggingIn = state.location == '/login';

    // =========================
    // user가 null인 경우
    // =========================
    // user 정보가 없는데 로그인 중이라면
    // 그대로 로그인 페이지에 두고
    // 로그인 중이 아니라면
    // 로그인 페이지로 이동
    if (user == null) {
      return loggingIn ? null : '/login';
    }

    // =========================
    // user가 null이 아닌 경우
    // =========================

    // user가 UserModel인 경우
    // 로그인 중이거나 현재 위치가 SlashScreen이면
    // Home으로 이동
    if (user is UserModel) {
      return loggingIn || state.location == '/splash' ? '/' : null;
    }

    // user가 UserModelError일 경우
    if (user is UserModelError) {
      return !loggingIn ? '/' : null;
    }

    return null;
  }
}
