import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: RiceFertileAi()));
}

class RiceFertileAi extends StatelessWidget {
  const RiceFertileAi({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Rice Fertile AI',
      home: HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rice Fertile AI'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Rice Fertile AI',
            ),
          ],
        ),
      ),
    );
  }
}
