part of 'task_bloc.dart';

@freezed
class TaskState with _$TaskState {
  const factory TaskState({List<Task>? tasks}) = _TaskState;
  // get and setter for tasks
  const TaskState._();
  int get taskCount => tasks?.length ?? 0;
  String get completedTaskCount {
    int count = tasks?.where((task) => task.status == TaskStatus.completed).length ?? 0;
    if (count == 0) return '';
    return "($count)";
  }

  String get pendingTaskCount {
    int count = tasks?.where((task) => task.status == TaskStatus.pending).length ?? 0;
    if (count == 0) return '';
    return "($count)";
  }

  String get totalTaskCount {
    int count = tasks?.length ?? 0;
    if (count == 0) return '';
    return "($count)";
  }

  List<Task> get completedTasks => tasks?.where((task) => task.status == TaskStatus.completed).toList() ?? [];
  List<Task> get pendingTasks => tasks?.where((task) => task.status == TaskStatus.pending).toList() ?? [];
}
