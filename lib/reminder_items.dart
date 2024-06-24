import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:diary/addReminderScreen.dart';
import 'package:diary/models/reminder.dart';
import 'package:diary/reposetry/reminder_reposetry.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ReminderItem extends StatefulWidget {
  final Reminder reminder;
  final VoidCallback? onReminderDeleted;

  const ReminderItem(
      {Key? key, required this.reminder, required this.onReminderDeleted})
      : super(key: key);

  @override
  _ReminderItemState createState() => _ReminderItemState();
}

class _ReminderItemState extends State<ReminderItem> {
  Timer? _timer;
  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    _checkExpiration();
  }

  @override
  void didUpdateWidget(covariant ReminderItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkExpiration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkExpiration() {
    if (widget.reminder.reminderDate != null &&
        widget.reminder.reminderTime != null) {
      DateTime reminderDateTime = DateTime(
        widget.reminder.reminderDate!.year,
        widget.reminder.reminderDate!.month,
        widget.reminder.reminderDate!.day,
        widget.reminder.reminderTime!.hour,
        widget.reminder.reminderTime!.minute,
      );

      setState(() {
        isExpired = DateTime.now().isAfter(reminderDateTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.reminder.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) {
        _deleteReminder();
      },
      child: GestureDetector(
        child: _buildReminderItem(),
      ),
    );
  }

  Widget _buildReminderItem() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 214, 195, 195),
      ),
      child: Row(
        children: [
          _buildReminderDateAndTime(),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReminderTitle(),
                SizedBox(height: 4),
                _buildReminderDescription(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderDateAndTime() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 178, 178),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.MMM().format(widget.reminder.createdAt),
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          Text(
            DateFormat.d().format(widget.reminder.createdAt),
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.reminder.createdAt.year.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.reminder.title,
            style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          DateFormat.Hm().format(widget.reminder.createdAt),
          style:
              TextStyle(fontSize: 14, color: Colors.black), // Custom text style
        ),
      ],
    );
  }

  Widget _buildReminderDescription() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        widget.reminder.description,
        style: TextStyle(fontWeight: FontWeight.w300),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(
        height: 10,
      ),
      if (widget.reminder.reminderDate != null &&
          widget.reminder.reminderTime != null)
        Row(
          children: [
            Icon(
              Icons.alarm,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                '${DateFormat('dd-MM-yyyy').format(widget.reminder.reminderDate!)} at ${widget.reminder.reminderTime!.format(context)}',
                style: isExpired ? TextStyle(color: Colors.red) : null,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isExpired)
              Text(
                ' (Expired)',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        )
    ]);
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Reminder?"),
          content: Text("Are you sure you want to delete this reminder?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteReminder() async {
    try {
      await ReminderRepository.delete(widget.reminder.id);
      // Show a success toast message
      Fluttertoast.showToast(
        msg: "Reminder deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Invoke the callback function if it's not null
      widget.onReminderDeleted?.call();
    } catch (error) {
      // Show an error toast message
      Fluttertoast.showToast(
        msg: "Failed to delete reminder: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
