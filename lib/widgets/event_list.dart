import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: ListTile(
              tileColor: today.isAfter(events[index].birthDate)
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
                onTap?.call(events[index]);
              },
            ));
      });
}
