part of 'task_bloc.dart';

abstract class TaskEvent {
  const TaskEvent();
}

class GetTasksEvent extends TaskEvent {
  const GetTasksEvent();
}
