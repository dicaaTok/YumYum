// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserRecipeAdapter extends TypeAdapter<UserRecipe> {
  @override
  final int typeId = 1;

  @override
  UserRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserRecipe(
      title: fields[0] as String,
      description: fields[1] as String,
      ingredients: (fields[2] as List).cast<String>(),
      steps: (fields[3] as List).cast<String>(),
      rating: fields[4] as double,
      imagePath: fields[5] as String?,
      difficulty: fields[6] as String?,
      time: fields[7] as String?,
      imageUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserRecipe obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.ingredients)
      ..writeByte(3)
      ..write(obj.steps)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.time)
      ..writeByte(8)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
