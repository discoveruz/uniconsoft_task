package uz.uniconsoft.taskmanagement.uniconsoft_task
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity


class MainActivity : FlutterActivity(){
    private val TASK_CHANNEL = "uz.uniconsoft.task/taskstats"
    private lateinit var channel: MethodChannel
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel =  MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TASK_CHANNEL)
        channel.setMethodCallHandler { call, result ->
             when(call.method){
                 "showTaskStats" ->{
                     val args = call.arguments as List<Map<String, Any>>
                     val firstItem = args[0]
                     val taskStats = firstItem["taskStats"] as Map<*, *>
                     println("Adroid Layer: Task Stats Received: $taskStats")
                     result.success("Task stats received successfully")
                    }
                    else -> {
                        result.notImplemented()
                 }
             }
         }

    }
}
