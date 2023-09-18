import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'models/event.dart';

class CalendarState extends ChangeNotifier {
  late final Box<EventObject> _eventsBox;
  late final LinkedHashMap<DateTime, List<Event>> _dateEvents =
      LinkedHashMap<DateTime, List<Event>>();
  final List<int> _dismissed = [];

  CalendarState(Box<EventObject> eventsBox) {
    _eventsBox = eventsBox;

    int year = DateTime.now().year;

    for (final kv in _eventsBox.toMap().entries) {
      final Event event = kv.value.getEvent(kv.key);
      DateTime normalizedDate = event.getNormalizedDate(year);
      _dateEvents.putIfAbsent(normalizedDate, () => <Event>[]);
      _dateEvents[normalizedDate]!.add(event);
    }
  }

  List<DateTime> get getMonthEvents {
    final dateNow = DateTime.now();
    final thisMonthEventDates = _dateEvents.keys
        .where((x) => (x.month == dateNow.month && x.day >= dateNow.day))
        .toList();

    return List.unmodifiable(thisMonthEventDates);
  }

  EventObject getEvent(int id) {
    final event = _eventsBox.get(id);

    if (event == null) {
      throw Exception("Event does not exist");
    }
    return event;
  }

  List<Event> getEvents(DateTime date) =>
      List.unmodifiable(_dateEvents[date] ?? []);

  List<Event> getUpcomingEvents() {
    DateTime now = DateTime.now();
    DateTime minDate = now.add(const Duration(days: -3));
    DateTime maxDate = now.add(const Duration(days: 7));

    final upcomingEvents = _dateEvents.entries
        .where((event) =>
            minDate.month <= event.key.month &&
            event.key.month <= maxDate.month &&
            minDate.day <= event.key.day &&
            event.key.day < maxDate.day)
        .map((e) => e.value)
        .expand((x) => x)
        .where((event) => !_dismissed.contains(event.id))
        .toList();
    upcomingEvents.sort((a, b) => a.birthDate.isBefore(b.birthDate) ? 0 : 1);

    return List.unmodifiable(upcomingEvents);
  }

  void dismissEvent(Event event) {
    if (_dismissed.contains(event.id)) {
      return;
    }
    _dismissed.add(event.id);
    notifyListeners();
  }

  void addEvent(DateTime date, String title) async {
    EventObject newEventObject = EventObject(date: date, title: title);

    final int id = await _eventsBox.add(newEventObject);
    final Event event = newEventObject.getEvent(id);
    final DateTime normalizedDate = event.getNormalizedDate();

    _dateEvents[normalizedDate] ??= [];
    _dateEvents[normalizedDate]!.add(event);

    newEventObject.save();
    notifyListeners();
  }

  void removeEvent(DateTime date, EventObject event) {
    final events = _dateEvents[date] ?? [];
    events.remove(event);
    // _eventsBox.delete(event.id);
    notifyListeners();
  }

  void updateEvent(int key, String title, DateTime date) {
    final EventObject inMemory = _eventsBox.get(key)!;
    final Event eventSnapshot = inMemory.getEvent(key);
    final Event updatedEvent = Event(id: key, title: title, birthDate: date);

    final EventObject updatedEventObject = updatedEvent.getEventObject();
    _eventsBox.put(key, updatedEvent.getEventObject());
    // updatedEventObject.save();

    _dateEvents[eventSnapshot.getNormalizedDate()]!
        .removeWhere((x) => x.id == key);

    final DateTime updatedNormalizedDate = updatedEvent.getNormalizedDate();

    _dateEvents[updatedNormalizedDate] ??= [];
    _dateEvents[updatedNormalizedDate]!.add(updatedEvent);

    notifyListeners();
  }

  void clear() {
    _dateEvents.clear();
    _eventsBox.clear();
    _dismissed.clear();
    notifyListeners();
  }
}
