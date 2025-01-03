import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/widget.freezed.dart';

@freezed
class ActivateState with _$ActivateState {
  const factory ActivateState({
    required bool active,
  }) = _ActivateState;
}
