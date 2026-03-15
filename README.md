# Smart Task Manager 🚀

A highly functional and professional Task Management Flutter application. This project was developed to showcase advanced state management, local database handling, strict data validation, and interactive UI/UX design.

**Built for CodeChine Internship Assignment.**

## ✨ Key Features

* **Advanced Task Management:** Create, Read, Update, and Delete (CRUD) tasks effortlessly.
* **Smart Sub-Tasks & Checklists:** Break down large tasks into smaller sub-tasks. The main task automatically completes when all sub-tasks are checked!
* **Chronological Deadline Validation:** Sub-tasks cannot be scheduled before the previous sub-task or after the main task's deadline, ensuring a perfectly logical project timeline.
* **Duplicate Task Detection:** Smartly alerts the user if a task with the exact same name already exists, preventing confusing duplicates.
* **Precision Push Notifications:** Instant alerts upon task creation, individual schedule-based alarms for every sub-task, and 24-hour, 10-hour, and 1-hour reminders for main deadlines using `awesome_notifications`.
* **Productivity Analytics:** Visual bar charts tracking your last 7 days of productivity using `fl_chart`.
* **Interactive Calendar View:** A dedicated calendar screen to view tasks scheduled for specific dates using `table_calendar`.
* **Smart Dashboard:** * Filter tasks by category (Work, Study, Personal).
    * Toggle between Pending and Completed tasks.
    * Sort tasks by Time or Priority.
    * Real-time productivity circular progress indicator.
* **Local Storage:** All tasks and sub-tasks are securely saved offline using `sqflite`.
* **Dark & Light Mode:** Fully supported theme toggling for better user experience.

## 🛠️ Tech Stack & Packages Used

* **Framework:** Flutter (Dart)
* **State Management:** Provider (`provider`)
* **Local Database:** SQLite (`sqflite`, `path`)
* **Charts & Analytics:** FL Chart (`fl_chart`)
* **Calendar:** Table Calendar (`table_calendar`)
* **Notifications:** Awesome Notifications (`awesome_notifications`)
* **Date & Time Formatting:** Intl (`intl`)

## 📱 Screenshots
<p align="center">
  <img src="assets/screenshots/light_ss.jpeg" width="22%" />
  <img src="assets/screenshots/light_dash.jpeg" width="22%" />
  <img src="assets/screenshots/light_CT.jpeg" width="22%" />
  <img src="assets/screenshots/light_task_read.jpeg" width="22%" />
  <img src="assets/screenshots/dark_ss.jpeg" width="22%" />
  <img src="assets/screenshots/dark_dash_1.jpeg" width="22%" />
  <img src="assets/screenshots/dark_dash_2.jpeg" width="22%" />
  <img src="assets/screenshots/dark_CT.jpeg" width="22%" />
  <img src="assets/screenshots/dark_read_task.jpeg" width="22%" />
</p>

## 🚀 How to Run the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/smart-task-manager.git

2. Navigate to the project directory:

   ```bash
   cd smart-task-manager
3. Install dependencies:

   ```bash
   flutter pub get  
4. Run the app on an emulator or physical device:

   ```bash
   flutter run
Note: For the best experience with precise background alarms, test on a physical device and ensure you grant the required notification and alarm permissions on the first launch.

👤 Author:    
Tayyab Khan