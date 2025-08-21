import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    int? id,
    required String title,
    String? description,
    required TaskStatus status,
    int? createdAt,
    int? finishedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

@JsonEnum(alwaysCreate: true)
enum TaskStatus {
  @JsonValue(0)
  pending(0),
  @JsonValue(1)
  completed(1);

  final int value;

  const TaskStatus(this.value);
}
