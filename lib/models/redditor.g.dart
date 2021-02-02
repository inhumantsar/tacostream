// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redditor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RedditorAdapter extends TypeAdapter<Redditor> {
  @override
  final int typeId = 2;

  @override
  Redditor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Redditor(
      id: fields[0] as String,
      displayName: fields[1] as String,
      credentials: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Redditor obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.credentials);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RedditorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
