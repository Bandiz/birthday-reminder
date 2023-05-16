import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../calendar_state.dart';

class EditEventPage extends StatefulWidget {
  final String _title = 'Edit event';
  final int eventId;
  const EditEventPage({super.key, required this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final TextEditingController _controller;
  late final TextEditingController _dateController;
  String? _dateErrorText;

  Future<void> _onDateIconTap() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDatePickerMode: DatePickerMode.year,
      initialDate: DateTime.now(),
      firstDate: DateTime.utc(1900, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _onDateChanged(String date) {
    setState(() {
      _validateDate(date);
    });
  }

  void _validateDate(String value) {
    if (value.isEmpty) {
      _dateErrorText = 'Date is required';
      return;
    }
    final dateTime = DateTime.tryParse(value);
    if (dateTime == null) {
      _dateErrorText = 'Invalid date format';
    } else {
      _dateErrorText = null;
    }
  }

  void _onSavePressed() {
    if (_controller.text.isEmpty ||
        _dateController.text.isEmpty ||
        _dateErrorText != null) {
      return;
    }
    context.read<CalendarState>().updateEvent(
        widget.eventId, _controller.text, DateTime.parse(_dateController.text));

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    final event = context.read<CalendarState>().getEvent(widget.eventId);
    _controller = TextEditingController(text: event.title);
    _dateController = TextEditingController(
        text: DateFormat("yyyy-MM-dd").format(event.date));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarState>(builder: (context, state, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget._title),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _dateController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'Birthday date',
                    hintText: '1999-01-07',
                    errorText: _dateErrorText,
                    prefixIcon: InkWell(
                      onTap: _onDateIconTap,
                      child: const Icon(Icons.calendar_today),
                    ),
                  ),
                  onChanged: _onDateChanged,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: "Event name",
                  ),
                ),
                TextButton(
                  onPressed: _onSavePressed,
                  child: const Text('Save'),
                ),
              ],
            )),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
