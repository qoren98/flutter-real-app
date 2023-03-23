// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_real_app/common/const/colors.dart';
import 'package:flutter_real_app/common/layout/default_layout.dart';
import 'package:flutter_real_app/order/provider/order_provider.dart';
import 'package:flutter_real_app/order/view/order_done_scree.dart';
import 'package:flutter_real_app/product/component/product_card.dart';
import 'package:flutter_real_app/user/provider/basket_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BasketScreen extends ConsumerWidget {
  static String get routeName => 'basket';
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket = ref.watch(basketProvider);

    if (basket.isEmpty) {
      return const DefaultLayout(
        title: '장바구니',
        child: Center(
          child: Text('장바구니가 비었습니다!'),
        ),
      );
    }

    final priceTotal = basket.fold<int>(
      0,
      (previous, next) => previous + (next.product.price * next.count),
    );
    final deliveryFee = basket.first.product.restaurant.deliveryFee;

    return DefaultLayout(
      title: "장바구니",
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (_, index) {
                    return const Divider(
                      height: 32.0,
                    );
                  },
                  itemBuilder: (_, index) {
                    final model = basket[index];
                    return ProductCard.fromProductModel(
                      model: model.product,
                      onAdd: () {
                        ref
                            .read(
                              basketProvider.notifier,
                            )
                            .addToBasket(
                              product: model.product,
                            );
                      },
                      onSubstract: () {
                        ref
                            .read(
                              basketProvider.notifier,
                            )
                            .removeFromBasket(
                              product: model.product,
                            );
                      },
                    );
                  },
                  itemCount: basket.length,
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '장바구니 금액',
                        style: TextStyle(
                          color: BODY_TEXT_COLOR,
                        ),
                      ),
                      Text(
                        "$priceTotal원",
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '배달비',
                        style: TextStyle(
                          color: BODY_TEXT_COLOR,
                        ),
                      ),
                      if (basket.isNotEmpty)
                        Text(
                          "$deliveryFee원",
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총액',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${priceTotal + deliveryFee}원",
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final resp =
                            await ref.read(orderProvider.notifier).postOrder();
                        if (resp) {
                          context.goNamed(OrderDoneScreen.routeName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('결제를 실패하였습니다.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                      child: const Text(
                        '결제하기',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
