import 'package:birthday_reminder/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';

class EventList extends StatelessWidget {
  final DateTime today = DateTime.now();
  final List<Event> events;
  final void Function(Event)? onTap;

  EventList({super.key, required this.events, this.onTap});

  @override
  Widget build(BuildContext context) => ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        Event event = events[index];
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: ListTile(
              tileColor: today.day == event.birthDate.day &&
                      today.month == event.birthDate.month
                  ? Colors.purple[300]
                  : today.isAfter(event.birthDate)
                      ? Colors.amber[700]
                      : Colors.blue[300],
              title: Text(events[index].title),
              subtitle: Text(
                  DateFormat('yyyy-MM-dd').format(events[index].birthDate)),
              leading: Text(index.toString()),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              onTap: () {
                onTap?.call(event);
              },
              trailing: IconButton.outlined(
                  onPressed: () => {
                        Provider.of<CalendarState>(context, listen: false)
                            .dismissEvent(event)
                      },
                  icon: const Icon(Icons.cancel_outlined)),
            ));
      });
}
