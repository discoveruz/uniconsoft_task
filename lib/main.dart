import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconsoft_task/core/utils/db_helper.dart';
import 'package:uniconsoft_task/data/repositories/task_repository.dart';
import 'package:uniconsoft_task/pages/tasks_page.dart';

import 'domain/bloc/task_bloc.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
      home: BlocProvider<TaskBloc>(
        create: (context) => TaskBloc(TaskRepository(DatabaseHelper.instance))..add(GetTasksEvent()),
        child: const TasksPage(),
      ),
    );
  }
}
