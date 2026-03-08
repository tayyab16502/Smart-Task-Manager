import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Provider import kiya
import '../../../core/constants/theme.dart';
import '../controllers/notification_controller.dart';
import '../../task/views/task_detail_screen.dart';
import '../../task/models/task_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Screen khulte hi data fetch karne ke liye Provider ko call kiya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().loadNotifications();
    });
  }

  // Card banane wala widget, ab theme aur controller parameter ma lay ga
  Widget _buildNotificationCard(BuildContext context, TaskModel task, bool isOverdue, ThemeData theme, NotificationController controller) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
        if (context.mounted) {
          controller.loadNotifications(); // Wapis anay par Provider k through refresh karein
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOverdue ? Colors.redAccent.withOpacity(0.05) : AppTheme.amber.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isOverdue ? Colors.redAccent.withOpacity(0.2) : AppTheme.amber.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOverdue ? Colors.redAccent.withOpacity(0.1) : AppTheme.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOverdue ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.clock_fill,
                color: isOverdue ? Colors.redAccent : AppTheme.amber,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOverdue ? 'Overdue Task!' : 'Upcoming Task',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? Colors.redAccent : AppTheme.amber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.title,
                    // Title color ab dynamic hai
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(task.dateTime),
                    // Hint color bhi theme se aa raha hai
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: theme.hintColor.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider aur Theme ko watch kar rahay hain
    final controller = context.watch<NotificationController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : controller.totalNotifications == 0
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.bell_slash, size: 64, color: theme.hintColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No new notifications', style: TextStyle(color: theme.hintColor)),
          ],
        ),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.overdueTasks.isNotEmpty) ...[
              const Text('Needs Attention', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent)),
              const SizedBox(height: 12),
              ...controller.overdueTasks.map((t) => _buildNotificationCard(context, t, true, theme, controller)).toList(),
              const SizedBox(height: 24),
            ],
            if (controller.upcomingTasks.isNotEmpty) ...[
              Text('Upcoming (Next 24 Hours)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.hintColor)),
              const SizedBox(height: 12),
              ...controller.upcomingTasks.map((t) => _buildNotificationCard(context, t, false, theme, controller)).toList(),
            ],
          ],
        ),
      ),
    );
  }
}