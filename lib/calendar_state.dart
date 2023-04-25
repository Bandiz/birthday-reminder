import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'utils.dart';

class CalendarState extends ChangeNotifier {
  late final LinkedHashMap<DateTime, List<Event>> _dateEvents;

  CalendarState() {
    _dateEvents = kEvents;
  }

  List<Event> getEvents(DateTime date) =>
      List.unmodifiable(_dateEvents[date] ?? []);

  void toggleEvent(DateTime date, int index) {
    final events = _dateEvents[date];

    if (events == null) return;

    final event = events[index];

    for (var element in events.where((x) => x.isSelected && x != event)) {
      element.isSelected = false;
    }

    event.isSelected = !event.isSelected;
    notifyListeners();
  }

  void addEvent(DateTime date, String title) {
    final events = _dateEvents[date] ?? [];

    events.add(Event(title: title, date: date));
    _dateEvents[date] = events;
    notifyListeners();
  }

  void removeEvent(DateTime date, Event event) {
    final events = _dateEvents[date] ?? [];
    events.remove(event);
    notifyListeners();
  }

  void updateEvent(DateTime date, Event event, String title) {
    final events = _dateEvents[date] ?? [];
    final index = events.indexOf(event);
    events.replaceRange(index, index + 1, [Event(date: date, title: title)]);
    notifyListeners();
  }
}
