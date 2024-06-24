import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diary/addNoteScreen.dart' as NoteScreen;
import 'package:diary/notes_items.dart' as NotesItems;
import 'package:diary/addReminderScreen.dart' as ReminderScreen;
import 'package:diary/reminder_items.dart' as ReminderItems;
import 'package:diary/models/notes.dart';
import 'package:diary/models/reminder.dart';
import 'package:diary/reposetry/notes_reposetry.dart';
import 'package:diary/reposetry/reminder_reposetry.dart';
import 'package:diary/splash.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => splash(),
        '/home': (context) => DiaryHomePage(),
      },
    );
  }
}

class DiaryHomePage extends StatefulWidget {
  @override
  _DiaryHomePageState createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  int _currentIndex = 0;

  List<Notes> notesList = [];
  List<Reminder> reminderList = [];

  @override
  void initState() {
    super.initState();
    refreshNotes();
    refreshReminders();
  }

  Future<void> refreshNotes() async {
    List<Notes> updatedNotes = await NotesRepository.getNotes();
    setState(() {
      notesList = updatedNotes;
    });
  }

  Future<void> refreshReminders() async {
    List<Reminder> updatedReminders = await ReminderRepository.getReminders();
    setState(() {
      reminderList = updatedReminders;
    });
  }

  Widget buildNotesTab() {
    return RefreshIndicator(
      onRefresh: refreshNotes,
      child: notesList.isEmpty
          ? Center(child: Text("No notes available."))
          : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                Notes note = notesList[index];
                return NotesItems.Items(
                  notes: note,
                  onNoteDeleted: refreshNotes,
                );
              },
            ),
    );
  }

  Widget buildReminder() {
    return RefreshIndicator(
      onRefresh: refreshReminders,
      child: reminderList.isEmpty
          ? Center(child: Text("No Reminder available."))
          : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: reminderList.length,
              itemBuilder: (context, index) {
                Reminder reminder = reminderList[index];
                return ReminderItems.ReminderItem(
                  reminder: reminder,
                  onReminderDeleted: refreshReminders,
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 244, 169, 169),
        title: Text(_currentIndex == 0 ? "Diary" : "Reminders"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => (_currentIndex == 0
                ? _showDeleteAllNotesConfirmationDialog(context)
                : _showDeleteAllReminderConfirmationDialog(context)),
          ),
        ],
        centerTitle: true,
      ),
      body: _currentIndex == 0 ? buildNotesTab() : buildReminder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result;
          if (_currentIndex == 0) {
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteScreen.AddNoteScreen(
                  onNoteAddedOrUpdated: refreshNotes,
                ),
              ),
            );
            if (result == true) {
              refreshNotes();
            }
          } else {
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReminderScreen.AddReminderScreen(
                  onReminderAddedOrUpdated: refreshReminders,
                ),
              ),
            );
            if (result == true) {
              refreshReminders();
            }
          }
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 212, 156, 156),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 243, 241, 241),
        selectedItemColor: Colors.black,
        unselectedItemColor: Color.fromARGB(255, 150, 147, 147),
        showSelectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.note_add_rounded), label: "Diary"),
          BottomNavigationBarItem(
              icon: Icon(Icons.alarm_add), label: "Reminders"),
        ],
      ),
    );
  }

  Future<void> _showDeleteAllNotesConfirmationDialog(
      BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete All Notes?"),
          content: Text("Are you sure you want to delete all notes?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await NotesRepository.deleteAllNotes();
                refreshNotes(); // Refresh notes after deletion
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAllReminderConfirmationDialog(
      BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete All Reminder?"),
          content: Text("Are you sure you want to delete all Remiders?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await ReminderRepository.deleteAllReminders();
                refreshReminders(); // Refresh notes after deletion
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
