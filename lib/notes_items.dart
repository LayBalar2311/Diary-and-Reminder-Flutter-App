import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:diary/addNoteScreen.dart';
import 'package:diary/models/notes.dart';
import 'package:diary/reposetry/notes_reposetry.dart';
import 'package:intl/intl.dart';

class Items extends StatefulWidget {
  final Notes notes;
  final Function onNoteDeleted;

  const Items({Key? key, required this.notes, required this.onNoteDeleted})
      : super(key: key);

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.notes.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) {
        _deleteNote();
      },
      child: GestureDetector(
        onDoubleTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddNoteScreen(
                notes: widget.notes,
              ),
            ),
          );
        },
        onLongPress: () {
          _showDeleteConfirmationDialog(context);
        },
        child: Container(
          padding: EdgeInsets.all(15.0),
          margin: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Color.fromARGB(255, 214, 195, 195),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 178, 178),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.MMM().format(widget.notes.createdAt),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      DateFormat.d().format(widget.notes.createdAt),
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.notes.createdAt.year.toString(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.notes.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat.Hm().format(widget.notes.createdAt),
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black), // Custom text style
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      widget.notes.description,
                      style: TextStyle(fontWeight: FontWeight.w300),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showDeleteConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Note?"),
          content: Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Fluttertoast.showToast(
                  msg: "Note Deleted successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey[700],
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                await _deleteNote();
                // After deletion, trigger a rebuild of the widget
                widget.onNoteDeleted(); // Call the callback function
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote() async {
    await NotesRepository.deleteNotes(notes: widget.notes);
  }
}
