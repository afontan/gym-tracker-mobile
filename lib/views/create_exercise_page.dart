import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../infrastructure/database_helper.dart';
import '../model/exercise.dart';

class CreateExercisePage extends StatefulWidget {
  final Exercise? exercise;

  const CreateExercisePage({Key? key, this.exercise}) : super(key: key);

  @override
  _CreateExercisePageState createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final _nameController = TextEditingController();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      if (widget.exercise!.imageUrl.isNotEmpty) {
        _imageFile = XFile(widget.exercise!.imageUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? "Create Exercise" : "Update Exercise"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Exercise Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter exercise name",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade100, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Exercise Image",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple.shade100, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _imageFile != null
                  ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                  : Icon(Icons.image_not_supported, size: 64),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _pickImageFromCamera(context),
                icon: Icon(Icons.camera_alt),
                label: Text("Take Photo"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveExercise,
        child: Icon(Icons.save),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        _imageFile = imageFile;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected.")),
      );
    }
  }

  Future<void> _saveExercise() async {
    String name = _nameController.text.trim();
    String imageUrl = _imageFile?.path ?? '';

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exercise name is required.")),
      );
      return;
    }

    if (widget.exercise == null) {
      // Create a new exercise and save it to the database
      Exercise newExercise = Exercise(name: name, imageUrl: imageUrl);
      var res = await DatabaseHelper.instance.insertExercise(newExercise);
    } else {
      // Update the existing exercise and save it to the database
      Exercise updatedExercise = Exercise(
        id: widget.exercise!.id,
        name: name,
        imageUrl: imageUrl,
      );
      await DatabaseHelper.instance.updateExercise(updatedExercise);
    }

    Navigator.pop(context);
  }
}
