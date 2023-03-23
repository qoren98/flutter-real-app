import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_real_app/common/model/cursor_pagination_model.dart';
import 'package:flutter_real_app/common/model/model_with_id.dart';
import 'package:flutter_real_app/common/model/pagination_params.dart';
import 'package:flutter_real_app/common/repository/base_pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _PaginationInfo {
  final int fetchCount;
  final bool fetchMore;
  final bool forceRefetch;

  _PaginationInfo({
    this.fetchCount = 20,
    this.fetchMore = false,
    this.forceRefetch = false,
  });
}

class PaginationProvider<T extends IModelWithId,
        U extends IBasePaginationRepository<T>>
    extends StateNotifier<CursorPaginationModelBase> {
  final U repository;
  final paginationThrottle = Throttle(
    const Duration(seconds: 3),
    initialValue: _PaginationInfo(),
    // 이 값은 연이은 함수의 initialValue가 똑같을 경우
    // 이후 함수는 실행하지 않도록 해 준다.
    checkEquality: false,
  );

  PaginationProvider({
    required this.repository,
  }) : super(CursorPaginationModelLoading()) {
    paginate();
    paginationThrottle.values.listen(
      (state) {
        _throttledPagination(state);
      },
    );
  }

  Future<void> paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    bool forceRefetch = false,
  }) async {
    paginationThrottle.setValue(_PaginationInfo(
      fetchCount: fetchCount,
      fetchMore: fetchMore,
      forceRefetch: forceRefetch,
    ));
  }

  _throttledPagination(_PaginationInfo info) async {
    final fetchCount = info.fetchCount;
    final fetchMore = info.fetchMore;
    final forceRefetch = info.forceRefetch;

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
        final pState = state as CursorPaginationModel<T>;

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
        final pState = state as CursorPaginationModel<T>;

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
          final pState = state as CursorPaginationModel<T>;

          state = CursorPaginationModelRefetching<T>(
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
        final pState = state as CursorPaginationModelFetchingMore<T>;
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
    } catch (e, stack) {
      print(e);
      print(stack);
      state = CursorPaginationModelError(
        message: "데이터를 가져오지 못했습니다.",
      );
    }
  }
}
