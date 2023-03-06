import 'package:flutter_real_app/common/model/cursor_pagination_model.dart';
import 'package:flutter_real_app/common/model/pagination_params.dart';
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
  Future<void> paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    bool forceRefetch = false,
  }) async {
    try {
// ----------------------
      // 5가지 가능
      // State의 상태
      // 1) CursorPaginationModel - 정상적으로 데이터가 있는 상태
      // 2) CursorPaginationModelLoading - 데이터가 로딩 중인 상태(현재 데이터가 캐시에 없음)
      // 3) CursorPaginationModelError - 에러가 발생한 상태
      // 4) CursorPaginationModelRefetching - 첫번째 페이지부터 다시 데이터를 가져올 때
      // 5) CursorPaginationModelFetchMore - 추가 데이터를 paginate 해 오라는 명령을 받았을 때
      // ----------------------

      // 1. 데이터 없이 바로 반환하는 상황
      //    1) hasMore = false 인 상태 - 기존 상태에서 이미 다음 데이터가 없다는 것을 알고 있다.
      if (state is CursorPaginationModel && !forceRefetch) {
        final pState = state as CursorPaginationModel;

        if (!pState.meta.hasMore) {
          return;
        }
      }
      //    2) 로딩 중일 때 - fetchMore : true
      //                    fetchMore : false -> 새로 고침의 의도가 있을 수 있다.
      final isLoading = state is CursorPaginationModelLoading;
      final isRefetching = state is CursorPaginationModelRefetching;
      final isFetchingMore = state is CursorPaginationModelFetchingMore;

      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }
      // 2. 데이터를 반환해야 하는 상황
      //    이제는 PaginationParams 값을 넣어 주어야 한다.
      //    현재 확정적으로 알 수 있는 paginationParams.count 값을 먼저 설정해 준다.
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );
      //  1) fetchMore:true로 데이터를 추가적으로 더 가져오는 상황
      //    - 현재 state 상태가 데이터를 가지고 있는 CursorPaginationModel임을 확신할 수 있기 때문에
      //    - state의 타입을 CursorPaginationModelFetchingMore로 캐스팅 해 주고
      //    - paginationParams의 after에 현재 데이터 중 가장 마지막 데이터의 id 값을 넣어 줄 수 있다.
      if (fetchMore) {
        final pState = state as CursorPaginationModel;

        state = CursorPaginationModelFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
        // 데이터를 가져오는 상황
      } else {
        // 만약에 데이터가 있는 상황이라면
        // 기존 데이터를 보존한 채로 Fetch(API 요청)를 진행
        if (state is CursorPaginationModel && !forceRefetch) {
          final pState = state as CursorPaginationModel;

          state = CursorPaginationModelRefetching(
            meta: pState.meta,
            data: pState.data,
          );
        } else {
          // 데이터가 없고 강제 fetching이 아니라면
          // 단순한 로딩 상태가 됨
          state = CursorPaginationModelLoading();
        }
      }

      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );

      // 기존 데이터에 새로운 데이터 추가
      if (state is CursorPaginationModelFetchingMore) {
        final pState = state as CursorPaginationModelFetchingMore;
        state = resp.copyWith(
          data: [
            ...pState.data,
            ...resp.data,
          ],
        );
        // state가 CursorPaginationModelLoading이거나
        // CursorPaginationModelRefetching이면
      } else {
        // 기존 데이터를 그대로 보여주면 됨
        state = resp;
      }
    } catch (e) {
      state = CursorPaginationModelError(
        message: "데이터를 가져오지 못했습니다.",
      );
    }
  }

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
