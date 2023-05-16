// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventObjectAdapter extends TypeAdapter<EventObject> {
  @override
  final int typeId = 1;

  @override
  EventObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventObject(
      title: fields[1] as String,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EventObject obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
