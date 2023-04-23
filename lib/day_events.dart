import 'package:birthday_reminder/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DayEvents extends StatelessWidget {
  final DateTime currentDate;
  late final ValueListenable<List<Event>> events;

  DayEvents(List<Event> events, {super.key, required this.currentDate}) {
    this.events = ValueNotifier(events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Date: ${currentDate.toString()}'),
      ),
      body: Center(
        child: Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: events,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                      // color: value[index].isSelected ? Colors.red : null
                    ),
                    child: ListTile(
                      onTap: () {
                        // setState(() {
                        //   value[index].isSelected = !value[index].isSelected;
                        // });
                      },
                      title: Text('${value[index]}'),
                      selected: value[index].isSelected,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
