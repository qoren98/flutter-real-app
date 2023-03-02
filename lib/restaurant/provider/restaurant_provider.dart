import 'package:flutter_real_app/common/model/cursor_pagination_model.dart';
import 'package:flutter_real_app/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationModelBase>(
        (ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);
  return notifier;
});

class RestaurantStateNotifier extends StateNotifier<CursorPaginationModelBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationModelLoading()) {
    paginate();
  }

  // fetchMore : true - 추가로 데이터 더 가져오기
  // fetchMore : false - 새로 고침(현재 상태를 덮어씀)
  // forceRefetch : true
  // -> 강제로 다시 초기 상태로 돌려 CursorPaginationModelLoading을 실행함
  void paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    bool forceRefetch = false,
  }) async {
    // 5가지 가능
    // State의 상태
    // 1) CursorPaginationModel - 정상적으로 데이터가 있는 상태
    // 2) CursorPaginationModelLoading - 데이터가 로딩 중인 상태(현재 데이터가 캐시에 없음)
    // 3) CursorPaginationModelError - 에러가 발생한 상태
    // 4) CursorPaginationModelRefetching - 첫번째 페이지부터 다시 데이터를 가져올 때
    // 5) CursorPaginationModelFetchMore - 추가 데이터를 paginate 해 오라는 명령을 받았을 때

    // 바로 반환하는 상황
    // 1) hasMore = false 인 상태 - 기존 상태에서 이미 다음 데이터가 없다는 것을 알고 있다.
    // 2) 로딩 중일 때 - fetchMore : true
    //                 fetchMore : false -> 새로 고침의 의도가 있는 때다.

    if (state is CursorPaginationModel && !forceRefetch) {
      final pState = state as CursorPaginationModel;

      if (!pState.meta.hasMore) {
        return;
      }
    }
  }
}
