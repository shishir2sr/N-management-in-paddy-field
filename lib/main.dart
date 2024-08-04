import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';

void main() {
  runApp(ProviderScope(
    observers: [LogProviderObserver()],
    child: const RiceFertileAi(),
  ));
}

class RiceFertileAi extends StatelessWidget {
  const RiceFertileAi({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RiceFertile AI',
      home: LoaderOverlay(child: HomePage()),
    );
  }
}
