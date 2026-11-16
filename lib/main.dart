import 'package:flutter/material.dart';
import 'package:graphics/graphics.dart';
import 'package:services/services.dart';

import 'presentation/main_shell/marg_shell.screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.instance.initFromDisk();
  runApp(const DealerConnectApp());
}

class DealerConnectApp extends StatelessWidget {
  const DealerConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GraphicsStringConsts.appTitle,
      debugShowCheckedModeBanner: false,
      theme: GraphicsTheme.darkTheme,
      home: const MargShellScreen(),
    );
  }
}
