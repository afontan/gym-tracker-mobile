import 'package:flutter/material.dart';
import 'package:gym_tracker/model/exercise_session.dart';
import 'package:gym_tracker/model/session.dart';

import '../infrastructure/database_helper.dart';
import '../model/weight_reps_pair.dart';
import 'create_weight_reps_pair_page.dart';
import 'dart:developer';

class ExerciseSessionDetailsPage extends StatefulWidget {
  final ExerciseSession exerciseSession;
  final int sessionId;

  ExerciseSessionDetailsPage({required this.exerciseSession, required this.sessionId});

  @override
  _ExerciseSessionDetailsPageState createState() => _ExerciseSessionDetailsPageState();
}

class _ExerciseSessionDetailsPageState extends State<ExerciseSessionDetailsPage> {
  List<WeightRepsPair> _weightRepsPairs = [];
  Session? _session;

  @override
  void initState() {
    super.initState();
    _loadSession();
    _loadWeightRepsPairs();
  }

  Future<void> _loadWeightRepsPairs() async {
    List<WeightRepsPair> weightRepsPairs = await DatabaseHelper.instance.getWeightRepsPairsByExerciseSessionId(widget.exerciseSession.id!);
    setState(() {
      _weightRepsPairs = weightRepsPairs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Session Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeightRepsPairs,
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Date:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _session?.date ?? 'Loading...',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Exercise Name:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.exerciseSession.exerciseName ?? 'Unknown Exercise',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
            ..._buildWeightRepsPairsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateWeightRepsPair(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  List<Widget> _buildWeightRepsPairsList() {
    return _weightRepsPairs.map((weightRepsPair) {
      return Card(
        elevation: 4.0,
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade300,
                Colors.deepPurple.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set ${_weightRepsPairs.indexOf(weightRepsPair) + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '${weightRepsPair.weight} kg x ${weightRepsPair.repetitions} reps',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () => _showDeleteWeightRepsPairDialog(context, weightRepsPair),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _navigateToCreateWeightRepsPair(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWeightRepsPairPage(exerciseSession: widget.exerciseSession),
      ),
    );
    _loadWeightRepsPairs();
  }

  void _showDeleteWeightRepsPairDialog(BuildContext context, WeightRepsPair weightRepsPair) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Set"),
          content: Text("Are you sure you want to delete this set?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                await DatabaseHelper.instance.deleteWeightRepsPair(weightRepsPair.id!);
                await DatabaseHelper.instance.updateLastWeight(widget.exerciseSession.exerciseId);
                _loadWeightRepsPairs();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSession() async {
    final session = await DatabaseHelper.instance.getSessionById(widget.sessionId);
    setState(() {
      _session = session ?? Session(date: "date");
    });
  }

}
