// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class File {
  final String? id;
  final String? filename;
  final String? path;
  final int? size;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  File({
    required this.id,
    required this.filename,
    required this.path,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  File copyWith({
    String? id,
    String? filename,
    String? path,
    int? size,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return File(
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

  factory File.fromMap(Map<String, dynamic> map) {
    return File(
      id: map['id'] as String,
      filename: map['filename'] as String,
      path: map['path'] as String,
      size: map['size'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      deletedAt: DateTime.fromMillisecondsSinceEpoch(map['deletedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory File.fromJson(String source) =>
      File.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'File(id: $id, filename: $filename, path: $path, size: $size, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(covariant File other) {
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
