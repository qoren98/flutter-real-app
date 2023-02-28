import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

abstract class CursorPaginationModelBase {}

class CursorPaginationModelError extends CursorPaginationModelBase {
  final String message;
  CursorPaginationModelError({
    required this.message,
  });
}

class CursorPaginationModelLoading extends CursorPaginationModelBase {}

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

  factory CursorPaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaModelFromJson(json);
}

class CursorPaginationModelRefetching extends CursorPaginationModel {
  CursorPaginationModelRefetching({
    required super.meta,
    required super.data,
  });
}
