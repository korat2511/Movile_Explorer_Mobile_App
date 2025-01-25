// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewed_movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ViewedMovieAdapter extends TypeAdapter<ViewedMovie> {
  @override
  final int typeId = 1;

  @override
  ViewedMovie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ViewedMovie(
      id: fields[0] as int,
      title: fields[1] as String,
      posterPath: fields[2] as String?,
      overview: fields[3] as String,
      releaseDate: fields[4] as String,
      voteAverage: fields[5] as double,
      viewedAt: fields[6] as DateTime,
      isFavorite: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ViewedMovie obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.overview)
      ..writeByte(4)
      ..write(obj.releaseDate)
      ..writeByte(5)
      ..write(obj.voteAverage)
      ..writeByte(6)
      ..write(obj.viewedAt)
      ..writeByte(7)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewedMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
