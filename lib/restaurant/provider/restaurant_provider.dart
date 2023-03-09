import 'package:flutter_real_app/common/model/cursor_pagination_model.dart';
import 'package:flutter_real_app/common/provider/pagination_provider.dart';
import 'package:flutter_real_app/restaurant/model/restaurant_model.dart';
import 'package:flutter_real_app/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);
  if (state is! CursorPaginationModel) {
    return null;
  }
  return state.data.firstWhere(
    (element) => element.id == id,
  );
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationModelBase>(
        (ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);
  return notifier;
});

class RestaurantStateNotifier
    extends PaginationProvider<RestaurantModel, RestaurantRepository> {
  RestaurantStateNotifier({
    required super.repository,
  });

  void getDetail({required String id}) async {
    // 만약에 아직 데이터가 하나도 없는 상태라면(CursorPagination이 아니라면)
    // 데이터를 가져오는 시도를 한다.
    if (state is! CursorPaginationModel) {
      await paginate();
    }
    // 위에서 페이지를 가져 오는 함수를 실행했는데도
    // state가 CursorPagination이 아닐 때는 그냥 리턴
    if (state is! CursorPaginationModel) {
      return;
    }
    // 여기까지 코드가 실행되면 우리가 가진 데이터가
    // CursorPaginationModel임을 확신할 수 있다.
    // pstate.data가 [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]이라고 하면,
    // getDetail(id: 2)라는 함수를 실행하면
    // [RestaurantModel(1), RestaurantDetailModel(2), RestaurantModel(3)]로 반환된다.
    final pState = state as CursorPaginationModel;
    final resp = await repository.getRestaurantDetail(id: id);
    state = pState.copyWith(
      data: pState.data
          .map<RestaurantModel>((e) => e.id == id ? resp : e)
          .toList(),
    );
  }
}
