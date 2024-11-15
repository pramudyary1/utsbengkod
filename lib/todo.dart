import 'package:drift/drift.dart';
import 'package:uts_aplication_busettt/data/database.dart';

class Todo {
  final int id;
  final String title;
  final String detail;

  Todo({
    required this.id,
    required this.title,
    required this.detail,
  });

  // Konversi dari database model ke aplikasi model
  factory Todo.fromDatabaseModel(Todo data) {
    return Todo(
      id: data.id,
      title: data.title,
      detail: data.detail,
    );
  }

  // Konversi dari aplikasi model ke database model
  TodosCompanion toDatabaseModel() {
    return TodosCompanion(
      id: Value(id),
      title: Value(title),
      detail: Value(detail),
    );
  }
}
