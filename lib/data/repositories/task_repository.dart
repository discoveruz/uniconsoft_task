import 'package:uniconsoft_task/core/utils/db_helper.dart';
import 'package:uniconsoft_task/models/task.dart';

class TaskRepository {
  TaskRepository(this._databaseHelper);
  final DatabaseHelper _databaseHelper;
  Future<List<Task>> fetchTasks() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getTasks();
    return List.generate(maps.length, (i) {
      return Task.fromJson(maps[i]);
    });
  }

  Future<int> addTask(Task task) async {
    final int status = await _databaseHelper.insertTask(task.toJson());
    return status;
  }

  Future<int> updateTask(Task task) async {
    final int status = await _databaseHelper.updateTask(task.toJson());
    return status;
  }

  Future<int> deleteTask(int id) async {
    final int status = await _databaseHelper.deleteTask(id);
    return status;
  }

  Future<void> clearTasks() async {
    await _databaseHelper.clearTasks();
  }

  Future<int> getTaskCount() async {
    return await _databaseHelper.getTaskCount();
  }

  Future<void> closeDatabase() async {
    await _databaseHelper.closeDatabase();
  }
}
