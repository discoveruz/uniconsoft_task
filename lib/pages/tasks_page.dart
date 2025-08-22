import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconsoft_task/domain/bloc/task_bloc.dart';
import 'package:uniconsoft_task/models/task.dart';
import 'package:uniconsoft_task/pages/widgets/task_list.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.deepOrange.shade200, title: Text('Tasks'), centerTitle: true),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tabAlignment: TabAlignment.fill,
                indicatorSize: TabBarIndicatorSize.tab,
                splashBorderRadius: BorderRadius.circular(12),
                indicator: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: <Widget>[
                  Tab(child: Text('All ${state.totalTaskCount}')),
                  Tab(child: Text('Completed ${state.completedTaskCount}')),
                  Tab(child: Text('Pending ${state.pendingTaskCount}')),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    TaskList(
                      onTaskFinished: (task) {
                        if (task.status == TaskStatus.pending) {
                          context.read<TaskBloc>().add(DoneTaskEvent(task));
                        }
                      },
                      tasks: state.tasks ?? [],
                    ),
                    TaskList(onTaskFinished: (task) {}, tasks: state.completedTasks),
                    TaskList(
                      onTaskFinished: (task) {
                        if (task.status == TaskStatus.pending) {
                          context.read<TaskBloc>().add(DoneTaskEvent(task));
                        }
                      },
                      tasks: state.pendingTasks,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  dev.log('Add Task button pressed');
                  final formKey = GlobalKey<FormState>();
                  final TextEditingController taskTitleController = TextEditingController();
                  final TextEditingController taskDescriptionController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Add New Task'),
                        content: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: taskTitleController,
                                validator: (value) {
                                  if (value == null || value.isEmpty || value.trim().isEmpty) {
                                    return 'Task title cannot be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter task title',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: taskDescriptionController,
                                decoration: InputDecoration(
                                  hintText: 'Enter task description',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;

                              return Navigator.pop(context, true);
                            },
                            child: Text('Add Task'),
                          ),
                        ],
                      );
                    },
                  ).then((v) {
                    if (v == true) {
                      final taskTitle = taskTitleController.text.trim();
                      final taskDescription = taskDescriptionController.text.trim();
                      final Task newTask = Task(
                        title: taskTitle,
                        description: taskDescription.isEmpty ? null : taskDescription,
                        status: TaskStatus.pending,
                        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      );
                      dev.log('New task created: ${newTask.toJson()}');
                      context.read<TaskBloc>().add(AddTaskEvent(newTask));
                    }
                  });
                },
                child: Text('Add Task'),
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          MethodChannel channel = MethodChannel('uz.uniconsoft.task/taskstats');
          channel
              .invokeMethod('showTaskStats', [
                {
                  "taskStats": {"totalTasks": 1, "completedTasks": 2, "pendingTasks": 2},
                },
              ])
              .then((value) {
                if (value is Map<String, dynamic>) {
                  dev.log('Task stats: $value');
                } else {
                  dev.log('Unexpected value type: ${value.runtimeType}');
                }
              })
              .catchError((error) {
                dev.log('Error getting task stats: $error');
              });
        },
        child: Icon(Icons.info_outline_rounded),
      ),
    );
  }
}
