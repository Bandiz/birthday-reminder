import 'package:birthday_reminder/pages/calendar_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../calendar_state.dart';
import 'edit_event_page.dart';
import 'new_event_page.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

void generateRandomEvents(
    CalendarState state, int numberOfEvents, int year, int month) {
  final Random random = Random();

  for (int i = 0; i < numberOfEvents; i++) {
    final int day = random.nextInt(DateTime(year, month + 1, 0).day) + 1;
    final DateTime randomDate = DateTime(year, month, day);

    state.addEvent(randomDate, 'Event ${i + 1}');
  }
}

class _HomePageState extends State<HomePage> {
  final DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarState>(builder: (context, state, child) {
      final events = state.getUpcomingEvents();
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            ...(kDebugMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.add_box),
                      onPressed: () {
                        generateRandomEvents(state, 50, 2023, 9);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added test data'),
                            dismissDirection: DismissDirection.horizontal,
                            duration: Duration(milliseconds: 2000),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        state.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cleared data'),
                            dismissDirection: DismissDirection.horizontal,
                            duration: Duration(milliseconds: 2000),
                          ),
                        );
                      },
                    )
                  ]
                : [])
          ],
        ),
        body: Column(
          children: [
            Expanded(
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
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditEventPage(eventId: events[index].id),
                                ),
                              );
                            },
                          ));
                    }))
          ],
        ),
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewEventPage(focusedDate: _focusedDay),
                ),
              );
            },
            child: const Icon(Icons.add_outlined),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarPage(
                      title: "Calendar",
                    ),
                  ));
            },
            child: const Icon(Icons.calendar_month_outlined),
          ),
          TextButton(
            onPressed: () {},
            child: const Icon(Icons.person_2_outlined),
          )
        ],
      );
    });
  }
}
