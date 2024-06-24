import 'dart:ffi';

import 'package:diary/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:diary/models/reminder.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:diary/reposetry/reminder_reposetry.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;
  final VoidCallback? onReminderAddedOrUpdated;

  const AddReminderScreen({
    Key? key,
    this.reminder,
    this.onReminderAddedOrUpdated,
  }) : super(key: key);

  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _reminderTitleController = TextEditingController();
  final _reminderDescriptionController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  TimeOfDay? selectedTime;
  DateTime? selectedDate;
  String timeButtonText = 'Set Time';
  String dateButtonText = 'Set Date';

  @override
  void initState() {
    if (widget.reminder != null) {
      _reminderTitleController.text = widget.reminder!.title;
      _reminderDescriptionController.text = widget.reminder!.description;
      selectedDate = widget.reminder!.reminderDate;
      selectedTime = widget.reminder!.reminderTime;
    }
    super.initState();
  }

  void _clearFields() {
    _reminderTitleController.clear();
    _reminderDescriptionController.clear();
    selectedDate = null;
    selectedTime = null;
    timeButtonText = 'Set Time';
    dateButtonText = 'Set Date';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (selectedDate != null) {
      dateButtonText = DateFormat('dd-MM-yyyy').format(selectedDate!);
    }
    if (selectedTime != null) {
      timeButtonText = selectedTime!.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedTime != null) {
      timeButtonText = selectedTime!.format(context);
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 230, 169, 169),
          title: const Text('Add Reminder'),
          actions: [
            TextButton(
              onPressed:
                  widget.reminder == null ? _insertReminder : _updateReminder,
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _buildTextField(
                controller: _reminderTitleController,
                hintText: 'Enter Title',
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _reminderDescriptionController,
                hintText: 'Enter Description',
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(
                      text: dateButtonText, onPressed: _showDatePicker),
                  _buildButton(
                      text: timeButtonText, onPressed: _showTimePicker),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Future<void> _insertReminder() async {
    // Validate inputs
    if (_reminderTitleController.text.isEmpty ||
        _reminderDescriptionController.text.isEmpty) {
      _showToast('Title and Description cannot be empty.');
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      _showToast('Please select both Time and Date.');
      return;
    }

    // Create a new reminder object
    final reminder = Reminder(
      title: _reminderTitleController.text,
      description: _reminderDescriptionController.text,
      createdAt: DateTime.now(),
      reminderDate: selectedDate,
      reminderTime: selectedTime,
    );

    final id = await ReminderRepository.insert(reminder);
    reminder.id = id;

    // Schedule notification for the reminder
    await _notificationService.scheduleNotification(
      id,
      reminder.title,
      reminder.description,
      DateTime(
          reminder.reminderDate!.year,
          reminder.reminderDate!.month,
          reminder.reminderDate!.day,
          reminder.reminderTime!.hour,
          reminder.reminderTime!.minute),
    );

    Fluttertoast.showToast(
      msg: "Reminder added successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0,
    );

    widget.onReminderAddedOrUpdated?.call();

    Navigator.pop(context);
  }

  Future<void> _updateReminder() async {
    // Update the reminder object
    final reminder = Reminder(
      id: widget.reminder!.id,
      title: _reminderTitleController.text,
      description: _reminderDescriptionController.text,
      createdAt: widget.reminder!.createdAt,
      reminderDate: selectedDate,
      reminderTime: selectedTime,
    );

    await ReminderRepository.update(reminder);

    _showToast('Reminder updated successfully!');

    // Notify the parent widget, if provided
    widget.onReminderAddedOrUpdated?.call();

    // Show a message and navigate back to the home screen

    Navigator.of(context).pop(); // Go back to the previous screen
  }

  Future<void> _showDatePicker() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      setState(() {
        selectedDate = newDate;
        dateButtonText = DateFormat('dd-MM-yyyy').format(newDate);
      });
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (newTime != null) {
      setState(() {
        selectedTime = newTime;
        timeButtonText = newTime.format(context);
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 17,
    );
  }

  @override
  void dispose() {
    _reminderTitleController.dispose();
    _reminderDescriptionController.dispose();
    super.dispose();
  }
}
