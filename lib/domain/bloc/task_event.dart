part of 'task_bloc.dart';

abstract class TaskEvent {
  const TaskEvent();
}

class GetTasksEvent extends TaskEvent {
  const GetTasksEvent();
}

class AddTaskEvent extends TaskEvent {
  final Task task;

  const AddTaskEvent(this.task);
}

class DoneTaskEvent extends TaskEvent {
  final Task task;

  const DoneTaskEvent(this.task);
}
