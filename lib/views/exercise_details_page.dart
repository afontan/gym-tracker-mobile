import 'package:flutter/material.dart';
import 'package:gym_tracker/model/exercise.dart';
import 'package:gym_tracker/model/exercise_session.dart';

import '../infrastructure/database_helper.dart';
import 'exercise_session_detail_page.dart';
import 'dart:io';


class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailPage({Key? key, required this.exercise}) : super(key: key);

  @override
  _ExerciseDetailPageState createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  List<ExerciseSession> exerciseSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchExerciseSessionsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(widget.exercise),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.exercise.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade600),
              ),
            ),
            _buildExerciseSessionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Exercise exercise) {
    return Container(
      height: 200,
      child: Stack(
        children: [
          // Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade300,
                  Colors.deepPurple.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Image
          Positioned.fill(
            child: exercise.imageUrl.isNotEmpty
                ? Image.file(
              File(exercise.imageUrl),
              fit: BoxFit.cover,
            )
                : const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildExerciseSessionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exerciseSessions.length,
      itemBuilder: (context, index) {
        final exerciseSession = exerciseSessions[index];
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
                    Colors.deepPurple.shade200,
                    Colors.deepPurple.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                title: Text(
                  'Session ${exerciseSession.sessionId}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(
                  'ExerciseSession ID: ${exerciseSession.id}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToExerciseSessionDetails(BuildContext context, ExerciseSession exerciseSession) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseSessionDetailsPage(exerciseSession: exerciseSession, sessionId: exerciseSession.sessionId),
      ),
    );
    _fetchExerciseSessionsFromDatabase();
  }

  Future<void> _fetchExerciseSessionsFromDatabase() async {
    List<ExerciseSession> eexerciseSessions = await DatabaseHelper.instance.getExerciseSessionsByExerciseId(widget.exercise.id!);
    setState(() {
      exerciseSessions = eexerciseSessions;
    });
  }
}
