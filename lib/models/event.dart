import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 1)
class EventObject extends HiveObject {
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime date;

  EventObject({required this.title, required this.date});

  @override
  String toString() => title;
}

extension EventObjectExtension on EventObject {
  Event getEvent(dynamic key) => Event.fromKeyPair(key, this);
}

class Event {
  final int id;
  final String title;
  final DateTime birthDate;

  Event.fromKeyPair(dynamic key, EventObject object)
      : id = key as int,
        title = object.title,
        birthDate = object.date;

  const Event({required this.id, required this.title, required this.birthDate});

  DateTime getNormalizedDate([int? year]) {
    year ??= DateTime.now().year;
    return DateTime.utc(year, birthDate.month, birthDate.day);
  }

  EventObject getEventObject() => EventObject(date: birthDate, title: title);
}
