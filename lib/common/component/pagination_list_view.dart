import 'package:flutter/material.dart';
import 'package:flutter_real_app/common/model/cursor_pagination_model.dart';
import 'package:flutter_real_app/common/model/model_with_id.dart';
import 'package:flutter_real_app/common/provider/pagination_provider.dart';
import 'package:flutter_real_app/common/utils/pagination_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PaginationWidgetBuilder<T extends IModelWithId> = Widget Function(
  BuildContext context,
  int index,
  T model,
);

class PaginationListView<T extends IModelWithId>
    extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationProvider, CursorPaginationModelBase>
      provider;
  final PaginationWidgetBuilder<T> itemBuilder;

  const PaginationListView({
    required this.provider,
    required this.itemBuilder,
    super.key,
  });

  @override
  ConsumerState<PaginationListView> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends IModelWithId>
    extends ConsumerState<PaginationListView> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
  }

  void scrollListener() {
    // 현재 위치가 최대 길이보다 조금 덜되는 위치까지 왔다면
    // 새로운 데이터를 추가 요청
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(widget.provider.notifier),
    );
  }

  @override
  void dispose() {
    controller.removeListener(scrollListener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    // 완전 처음 로딩 상태일 경우
    if (state is CursorPaginationModelLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러 상태일 경우
    if (state is CursorPaginationModelError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16.0,
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(widget.provider.notifier).paginate(
                    forceRefetch: true,
                  );
            },
            child: const Text("다시 시도"),
          ),
        ],
      );
    }

    // 위 두 경우가 아니면 데이터가 있는 세가지 상태
    // CursorPaginationModel / CursorPaginationModelFetching / CursorPaginationModelRefetching
    final cp = state as CursorPaginationModel<T>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        controller: controller,
        itemCount: cp.data.length + 1,
        itemBuilder: (_, index) {
          if (index == cp.data.length) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: cp is CursorPaginationModelFetchingMore
                    ? const CircularProgressIndicator()
                    : const Text("마지막 데이터입니다."),
              ),
            );
          }

          final item = cp.data[index];
          return widget.itemBuilder(context, index, item);
        },
        separatorBuilder: (_, index) {
          return const SizedBox(
            height: 16.0,
          );
        },
      ),
    );
  }
}
