import 'package:flutter/material.dart';
import 'package:uniconsoft_task/models/task.dart';
import 'package:uniconsoft_task/pages/widgets/task_tile.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key, required this.onTaskFinished, required this.tasks});
  final ValueChanged<Task> onTaskFinished;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      addAutomaticKeepAlives: true,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: tasks.length,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        return TaskTile(
          task: tasks[index],
          onTap: () {
            _confirmFinish(context).then((isFinished) {
              if (isFinished) onTaskFinished(tasks[index]);
            });
          },
        );
      },
    );
  }
}

Future<bool> _confirmFinish(BuildContext context) async {
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
  return result ?? false;
}
