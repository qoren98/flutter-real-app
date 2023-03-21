import 'package:flutter/material.dart';
import 'package:flutter_real_app/common/const/colors.dart';
import 'package:flutter_real_app/product/model/product_model.dart';
import 'package:flutter_real_app/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_real_app/user/provider/basket_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCard extends ConsumerWidget {
  final String id;
  final Image img;
  final String name;
  final String detail;
  final int price;
  final VoidCallback? onSubstract;
  final VoidCallback? onAdd;

  const ProductCard({
    required this.id,
    required this.img,
    required this.name,
    required this.detail,
    required this.price,
    this.onAdd,
    this.onSubstract,
    super.key,
  });

  factory ProductCard.fromProductModel({
    required ProductModel model,
    VoidCallback? onSubstract,
    VoidCallback? onAdd,
  }) {
    return ProductCard(
      id: model.id,
      img: Image.network(
        model.imgUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
      name: model.name,
      detail: model.detail,
      price: model.price,
      onSubstract: onSubstract,
      onAdd: onAdd,
    );
  }

  factory ProductCard.fromRestaurantProductModel({
    required RestaurantProductModel model,
    VoidCallback? onSubstract,
    VoidCallback? onAdd,
  }) {
    return ProductCard(
      id: model.id,
      img: Image.network(
        model.imgUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
      name: model.name,
      detail: model.detail,
      price: model.price,
      onSubstract: onSubstract,
      onAdd: onAdd,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket = ref.watch(basketProvider);

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: img,
              ),
              const SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BODY_TEXT_COLOR,
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      '${price.toString()}원',
                      style: const TextStyle(
                        color: PRIMARY_COLOR,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        if (onSubstract != null && onAdd != null)
          _Footer(
            total: basket.isNotEmpty
                ? (basket.firstWhere((e) => e.product.id == id).count *
                        basket
                            .firstWhere((e) => e.product.id == id)
                            .product
                            .price)
                    .toString()
                : "0",
            count: basket.isNotEmpty
                ? basket.firstWhere((e) => e.product.id == id).count
                : 0,
            onAdd: onAdd!,
            onSubstract: onSubstract!,
          ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final String total;
  final int count;
  final VoidCallback onSubstract;
  final VoidCallback onAdd;

  const _Footer({
    required this.total,
    required this.count,
    required this.onAdd,
    required this.onSubstract,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '총액 ₩$total',
            style: const TextStyle(
              color: PRIMARY_COLOR,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            renderButton(
              icon: Icons.remove,
              onTap: onSubstract,
            ),
            Text(
              count.toString(),
              style: const TextStyle(
                color: PRIMARY_COLOR,
                fontWeight: FontWeight.w500,
              ),
            ),
            renderButton(
              icon: Icons.add,
              onTap: onAdd,
            ),
          ],
        ),
      ],
    );
  }

  Widget renderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          color: PRIMARY_COLOR,
        ),
      ),
    );
  }
}
