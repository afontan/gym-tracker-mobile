import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gym_tracker/model/session.dart';

import '../infrastructure/database_helper.dart';

class CreateSessionPage extends StatefulWidget {
  final Session? session;

  const CreateSessionPage({Key? key, this.session}) : super(key: key);

  @override
  _CreateSessionPageState createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.session?.date != null
        ? DateFormat('yyyy-MM-dd').parse(widget.session!.date)
        : DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Session"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      hintText: 'Select session date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade200,
                          width: 1.0,
                        ),
                      ),
                    ),
                    initialValue: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveSession();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Create Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveSession() async {

    Session? res;
    if (widget.session == null) {
      // Create a new session and save it to the database
      Session newSession = Session(date: DateFormat('yyyy-MM-dd').format(_selectedDate));
      final id = await DatabaseHelper.instance.insertSession(newSession);
      res = Session(id: id, date: newSession.date);
    } else {
      // Update the existing session and save it to the database
      Session updatedSession = Session(
        id: widget.session!.id,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );
      await DatabaseHelper.instance.updateSession(updatedSession);
    }

    if (context.mounted) Navigator.pop(context, res);
  }

}
