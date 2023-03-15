import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

// CursorPaginationModel 객체의 각 상태를 확인할 수 있는
// 연관 객체들을 생성해 준다.

// CursorPaginationModel 객체의 추상 클래스로
// CursorPaginationModel에 데이터가 없을 경우
// CursorPaginationModel is CursorPaginationModelBase 값이 true가 된다.
abstract class CursorPaginationModelBase {}

// CursorPaginationModel에 에러가 발생했을 때 처리해 줄 에러 객체
class CursorPaginationModelError extends CursorPaginationModelBase {
  final String message;
  CursorPaginationModelError({
    required this.message,
  });
}

// CursorPaginationModel에 아직 데이터가 채워지지 않아
// Loading 표시를 해 줘야할 때 사용할 객체
class CursorPaginationModelLoading extends CursorPaginationModelBase {}

// CursorPaginationModel를 새로 고침하여 데이터를 다시 불러올 때 사용
class CursorPaginationModelRefetching<T> extends CursorPaginationModel<T> {
  CursorPaginationModelRefetching({
    required super.meta,
    required super.data,
  });
}

// 리스트의 맨 아래로 스크롤되었을 때
// 추가 데이터를 요청하는 중임을 체크할 때 사용
class CursorPaginationModelFetchingMore<T> extends CursorPaginationModel<T> {
  CursorPaginationModelFetchingMore({
    required super.meta,
    required super.data,
  });
}

@JsonSerializable(
  genericArgumentFactories: true,
)
class CursorPaginationModel<T> extends CursorPaginationModelBase {
  final CursorPaginationMetaModel meta;
  final List<T> data;

  CursorPaginationModel({
    required this.meta,
    required this.data,
  });

  CursorPaginationModel copyWith({
    CursorPaginationMetaModel? meta,
    List<T>? data,
  }) {
    return CursorPaginationModel<T>(
      meta: meta ?? this.meta,
      data: data ?? this.data,
    );
  }

  factory CursorPaginationModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$CursorPaginationModelFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMetaModel {
  final int count;
  final bool hasMore;

  CursorPaginationMetaModel({
    required this.count,
    required this.hasMore,
  });

  CursorPaginationMetaModel copyWith({
    int? count,
    bool? hasMore,
  }) {
    return CursorPaginationMetaModel(
      count: count ?? this.count,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory CursorPaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaModelFromJson(json);
}
