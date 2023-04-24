import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
            'Selected Date: ${DateFormat("yyyy-MM-dd").format(currentDate).toString()}'),
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
                  // color: value[index].isSelected ? Colors.red : null
                ),
                child: ListTile(
                  onTap: () {
                    calendarState.toggleEvent(currentDate, index);
                    // setState(() {
                    //   value[index].isSelected = !value[index].isSelected;
                    // });
                  },
                  title: Text('${events[index]}'),
                  selected: events[index].isSelected,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
