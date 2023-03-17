import 'package:flutter_real_app/product/model/product_model.dart';
import 'package:flutter_real_app/user/model/basket_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasketProvider extends StateNotifier<List<BasketItemModel>> {
  BasketProvider() : super([]);

  Future<void> addToBasket({
    required ProductModel product,
  }) {
    // 1) 아직 장바구니에 추가하려는 상품이 없다면,
    //    - 장바구니에 상품을 추가한다.
    // 2) 추가하려는 상품이 이미 있다면
    //    - count만 변경해 준다.
  }
}
