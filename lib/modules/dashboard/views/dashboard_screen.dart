import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/controllers/theme_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../task/views/add_task_screen.dart';
import '../../task/views/task_detail_screen.dart';
import '../../task/views/edit_task_screen.dart';
import '../../task/widgets/task_card_widget.dart';
import '../../notification/views/notification_screen.dart';
import '../../notification/controllers/notification_controller.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().fetchTasks();
      context.read<NotificationController>().loadNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<DashboardController>().fetchTasks();
      context.read<NotificationController>().loadNotifications();
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work': return AppTheme.teal;
      case 'Study': return AppTheme.violet;
      case 'Personal': return AppTheme.amber;
      default: return AppTheme.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final notificationController = context.watch<NotificationController>();
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
            : CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // --- FIX: Wrap with Expanded to prevent overflow ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.greeting,
                                style: TextStyle(fontSize: 14, color: theme.hintColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'My Dashboard',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // ---------------------------------------------------
                        Row(
                          mainAxisSize: MainAxisSize.min, // FIX: Ensure Row takes minimum required space
                          children: [
                            IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                color: AppTheme.teal,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                context.read<ThemeController>().toggleTheme();
                              },
                            ),
                            const SizedBox(width: 8),

                            // --- NAYA BUTTON: CALENDAR & ANALYTICS ---
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                                );
                              },
                              child: Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.violet.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.violet.withOpacity(0.3)),
                                ),
                                child: const Icon(CupertinoIcons.calendar, color: AppTheme.violet, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // -----------------------------------------

                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                                );
                                // FIX: Removed 'if (result == true)' so it always updates
                                if (context.mounted) {
                                  context.read<DashboardController>().fetchTasks();
                                  context.read<NotificationController>().loadNotifications();
                                }
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.teal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppTheme.teal.withOpacity(0.3)),
                                    ),
                                    child: const Icon(CupertinoIcons.bell, color: AppTheme.teal, size: 20),
                                  ),
                                  if (notificationController.totalNotifications > 0)
                                    Positioned(
                                      right: 10,
                                      top: 12,
                                      child: Container(
                                        height: 8,
                                        width: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.teal.withOpacity(0.15), AppTheme.violet.withOpacity(0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.teal.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Productivity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              Text(
                                '${controller.completedTasks} Completed • ${controller.pendingTasks} Pending',
                                style: TextStyle(fontSize: 12, color: theme.hintColor),
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: CircularProgressIndicator(
                                  value: controller.productivityPercentage,
                                  strokeWidth: 5,
                                  backgroundColor: theme.dividerColor,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amber),
                                ),
                              ),
                              Text(
                                '${(controller.productivityPercentage * 100).toInt()}%',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      onChanged: controller.updateSearch,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: Icon(CupertinoIcons.search, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.toggleView(false),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !controller.showCompleted ? AppTheme.teal.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: !controller.showCompleted ? AppTheme.teal.withOpacity(0.5) : Colors.transparent),
                                ),
                                child: Text(
                                  'Pending',
                                  style: TextStyle(
                                    color: !controller.showCompleted ? AppTheme.teal : theme.hintColor,
                                    fontWeight: !controller.showCompleted ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.toggleView(true),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: controller.showCompleted ? AppTheme.violet.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: controller.showCompleted ? AppTheme.violet.withOpacity(0.5) : Colors.transparent),
                                ),
                                child: Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: controller.showCompleted ? AppTheme.violet : theme.hintColor,
                                    fontWeight: controller.showCompleted ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: ['All', 'Work', 'Study', 'Personal'].map((category) {
                                final isSelected = controller.selectedCategory == category;
                                return GestureDetector(
                                  onTap: () => controller.updateCategoryFilter(category),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? _getCategoryColor(category).withOpacity(0.2) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? _getCategoryColor(category) : theme.dividerColor,
                                      ),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected ? _getCategoryColor(category) : theme.hintColor,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: controller.updateSort,
                          color: theme.cardColor,
                          icon: Icon(CupertinoIcons.sort_down, color: theme.hintColor, size: 20),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'Time', child: Text('Sort by Time', style: TextStyle(color: theme.colorScheme.onSurface))),
                            PopupMenuItem(value: 'Priority', child: Text('Sort by Priority', style: TextStyle(color: theme.colorScheme.onSurface))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            controller.displayTasks.isEmpty
                ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Center(
                  child: Text(
                    'No tasks found',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final task = controller.displayTasks[index];
                    return TaskCardWidget(
                      task: task,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
                        );
                        // FIX: Removed 'if (result == true)' so it always updates
                        if (context.mounted) {
                          context.read<DashboardController>().fetchTasks();
                          context.read<NotificationController>().loadNotifications();
                        }
                      },
                      onComplete: () async {
                        await controller.markTaskAsCompleted(task);
                        if (context.mounted) {
                          context.read<NotificationController>().loadNotifications();
                        }
                      },
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
                        );
                        // FIX: Removed 'if (result == true)' so it always updates
                        if (context.mounted) {
                          context.read<DashboardController>().fetchTasks();
                          context.read<NotificationController>().loadNotifications();
                        }
                      },
                      onDelete: () async {
                        await controller.deleteTask(task.id!);
                        if (context.mounted) {
                          context.read<NotificationController>().loadNotifications();
                        }
                      },
                    );
                  },
                  childCount: controller.displayTasks.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.teal.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            );
            // FIX: Removed 'if (result == true)' so it always updates
            if (context.mounted) {
              context.read<DashboardController>().fetchTasks();
              context.read<NotificationController>().loadNotifications();
            }
          },
          backgroundColor: AppTheme.teal,
          elevation: 0,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        ),
      ),
    );
  }
}