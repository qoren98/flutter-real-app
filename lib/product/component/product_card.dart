import 'package:flutter/material.dart';
import 'package:flutter_real_app/common/const/colors.dart';
import 'package:flutter_real_app/product/model/product_model.dart';
import 'package:flutter_real_app/restaurant/model/restaurant_detail_model.dart';

class ProductCard extends StatelessWidget {
  // final String id;
  final Image img;
  final String name;
  final String detail;
  final int price;

  const ProductCard({
    // required this.id,
    required this.img,
    required this.name,
    required this.detail,
    required this.price,
    super.key,
  });

  factory ProductCard.fromProductModel({
    required ProductModel model,
  }) {
    return ProductCard(
      img: Image.network(
        model.imgUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
      name: model.name,
      detail: model.detail,
      price: model.price,
    );
  }

  factory ProductCard.fromRestaurantProductModel({
    required RestaurantProductModel model,
  }) {
    return ProductCard(
      img: Image.network(
        model.imgUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
      name: model.name,
      detail: model.detail,
      price: model.price,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
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
    );
  }
}
