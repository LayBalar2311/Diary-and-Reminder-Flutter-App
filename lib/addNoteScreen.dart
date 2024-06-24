import 'package:diary/models/notes.dart';
import 'package:diary/reposetry/notes_reposetry.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddNoteScreen extends StatefulWidget {
  final Notes? notes;
  final VoidCallback? onNoteAddedOrUpdated; // Callback function

  const AddNoteScreen({Key? key, this.notes, this.onNoteAddedOrUpdated})
      : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();

  @override
  void initState() {
    if (widget.notes != null) {
      _title.text = widget.notes!.title;
      _description.text = widget.notes!.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 230, 169, 169),
        title: const Text("Add Notes"),
        actions: [
          TextButton(
            onPressed: widget.notes == null ? _insertNote : _updateNote,
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(
                hintText: "Enter Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: TextField(
                controller: _description,
                decoration: InputDecoration(
                  hintText: "Enter Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insertNote() async {
    if (_title.text.isEmpty || _description.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Title and Description cannot be empty.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    final note = Notes(
      title: _title.text,
      description: _description.text,
      createdAt: DateTime.now(),
    );

    int id = await NotesRepository.insert(notes: note);

    note.id = id; // Update the note object with the new id

    Fluttertoast.showToast(
      msg: "Note added successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0,
    );

    print(
        'Note added: id=$id, title=${note.title}, description=${note.description}');

    // Call the callback function to notify the parent widget (home page)
    widget.onNoteAddedOrUpdated?.call();

    Navigator.pop(context);
  }

  void _updateNote() async {
    final note = Notes(
      id: widget.notes!.id!,
      title: _title.text,
      description: _description.text,
      createdAt: widget.notes!.createdAt,
    );

    await NotesRepository.update(notes: note);

    Fluttertoast.showToast(
      msg: "Note updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0,
    );

    print(
        'Note updated: id=${note.id}, title=${note.title}, description=${note.description}');

    // Call the callback function to notify the parent widget (home page)
    widget.onNoteAddedOrUpdated?.call();

    Navigator.pop(context); // Close the AddNoteScreen after updating
  }

  _deleteNotes() async {
    await NotesRepository.deleteNotes(notes: widget.notes!);
    widget.onNoteAddedOrUpdated?.call();
    Navigator.pop(context);
  }
}
