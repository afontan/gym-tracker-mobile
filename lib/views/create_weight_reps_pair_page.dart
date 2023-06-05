import 'package:flutter/material.dart';
import 'package:gym_tracker/model/exercise_session.dart';
import 'package:gym_tracker/model/weight_reps_pair.dart';

import '../infrastructure/database_helper.dart';

class CreateWeightRepsPairPage extends StatefulWidget {
  final ExerciseSession exerciseSession;

  CreateWeightRepsPairPage({required this.exerciseSession});

  @override
  _CreateWeightRepsPairPageState createState() => _CreateWeightRepsPairPageState();
}

class _CreateWeightRepsPairPageState extends State<CreateWeightRepsPairPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Weight x Reps"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Weight (kg)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                hintText: "Enter weight",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade100, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text(
              "Reps",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _repsController,
              decoration: InputDecoration(
                hintText: "Enter reps",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade100, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text(
              "Sets",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _setsController,
              decoration: InputDecoration(
                hintText: "Enter sets",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade100, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveWeightRepsPair(),
        child: Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _saveWeightRepsPair() async {
    String weightString = _weightController.text.trim();
    String repsString = _repsController.text.trim();
    String setsString = _setsController.text.trim();
    double weight = double.tryParse(weightString) ?? 0;
    int reps = int.tryParse(repsString) ?? 0;
    int sets = int.tryParse(setsString) ?? 0;

    if (weight <= 0 || reps <= 0 || sets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Weight, reps, and sets should be greater than 0.")),
      );
      return;
    }

    for (int i = 0; i < sets; i++) {
      WeightRepsPair newWeightRepsPair = WeightRepsPair(
        exerciseSessionId: widget.exerciseSession.id!,
        weight: weight,
        repetitions: reps,
      );

      await DatabaseHelper.instance.insertWeightRepsPair(newWeightRepsPair);
    }
    await DatabaseHelper.instance.updateLastWeight(widget.exerciseSession.exerciseId);
    Navigator.pop(context);
  }

}
