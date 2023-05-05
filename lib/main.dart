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
    ChangeNotifierProvider(
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

  for (DateTime eventDate in futureEventsDates) {
    int delay = 0;
    for (Event event in state.getEvents(eventDate)) {
      DateTime notificationTime = DateTime(
          event.date.year, event.date.month, event.date.day, 10, 0, delay++);

      if (notificationTime.isBefore(DateTime.now())) {
        notificationTime = DateTime.now().add(Duration(seconds: 10 + delay++));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
          event.id,
          event.title,
          'This is your birthday reminder',
          tz.TZDateTime.from(notificationTime, local),
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }
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
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    final events = context.read<CalendarState>().getEvents(day);
    return events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final List<Event> events = _getEventsForDay(selectedDay);
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = events;
    }

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DayEvents(currentDate: selectedDay),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
              eventLoader: _getEventsForDay,
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
                        itemCount: _selectedEvents.value.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              child: ListTile(
                                  title:
                                      Text(_selectedEvents.value[index].title),
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
              final controller = TextEditingController();
              await showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Enter new event"),
                  content: TextField(
                    controller: controller,
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        controller.dispose();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        if (controller.text.isEmpty) {
                          return;
                        }
                        context
                            .read<CalendarState>()
                            .addEvent(_focusedDay, controller.text);

                        controller.dispose();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.add)));
  }
}
