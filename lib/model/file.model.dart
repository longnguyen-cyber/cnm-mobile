// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class FileModel {
  final String? id;
  final String? filename;
  final String? path;
  final int? size;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  FileModel({
    required this.id,
    required this.filename,
    required this.path,
    required this.size,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  FileModel copyWith({
    String? id,
    String? filename,
    String? path,
    int? size,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return FileModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      path: path ?? this.path,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'filename': filename,
      'path': path,
      'size': size,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'] != null ? map['id'] as String : null,
      filename: map['filename'] as String,
      path: map['path'] as String,
      size: map['size'] as int,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      deletedAt: map['deletedAt'] is String
          ? DateTime.parse(map['deletedAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FileModel.fromJson(String source) =>
      FileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'File(id: $id, filename: $filename, path: $path, size: $size, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(covariant FileModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.filename == filename &&
        other.path == path &&
        other.size == size &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        filename.hashCode ^
        path.hashCode ^
        size.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
