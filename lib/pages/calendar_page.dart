import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../calendar_state.dart';
import '../models/event.dart';
import '../constants.dart';
import 'edit_event_page.dart';
import 'new_event_page.dart';

class CalendarPage extends StatefulWidget {
  final String title;

  const CalendarPage({super.key, required this.title});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
    if (isSameDay(_selectedDay, selectedDay)) {
      return;
    }
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarState>(builder: (context, state, child) {
      final events = state.getEvents(_focusedDay);
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: <Widget>[
              ...(kDebugMode
                  ? [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          state.clear();
                        },
                      )
                    ]
                  : [])
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
                                    builder: (context) => EditEventPage(
                                        eventId: events[index].id),
                                  ),
                                );
                              },
                            ));
                      }))
            ],
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NewEventPage(focusedDate: _focusedDay),
                  ),
                );
              },
              child: const Icon(Icons.add)));
    });
  }
}
