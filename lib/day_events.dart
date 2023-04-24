import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'calendar_state.dart';

class DayEvents extends StatelessWidget {
  final DateTime currentDate;

  const DayEvents({super.key, required this.currentDate});

  @override
  Widget build(BuildContext context) {
    final calendarState = Provider.of<CalendarState>(context, listen: true);
    final events = calendarState.getEvents(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Selected Date: ${DateFormat("yyyy-MM-dd").format(currentDate)}'),
      ),
      body: Center(
        child: Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  onTap: () => calendarState.toggleEvent(currentDate, index),
                  title: Text('${events[index]}'),
                  selected: events[index].isSelected,
                ),
              );
            },
          ),
        ),
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
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Save'),
                          onPressed: () {
                            if (controller.text.isEmpty) {
                              return;
                            }
                            calendarState.addEvent(
                                currentDate, controller.text);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                barrierDismissible: true);
          },
          child: const Icon(Icons.add)),
    );
  }
}
