import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'calendar_state.dart';
import 'models/event.dart';
import 'pages/home_page.dart';

void main() async {
  Hive.registerAdapter(EventObjectAdapter());
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();

  final Box<EventObject> eventsBox = await Hive.openBox<EventObject>("events");
  final Cron cron = Cron();
  final CalendarState state = CalendarState(eventsBox);

  await initializeNotifications();
  tz.initializeTimeZones();
  await scheduleReminders(state);

  cron.schedule(Schedule.parse('0 8 1 * *'), () async {
    await scheduleReminders(state);
  });

  runApp(
    ChangeNotifierProvider<CalendarState>(
        create: (_) => state, child: const BirthdayReminderApp()),
  );
}

Future<void> scheduleReminders(CalendarState state) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('monthly_notification', 'Monthly Notification',
          channelDescription: 'Scheduled monthly notification',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  final futureEventsDates = state.getMonthEvents;
  final local = tz.getLocation("Europe/Stockholm");

  await flutterLocalNotificationsPlugin.cancelAll();

  // for (DateTime eventDate in futureEventsDates) {
  //   int delay = 0;
  //   for (Event event in state.getEvents(eventDate)) {
  //     DateTime notificationTime = DateTime(
  //         event.date.year, event.date.month, event.date.day, 10, 0, delay++);

  //     if (notificationTime.isBefore(DateTime.now())) {
  //       notificationTime = DateTime.now().add(Duration(seconds: 10 + delay++));
  //     }

  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //         event.id,
  //         event.title,
  //         'This is your birthday reminder',
  //         tz.TZDateTime.from(notificationTime, local),
  //         platformChannelSpecifics,
  //         androidAllowWhileIdle: true,
  //         uiLocalNotificationDateInterpretation:
  //             UILocalNotificationDateInterpretation.absoluteTime);
  //   }
  // }
}

Future<bool?> initializeNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin);
  return flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class BirthdayReminderApp extends StatelessWidget {
  const BirthdayReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birthday reminder',
      locale: const Locale('sv', 'SE'),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(title: 'Home page'),
    );
  }
}
