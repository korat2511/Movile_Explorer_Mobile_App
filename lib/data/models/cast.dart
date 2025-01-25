import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cast.g.dart';

@JsonSerializable()
class Cast extends Equatable {
  final int id;
  final String name;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  final String character;

  const Cast({
    required this.id,
    required this.name,
    this.profilePath,
    required this.character,
  });

  String? get fullProfilePath => 
      profilePath != null ? 'https://image.tmdb.org/t/p/w200$profilePath' : null;

  factory Cast.fromJson(Map<String, dynamic> json) => _$CastFromJson(json);

  Map<String, dynamic> toJson() => _$CastToJson(this);

  @override
  List<Object?> get props => [id, name, profilePath, character];
} 