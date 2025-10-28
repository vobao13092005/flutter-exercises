import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Khởi tạo timezone
  runApp(const ReminderApp());
}

class ReminderApp extends StatelessWidget {
  const ReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const ReminderPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  // 🔔 Khởi tạo plugin
  Future<void> _initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  // 🕒 Chọn thời gian
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // 🧠 Hẹn thông báo
  Future<void> _scheduleNotification() async {
    final androidPlugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final granted = await AndroidFlutterLocalNotificationsPlugin()
          .requestExactAlarmsPermission();
      if (granted == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please allow exact alarms in settings"),
          ),
        );
        return;
      }
    }
    if (_selectedDateTime == null || _titleController.text.isEmpty) return;

    final tzDateTime = tz.TZDateTime.from(_selectedDateTime!, tz.local);

    await _notificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      _titleController.text,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Scheduled reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⏰ Reminder scheduled successfully!')),
    );

    _titleController.clear();
    setState(() => _selectedDateTime = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔔 Reminder App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'No time selected'
                        : '⏱ ${_selectedDateTime!.toLocal()}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Pick time'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Schedule Reminder'),
              onPressed: _scheduleNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
