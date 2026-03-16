import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';
import '../../task/models/task_model.dart';

class NotificationService {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'task_alarms',
          channelName: 'Task Alarms',
          channelDescription: 'Alarms for task deadlines',
          defaultColor: const Color(0xFF06B6D4),
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          criticalAlerts: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
        ),
        NotificationChannel(
          channelKey: 'task_reminders',
          channelName: 'Task Reminders',
          channelDescription: 'Reminders for upcoming tasks',
          defaultColor: const Color(0xFF8B5CF6),
          importance: NotificationImportance.High,
        ),
      ],
    );

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    List<NotificationPermission> permissionsRequired = [
      NotificationPermission.PreciseAlarms,
      NotificationPermission.Vibration,
      NotificationPermission.FullScreenIntent,
    ];

    List<NotificationPermission> permissionsAllowed = await AwesomeNotifications().checkPermissionList(
      channelKey: 'task_alarms',
      permissions: permissionsRequired,
    );

    if (permissionsAllowed.length != permissionsRequired.length) {
      List<NotificationPermission> permissionsNeeded = permissionsRequired
          .where((element) => !permissionsAllowed.contains(element))
          .toList();
      await AwesomeNotifications().requestPermissionToSendNotifications(
        channelKey: 'task_alarms',
        permissions: permissionsNeeded,
      );
    }

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final String? taskIdStr = receivedAction.payload?['taskId'];

    if (taskIdStr != null) {
      final int taskId = int.parse(taskIdStr);
      final dbTasks = await DBHelper.instance.fetchAllTasks();
      final taskIndex = dbTasks.indexWhere((t) => t.id == taskId);

      if (taskIndex != -1) {
        final task = dbTasks[taskIndex];

        // Main Task Complete Action
        if (receivedAction.buttonKeyPressed == 'complete_action') {
          await DBHelper.instance.updateTask(task.copyWith(isCompleted: true));
        }
        // Main Task Delay Action
        else if (receivedAction.buttonKeyPressed == 'delay_action') {
          final delayedTask = task.copyWith(dateTime: task.dateTime.add(const Duration(minutes: 15)));
          await DBHelper.instance.updateTask(delayedTask);
          await scheduleTaskNotifications(delayedTask);
        }
        // NAYA SECTION: Sub-task Complete Action directly from Notification
        else if (receivedAction.buttonKeyPressed == 'complete_subtask_action') {
          final String? subTaskIndexStr = receivedAction.payload?['subTaskIndex'];
          if (subTaskIndexStr != null) {
            final int subIndex = int.parse(subTaskIndexStr);

            List<SubTask> updatedSubTasks = List.from(task.subTasks);
            updatedSubTasks[subIndex] = updatedSubTasks[subIndex].copyWith(isCompleted: true);

            bool areAllCompleted = updatedSubTasks.isNotEmpty && updatedSubTasks.every((st) => st.isCompleted);

            final updatedTask = task.copyWith(
              subTasks: updatedSubTasks,
              isCompleted: areAllCompleted ? true : task.isCompleted,
            );

            await DBHelper.instance.updateTask(updatedTask);

            // Agar saare sub-tasks puray ho gaye to main notifications cancel kar dein
            if (areAllCompleted) {
              await AwesomeNotifications().cancel(taskId);
              await AwesomeNotifications().cancel(taskId * 10 + 1);
              await AwesomeNotifications().cancel(taskId * 10 + 2);
              await AwesomeNotifications().cancel(taskId * 10 + 3);
            }
          }
        }
      }
    }
  }

  // Task create hotay hi fawran notification bhejne ke liye
  static Future<void> showTaskCreatedNotification(TaskModel task) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'task_reminders',
        title: 'Task Successfully Created! 🎉',
        body: 'Your task "${task.title}" has been added to the list.',
      ),
    );
  }

  static Future<void> scheduleTaskNotifications(TaskModel task) async {
    final int id = task.id ?? task.hashCode;

    // Purani notifications cancel karna
    await AwesomeNotifications().cancel(id);
    await AwesomeNotifications().cancel(id * 10 + 1);
    await AwesomeNotifications().cancel(id * 10 + 2);
    await AwesomeNotifications().cancel(id * 10 + 3);

    // Sub-tasks ki notifications bhi pehle cancel kar dein taake purani refresh ho jayen
    for (int i = 0; i < task.subTasks.length; i++) {
      await AwesomeNotifications().cancel(id * 1000 + i);
    }

    // Agar task poora ho chuka hai, to notification schedule nahi karni
    if (task.isCompleted) return;

    final DateTime deadline = task.dateTime;
    final DateTime now = DateTime.now();
    final Map<String, String> payload = {'taskId': id.toString()};

    // 1. Main Task ki Deadline Notification
    if (deadline.isAfter(now)) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'task_alarms',
          title: '⏰ Time is up!',
          body: 'Your task "${task.title}" is due now!',
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          locked: true,
          autoDismissible: false,
          timeoutAfter: const Duration(minutes: 1),
          payload: payload,
        ),
        actionButtons: [
          NotificationActionButton(key: 'delay_action', label: 'Delay It'),
          NotificationActionButton(key: 'complete_action', label: 'Mark as Complete'),
        ],
        schedule: NotificationCalendar.fromDate(
          date: deadline,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
    }

    // UPDATE: Sub-tasks ki Notifications ab proper Alarms ban chuki hain
    for (int i = 0; i < task.subTasks.length; i++) {
      final subTask = task.subTasks[i];
      final int subTaskId = id * 1000 + i;

      if (!subTask.isCompleted && subTask.deadline != null) {
        if (subTask.deadline!.isAfter(now)) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: subTaskId,
              channelKey: 'task_alarms', // Ab yeh reminder nahi, full alarm hai
              title: '⏰ Sub-task Time is up!',
              body: 'Your sub-task "${subTask.title}" is due now!',
              category: NotificationCategory.Alarm,
              wakeUpScreen: true,
              fullScreenIntent: true,
              criticalAlert: true,
              locked: true,
              autoDismissible: false,
              timeoutAfter: const Duration(minutes: 1),
              payload: {
                'taskId': id.toString(),
                'subTaskIndex': i.toString(), // Index pass kiya taake direct complete ho sake
              },
            ),
            actionButtons: [
              NotificationActionButton(key: 'complete_subtask_action', label: 'Mark Sub-task Complete'),
            ],
            schedule: NotificationCalendar.fromDate(
              date: subTask.deadline!,
              allowWhileIdle: true,
              preciseAlarm: true,
            ),
          );
        }
      }
    }
    // ------------------------------------------

    final DateTime oneHourLeft = deadline.subtract(const Duration(hours: 1));
    if (oneHourLeft.isAfter(now)) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id * 10 + 1,
          channelKey: 'task_reminders',
          title: 'Hurry Up!',
          body: '1 hour remaining for "${task.title}"',
        ),
        schedule: NotificationCalendar.fromDate(
          date: oneHourLeft,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
    }

    final DateTime tenHoursLeft = deadline.subtract(const Duration(hours: 10));
    if (tenHoursLeft.isAfter(now)) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id * 10 + 2,
          channelKey: 'task_reminders',
          title: 'Reminder',
          body: '10 hours left for "${task.title}"',
        ),
        schedule: NotificationCalendar.fromDate(
          date: tenHoursLeft,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
    }

    final DateTime twentyFourHoursLeft = deadline.subtract(const Duration(hours: 24));
    if (twentyFourHoursLeft.isAfter(now)) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id * 10 + 3,
          channelKey: 'task_reminders',
          title: 'Task Alert',
          body: '24 hours left for "${task.title}"',
        ),
        schedule: NotificationCalendar.fromDate(
          date: twentyFourHoursLeft,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
    }
  }
}