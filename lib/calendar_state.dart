import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'utils.dart';

class CalendarState extends ChangeNotifier {
  late final LinkedHashMap<DateTime, List<Event>> _dateEvents;

  CalendarState() {
    _dateEvents = kEvents;
  }

  List<Event> getEvents(DateTime date) => _dateEvents[date] ?? [];
}
