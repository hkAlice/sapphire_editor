// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EditorSettingsModelAdapter extends TypeAdapter<EditorSettingsModel> {
  @override
  final int typeId = 0;

  @override
  EditorSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for(int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EditorSettingsModel(
      theme: fields[0] as String,
      brightness: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EditorSettingsModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.theme)
      ..writeByte(1)
      ..write(obj.brightness);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
