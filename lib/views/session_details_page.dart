import 'package:flutter/material.dart';
import 'package:gym_tracker/model/exercise_session.dart';
import 'package:gym_tracker/model/session.dart';

import '../infrastructure/database_helper.dart';
import 'create_exercise_session_page.dart';
import 'exercise_session_detail_page.dart';

class SessionDetailsPage extends StatefulWidget {
  final Session session;

  SessionDetailsPage({required this.session});

  @override
  _SessionDetailsPageState createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends State<SessionDetailsPage> {
  List<ExerciseSession> _exerciseSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchExerciseSessionsFromDatabase();
  }

  Future<void> _fetchExerciseSessionsFromDatabase() async {
    List<ExerciseSession> exerciseSessions = await DatabaseHelper.instance.getExerciseSessionsBySessionId(widget.session.id!);
    setState(() {
      _exerciseSessions = exerciseSessions;
    });
  }

  // Session Detail Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Session Date:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                Text(
                  widget.session.date,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildExerciseSessionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateExerciseSession(context),
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

// Build Exercise Sessions List
  Widget _buildExerciseSessionsList() {
    return ListView.builder(
      itemCount: _exerciseSessions.length,
      itemBuilder: (context, index) {
        final exerciseSession = _exerciseSessions[index];
        return InkWell(
          onTap: () => _navigateToExerciseSessionDetails(context, exerciseSession),
          child: Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade300,
                    Colors.deepPurple.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${index + 1} - ${exerciseSession.exerciseName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _showDeleteExerciseSessionDialog(context, exerciseSession),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteExerciseSessionDialog(BuildContext context, ExerciseSession exerciseSession) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Exercise Session'),
          content: const Text('Are you sure you want to delete this exercise session?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await DatabaseHelper.instance.deleteExerciseSession(exerciseSession.id!);
                _fetchExerciseSessionsFromDatabase();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToExerciseSessionDetails(BuildContext context, ExerciseSession exerciseSession) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseSessionDetailsPage(exerciseSession: exerciseSession, sessionId: widget.session.id!),
      ),
    );
    _fetchExerciseSessionsFromDatabase();
  }

  void _navigateToCreateExerciseSession(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateExerciseSessionPage(session: widget.session),
      ),
    );

    // Reload ExerciseSession data when returning from the CreateExerciseSessionPage
    _fetchExerciseSessionsFromDatabase();
  }

}
