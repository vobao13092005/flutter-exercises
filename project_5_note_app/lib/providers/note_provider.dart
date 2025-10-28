import 'package:flutter/material.dart';
import '../models/note.dart';
import 'package:uuid/uuid.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(String title, String content) {
    final newNote = Note(id: const Uuid().v4(), title: title, content: content);
    _notes.insert(0, newNote);
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = Note(id: id, title: title, content: content);
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  Note? getNoteById(String id) {
    return _notes.firstWhere(
      (note) => note.id == id,
      orElse: () => Note(id: '', title: '', content: ''),
    );
  }
}
