import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/providers/auth_provider.dart';
import 'package:touch_grass/screens/auth/login_screen.dart';
import 'package:touch_grass/screens/auth/register_screen.dart';
import 'package:touch_grass/screens/home/home_screen.dart';
import 'package:touch_grass/screens/camera/camera_screen.dart';
import 'package:touch_grass/screens/profile/profile_screen.dart';
import 'package:touch_grass/screens/profile/edit_profile_screen.dart';
import 'package:touch_grass/screens/explore/explore_map_screen.dart';
import 'package:touch_grass/screens/hot_pics/hot_pics_screen.dart';
import 'package:touch_grass/screens/friends/friends_list_screen.dart';
import 'package:touch_grass/screens/friends/add_friend_screen.dart';
import 'package:touch_grass/screens/settings/settings_screen.dart';
import 'package:touch_grass/screens/post/post_detail_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggedIn = auth.isLoggedIn;
      final isAuthRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    refreshListenable: _AuthListenable(),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (_, __) => const CameraScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'editProfile',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (_, __) => const ExploreMapScreen(),
      ),
      GoRoute(
        path: '/hot-pics',
        name: 'hotPics',
        builder: (_, __) => const HotPicsScreen(),
      ),
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (_, __) => const FriendsListScreen(),
      ),
      GoRoute(
        path: '/friends/add',
        name: 'addFriend',
        builder: (_, __) => const AddFriendScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/post/:postId',
        name: 'postDetail',
        builder: (_, state) => PostDetailScreen(
          postId: state.pathParameters['postId']!,
        ),
      ),
    ],
  );
}

/// Bridges [AuthProvider] changes to GoRouter's refresh mechanism.
class _AuthListenable extends ChangeNotifier {
  // GoRouter calls redirect on every navigation; using a static redirect
  // that reads provider state directly is sufficient without a listenable.
}
