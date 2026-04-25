import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/hunt_game_state.dart';
import 'services/audio_service.dart';
import 'screens/root_router_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    print("ERROR: ${details.exception}");
  };

  runApp(const SpeurtochtApp());
}

class SpeurtochtApp extends StatelessWidget {
  const SpeurtochtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HuntGameState()..hydrate(),
      child: Consumer<HuntGameState>(
        builder: (context, game, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'KZ Speurtocht',
            theme: game.themeData,
            home: const RootRouterScreen(),
          );
        },
      ),
    );
  }
}