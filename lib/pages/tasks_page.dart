import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconsoft_task/bloc/task_bloc.dart';
import 'package:uniconsoft_task/models/task.dart';
import 'package:uniconsoft_task/pages/widgets/task_tile.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Tasks'),
        centerTitle: true,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tabAlignment: TabAlignment.fill,
                indicatorSize: TabBarIndicatorSize.tab,
                splashBorderRadius: BorderRadius.circular(12),
                indicator: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: <Widget>[Tab(child: Text('All')), Tab(child: Text('Completed')), Tab(child: Text('Pending'))],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.separated(
                      addAutomaticKeepAlives: true,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: 22,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        return TaskTile(
                          task: Task(
                            createdAt: 1755761104,
                            description: 'Task $index',
                            id: index,
                            status: Random().nextInt(2),
                          ),

                          onTap: () {
                            _confirmFinish(context);

                            // Handle task tap
                            dev.log('Task tapped: ${index + 1}');
                          },
                          onLongPress: () {
                            dev.log('Task long pressed: ${index + 1}');
                          },
                        );
                      },
                    ),
                    ListView.separated(
                      addAutomaticKeepAlives: true,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: 22,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        return TaskTile(
                          task: Task(
                            createdAt: 1755761104,
                            description: 'Task $index',
                            id: index,
                            status: Random().nextInt(2),
                          ),

                          onTap: () {
                            _confirmFinish(context);

                            // Handle task tap
                            dev.log('Task tapped: ${index + 1}');
                          },
                          onLongPress: () {
                            // Handle task double tap
                            dev.log('Task long pressed: ${index + 1}');
                          },
                        );
                      },
                    ),
                    ListView.separated(
                      addAutomaticKeepAlives: true,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: 22,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        return TaskTile(
                          task: Task(
                            createdAt: 1755761104,
                            description: 'Task $index',
                            id: index,
                            status: Random().nextInt(2),
                          ),

                          onTap: () {
                            // Handle task tap
                            _confirmFinish(context);

                            dev.log('Task tapped: ${index + 1}');
                          },
                          onLongPress: () {
                            // Handle task double tap
                            dev.log('Task long pressed: ${index + 1}');
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

void _confirmFinish(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure the task is finished?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Finish')),
        ],
      );
    },
  );
}
