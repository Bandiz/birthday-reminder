import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../calendar_state.dart';

class EditEventPage extends StatefulWidget {
  final String _title = 'Edit event';
  const EditEventPage({super.key});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
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
        DateTime.tryParse(_dateController.text) == null) {
      return;
    }
    context
        .read<CalendarState>()
        .addEvent(DateTime.parse(_dateController.text), _controller.text);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                  hintText: 'yyyy-MM-dd',
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
                  labelText: "Enter name",
                ),
              ),
              TextButton(
                onPressed: _onSavePressed,
                child: const Text('Save'),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
