import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'models/event.dart';

class CalendarState extends ChangeNotifier {
  late final Box<Event> _eventsBox;
  late final LinkedHashMap<DateTime, List<Event>> _dateEvents =
      LinkedHashMap<DateTime, List<Event>>();

  CalendarState(Box<Event> eventsBox) {
    _eventsBox = eventsBox;

    for (final Event event in _eventsBox.values) {
      _dateEvents.putIfAbsent(event.date, () => <Event>[]);
      _dateEvents[event.date]?.add(event);
    }
  }

  List<DateTime> get futureEventDates {
    final dateNow = DateTime.now();
    final thisMonthEventDates = _dateEvents.keys
        .where((x) => (x.month == dateNow.month && x.day >= dateNow.day))
        .toList();

    return List.unmodifiable(thisMonthEventDates);
  }

  List<Event> getEvents(DateTime date) =>
      List.unmodifiable(_dateEvents[date] ?? []);

  void addEvent(DateTime date, String title) {
    final events = _dateEvents[date] ?? [];
    final id =
        events.fold(0, (curr, next) => curr < next.id ? next.id : curr) + 1;
    final normalizedDay = DateTime.utc(date.year, date.month, date.day);
    final newEvent = Event(id: id, title: title, date: normalizedDay);
    events.add(newEvent);
    _dateEvents[date] = events;

    _eventsBox.add(newEvent);
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
    events.replaceRange(
        index, index + 1, [Event(id: event.id, date: date, title: title)]);
    notifyListeners();
  }
}
