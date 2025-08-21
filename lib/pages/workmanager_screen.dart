import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const simpleTaskKey = "dev.fluttercommunity.workmanagerExample.simpleTask";
const rescheduledTaskKey = "dev.fluttercommunity.workmanagerExample.rescheduledTask";
const failedTaskKey = "dev.fluttercommunity.workmanagerExample.failedTask";
const simpleDelayedTask = "dev.fluttercommunity.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask = "dev.fluttercommunity.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask = "dev.fluttercommunity.workmanagerExample.simplePeriodic1HourTask";
const iOSBackgroundAppRefresh = "dev.fluttercommunity.workmanagerExample.iOSBackgroundAppRefresh";
const iOSBackgroundProcessingTask = "dev.fluttercommunity.workmanagerExample.iOSBackgroundProcessingTask";
const periodicUpdatePolicyTask = "dev.fluttercommunity.workmanagerExample.periodicUpdatePolicyTask";

final List<String> allTasks = [
  simpleTaskKey,
  rescheduledTaskKey,
  failedTaskKey,
  simpleDelayedTask,
  simplePeriodicTask,
  simplePeriodic1HourTask,
  iOSBackgroundAppRefresh,
  iOSBackgroundProcessingTask,
  periodicUpdatePolicyTask,
];

// Pragma is mandatory if the App is obfuscated or using Flutter 3.1+
@pragma('vm:entry-point')
void callbackDispatcher() {
  log('callbackDispatcher called');
  Workmanager().executeTask((task, inputData) async {
    log("callbackDispatcher called with task: $task");
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    print("$task started. inputData = $inputData");
    await prefs.setString(task, 'Last ran at: ${DateTime.now().toString()}');

    switch (task) {
      case simpleTaskKey:
        await prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        if (prefs.containsKey('unique-$key')) {
          print('has been running before, task is successful');
          return true;
        } else {
          await prefs.setBool('unique-$key', true);
          print('reschedule task');
          return false;
        }
      case failedTaskKey:
        print('failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");
        break;
      case iOSBackgroundAppRefresh:
        // To test, follow the instructions on https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development
        // and https://github.com/fluttercommunity/flutter_workmanager/blob/main/IOS_SETUP.md
        Directory? tempDir = await getTemporaryDirectory();
        String? tempPath = tempDir.path;
        print(
          "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath",
        );
        break;
      case iOSBackgroundProcessingTask:
        // To test, follow the instructions on https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development
        // and https://github.com/fluttercommunity/flutter_workmanager/blob/main/IOS_SETUP.md
        // Processing tasks are started by iOS only when phone is idle, hence
        // you need to manually trigger by following the docs and putting the App to background
        await Future<void>.delayed(Duration(seconds: 40));
        print("$task finished");
        break;
      case periodicUpdatePolicyTask:
        final frequency = inputData?['frequency'] ?? 'unknown';
        print("$periodicUpdatePolicyTask executed with frequency: $frequency minutes at ${DateTime.now()}");
        break;
      default:
        return Future.value(false);
    }

    // Return true to indicate that the task was successful
    print("$task finished successfully");
    return Future.value(true);
  });
}

class WorkManagerScreen extends StatefulWidget {
  const WorkManagerScreen({super.key});

  @override
  _WorkManagerScreenState createState() => _WorkManagerScreenState();
}

class _WorkManagerScreenState extends State<WorkManagerScreen> {
  bool workmanagerInitialized = false;
  String _prefsString = "empty";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Flutter WorkManager Example")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("Plugin initialization", style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () async {
                    if (Platform.isIOS) {
                      final status = await Permission.backgroundRefresh.status;
                      if (status != PermissionStatus.granted) {
                        _showNoPermission(context, status);
                        return;
                      }
                    }
                    if (!workmanagerInitialized) {
                      try {
                        await Workmanager().initialize(callbackDispatcher);
                      } catch (e) {
                        print('Error initializing Workmanager: $e');
                        return;
                      }
                      setState(() => workmanagerInitialized = true);
                    }
                  },
                ),
                SizedBox(height: 8),
                Text("Register task", style: Theme.of(context).textTheme.headlineSmall),

                ElevatedButton(
                  child: Text("Register Delayed OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      simpleDelayedTask,
                      simpleDelayedTask,
                      initialDelay: Duration(seconds: 30),
                    );
                  },
                ),

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      Platform.isAndroid
                          ? () async {
                            final workInfo = await Workmanager().isScheduledByUniqueName(simplePeriodicTask);
                            print('isscheduled = $workInfo');
                          }
                          : null,
                  child: Text("isscheduled (Android)"),
                ),
                SizedBox(height: 8),
                Text("Task cancellation", style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton(
                  child: Text("Cancel All"),
                  onPressed: () async {
                    await Workmanager().cancelAll();
                    print('Cancel all tasks completed');
                  },
                ),
                SizedBox(height: 15),
                SingleChildScrollView(
                  child: Text(
                    'Task run stats:\n'
                    '${workmanagerInitialized ? '' : 'Workmanager not initialized'}'
                    '\n$_prefsString',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotInitialized() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Workmanager not initialized'),
          content: Text('Workmanager is not initialized, please initialize'),
          actions: <Widget>[TextButton(child: Text('OK'), onPressed: () => Navigator.of(context).pop())],
        );
      },
    );
  }

  void _showNoPermission(BuildContext context, PermissionStatus hasPermission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No permission'),
          content: Text(
            'Background app refresh is disabled, please enable in '
            'App settings. Status ${hasPermission.name}',
          ),
          actions: <Widget>[TextButton(child: Text('OK'), onPressed: () => Navigator.of(context).pop())],
        );
      },
    );
  }
}
