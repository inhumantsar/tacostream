// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommentAdapter extends TypeAdapter<Comment> {
  @override
  final int typeId = 1;

  @override
  Comment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Comment(
      id: fields[0] as String,
      name: fields[1] as String,
      permalink: fields[2] as String,
      createdUtc: fields[3] as DateTime,
      removed: fields[4] as bool,
      upvotes: fields[5] as int,
      downvotes: fields[6] as int,
      author: fields[7] as String,
      authorFlairImageUrl: fields[8] as String,
      authorFlairText: fields[9] as String,
      body: fields[10] as String,
      parentId: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Comment obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.permalink)
      ..writeByte(3)
      ..write(obj.createdUtc)
      ..writeByte(4)
      ..write(obj.removed)
      ..writeByte(5)
      ..write(obj.upvotes)
      ..writeByte(6)
      ..write(obj.downvotes)
      ..writeByte(7)
      ..write(obj.author)
      ..writeByte(8)
      ..write(obj.authorFlairImageUrl)
      ..writeByte(9)
      ..write(obj.authorFlairText)
      ..writeByte(10)
      ..write(obj.body)
      ..writeByte(11)
      ..write(obj.parentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
