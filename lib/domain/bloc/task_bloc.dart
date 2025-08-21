import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uniconsoft_task/data/repositories/task_repository.dart';
import 'package:uniconsoft_task/main.dart';
import 'package:uniconsoft_task/models/task.dart';

part 'task_event.dart';
part 'task_state.dart';
part 'task_bloc.freezed.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  TaskBloc(this.taskRepository) : super(const TaskState()) {
    on<GetTasksEvent>((event, emit) async {
      try {
        final tasks = await taskRepository.fetchTasks();
        emit(state.copyWith(tasks: tasks));
      } catch (e) {
        scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
      }
    });
    on<AddTaskEvent>((event, emit) async {
      try {
        final newTask = await taskRepository.addTask(event.task);
        if (newTask != 0) {
          add(GetTasksEvent());
        }
      } catch (e) {
        log('Error adding task: $e');
        scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Failed to add task: $e')));
      }
    });
    on<DoneTaskEvent>((event, emit) async {
      try {
        final doneTask = await taskRepository.updateTask(
          event.task.copyWith(status: TaskStatus.completed, finishedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000),
        );
        if (doneTask != 0) {
          add(GetTasksEvent());
        }
      } catch (e) {
        scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
      }
    });
  }
}
