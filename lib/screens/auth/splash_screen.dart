import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/index.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            GoRouter.of(context).go('/');
          },
        ),
      ),
      body: const Column(
        children: [
          Center(
            child: ScreenTitle(
              title: 'Welcome',
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
