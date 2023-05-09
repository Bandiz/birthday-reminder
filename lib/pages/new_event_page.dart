import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../calendar_state.dart';

class NewEventPage extends StatefulWidget {
  final String _title = 'New event';
  const NewEventPage({super.key});

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
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
                  decoration: InputDecoration(
                    labelText: 'Birthday date',
                    prefixIcon: InkWell(
                      onTap: () => _selectDate(context),
                      child: const Icon(Icons.calendar_today),
                    ),
                  )),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: "Enter name"),
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_controller.text.isEmpty) {
                    return;
                  }
                  context
                      .read<CalendarState>()
                      .addEvent(_selectedDate, _controller.text);

                  Navigator.of(context).pop();
                },
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
