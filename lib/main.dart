import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gym_tracker/views/create_exercise_page.dart';
import 'package:gym_tracker/views/create_session_page.dart';
import 'package:gym_tracker/views/exercise_details_page.dart';
import 'package:gym_tracker/views/session_details_page.dart';

import 'infrastructure/database_helper.dart';
import 'model/exercise.dart';
import 'model/session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Training Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Gym Training Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<Exercise> _exercises = [];
  final List<Session> _sessions = [];

  // Exercise search
  List<Exercise> _filteredExercises = [];
  TextEditingController _searchController = TextEditingController();

  // Session search
  List<Session> _filteredSessions = [];
  final TextEditingController _searchControllerSessions = TextEditingController();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _fetchExercisesFromDatabase();
    _fetchSessionsFromDatabase();
  }


  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gym Tracker"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _purgeDatabase,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Exercises"),
            Tab(text: "Sessions"),
          ],
          indicatorColor: Colors.deepPurple,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _fetchExercisesFromDatabase,
            child: Column(
              children: [
                _buildExerciseSearchBar(),
                Expanded(child: _buildExercisesList()),
              ],
            ),
          ),
          RefreshIndicator(
            onRefresh: _fetchSessionsFromDatabase,
            child: Column(
              children: [
                _buildSearchBarSessions(),
                Expanded(child: _buildSessionsList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController!.index == 0) {
            _navigateToCreateExercise(context);
          } else {
            _navigateToCreateSession(context);
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),

    );
  }

  Widget _buildExercisesList() {
    return ListView.builder(
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        return InkWell(
          onTap: () => _navigateToExerciseDetails(context, exercise),
          child: Card(
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
                    Colors.deepPurple.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  exercise.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(exercise.imageUrl),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(Icons.image_not_supported, size: 80, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${exercise.name} - ${exercise.lastWeight ?? "N/A"} kg",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _showExerciseDeleteConfirmationDialog(context, exercise),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search exercises',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2.0),
          ),
          prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        onChanged: (value) => _filterExercises(value),
      ),
    );
  }

  Future<void> _showExerciseDeleteConfirmationDialog(BuildContext context, Exercise exercise) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: Text('Are you sure you want to delete "${exercise.name}"?'),
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
                await DatabaseHelper.instance.deleteExercise(exercise.id!);
                setState(() {
                  _exercises.remove(exercise);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSessionsList() {
    return ListView.builder(
      itemCount: _filteredSessions.length,
      itemBuilder: (context, index) {
        final session = _filteredSessions[index];
        return InkWell(
          onTap: () => _navigateToSessionDetails(context, session),
          child: Card(
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
                    session.date,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _showSessionDeleteConfirmationDialog(context, session),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBarSessions() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchControllerSessions,
        decoration: InputDecoration(
          labelText: 'Search sessions',
          hintText: 'Enter session date',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2.0),
          ),
          prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        onChanged: (value) {
          _filterSessions(value);
        },
      ),
    );
  }

  Future<void> _showSessionDeleteConfirmationDialog(BuildContext context, Session session) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: Text('Are you sure you want to delete the session on "${session.date}"?'),
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
                await DatabaseHelper.instance.deleteSession(session.id!);
                setState(() {
                  _sessions.remove(session);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToExerciseDetails(BuildContext context, Exercise exercise) async {
    // Fetch ExerciseSessions associated with the selected exercise
    // Implement a method in your DatabaseHelper to fetch ExerciseSessions by exerciseId
    final exerciseSessions = await DatabaseHelper.instance.getExerciseSessionsByExerciseId(exercise.id!); // Replace this with the fetched data

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailPage(
          exercise: exercise,
        ),
      ),
    );
  }

  void _navigateToSessionDetails(BuildContext context, Session session) async {
    final updatedSession = await Navigator.push<Session>(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailsPage(session: session),
      ),
    );

    if (updatedSession != null) {
      setState(() {
        int index = _sessions.indexWhere((s) => s.id == updatedSession.id);
        _sessions[index] = updatedSession;
      });
    }
  }


  void _navigateToCreateExercise(BuildContext context) async {
    final newExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateExercisePage(),
      ),
    );

    if (newExercise != null) {
      setState(() {
        _exercises.add(newExercise);
      });
      _fetchExercisesFromDatabase();
    }
  }

  Future<void> _fetchExercisesFromDatabase() async {
    final exercises = await DatabaseHelper.instance.getExercises();
    setState(() {
      _exercises.clear();
      _exercises.addAll(exercises);
      _filteredExercises = exercises;
    });
  }

  void _navigateToCreateSession(BuildContext context) async {
    final newSession = await Navigator.push<Session>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSessionPage(),
      ),
    );

    if (newSession != null) {
      setState(() {
        _sessions.add(newSession);
      });
    }
    _fetchSessionsFromDatabase();
  }

  Future<void> _fetchSessionsFromDatabase() async {
    final sessions = await DatabaseHelper.instance.getSessions();
    setState(() {
      _sessions.clear();
      _sessions.addAll(sessions);
      _filteredSessions = _sessions;
    });
  }

  void _filterExercises(String query) {
    final filteredExercises = _exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredExercises = filteredExercises;
    });
  }

  void _filterSessions(String query) {
    final filteredSessions = _sessions.where((session) {
      return session.date.toLowerCase().contains(RegExp(".*${query.toLowerCase()}.*"));
    }).toList();

    setState(() {
      _filteredSessions = filteredSessions;
    });
  }

  Future<void> _purgeDatabase() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Purge Database"),
          content: Text("Are you sure you want to purge the database?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Purge"),
              onPressed: () async {
                // Perform database purge operations here.
                await DatabaseHelper.instance.purgeDatabase();
                // Reload data after purging
                _fetchExercisesFromDatabase();
                _fetchSessionsFromDatabase();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

