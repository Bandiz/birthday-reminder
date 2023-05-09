import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'calendar_state.dart';
import 'models/event.dart';
import 'pages/new_event_page.dart';

final kToday = DateTime.now().toUtc();
final kFirstDay = DateTime(kToday.year, 1, 31);
final kLastDay = DateTime(kToday.year, 12, 31);

void main() async {
  Hive.registerAdapter(EventAdapter());
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();

  final Box<Event> eventsBox = await Hive.openBox<Event>("events");
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

  final futureEventsDates = state.futureEventDates;
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

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarState>(builder: (context, state, child) {
      final events = state.getEvents(_focusedDay);
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  state.clear();
                },
              )
            ],
          ),
          body: Column(
            children: [
              TableCalendar<Event>(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                headerStyle: const HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
                eventLoader: (date) => state.getEvents(date),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: true,
                ),
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              Expanded(
                  child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: ListTile(
                                    title: Text(events[index].title),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(5),
                                    )));
                          })))
            ],
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewEventPage(),
                  ),
                );
              },
              child: const Icon(Icons.add)));
    });
  }
}
