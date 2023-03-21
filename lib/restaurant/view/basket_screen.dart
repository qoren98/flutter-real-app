import 'package:flutter/material.dart';
import 'package:flutter_real_app/common/layout/default_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasketScreen extends ConsumerWidget {
  static String get routeName => 'basket';
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultLayout(
      title: "장바구니",
      child: Column(
        children: const [
          Text("data"),
        ],
      ),
    );
  }
}
