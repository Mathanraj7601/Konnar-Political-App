import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "config/app_config.dart";
import "providers/auth_provider.dart";
import "screens/splash_screen.dart";
import "services/api_client.dart";
import "services/auth_service.dart";
import "services/local_storage_service.dart";
import "services/mock_api_client.dart";
import "services/user_service.dart";
import "theme/app_theme.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ApiClient apiClient = AppConfig.useMockBackend
      ? MockApiClient()
      : ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authService: AuthService(apiClient),
            userService: UserService(apiClient),
            localStorageService: LocalStorageService(),
          )..initializeSession(),
        ),
      ],
      child: const KonnarApp(),
    ),
  );
}

class KonnarApp extends StatelessWidget {
  const KonnarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ss natha konnar",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
