import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final bool loading;
  final Widget child;

  const AppLoading({super.key, required this.loading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

