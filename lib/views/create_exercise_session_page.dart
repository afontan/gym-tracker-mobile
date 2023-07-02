import 'package:flutter/material.dart';
import 'package:gym_tracker/model/exercise.dart';
import 'package:gym_tracker/model/exercise_session.dart';
import 'package:gym_tracker/model/session.dart';

import '../infrastructure/database_helper.dart';

class CreateExerciseSessionPage extends StatefulWidget {
  final Session session;

  CreateExerciseSessionPage({required this.session});

  @override
  _CreateExerciseSessionPageState createState() =>
      _CreateExerciseSessionPageState();
}

class _CreateExerciseSessionPageState extends State<CreateExerciseSessionPage> {
  List<Exercise> _exercises = [];
  Exercise? _selectedExercise;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    List<Exercise> exercises = await DatabaseHelper.instance.getExercises();
    setState(() {
      _exercises = exercises;
    });
  }

  Future<void> _saveExerciseSession() async {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an exercise.")),
      );
      return;
    }

    ExerciseSession exerciseSession = ExerciseSession(
      sessionId: widget.session.id!,
      exerciseId: _selectedExercise!.id!,
      exerciseName: _selectedExercise!.name,
      weightRepsPairs: [], // Initialize with an empty list
    );

    await DatabaseHelper.instance.insertExerciseSession(exerciseSession);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise Session'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select an exercise:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.deepPurple.shade200,
                  width: 1.0,
                ),
              ),
              child: DropdownButton<Exercise>(
                value: _selectedExercise,
                items: _exercises.map((exercise) {
                  return DropdownMenuItem<Exercise>(
                    value: exercise,
                    child: Text(exercise.name),
                  );
                }).toList(),
                onChanged: (Exercise? newValue) {
                  setState(() {
                    _selectedExercise = newValue;
                  });
                },
                isExpanded: true,
                dropdownColor: Colors.deepPurple.shade50,
                underline: const SizedBox.shrink(),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            // Add more fields and widgets for the ExerciseSession here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveExerciseSession,
        child: const Icon(Icons.check),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
