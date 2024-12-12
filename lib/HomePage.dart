import 'package:flutter/material.dart';
import 'package:sql_lite_tut/data/local/db_helper.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> notes = [];
  DbHelper? myDb;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    myDb = DbHelper.getInstatnce;
    getNotes();
    super.initState();
  }

  getNotes() async {
    notes = await myDb!.getNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes App"),
        automaticallyImplyLeading: false,
      ),
      body: notes.isEmpty
          ? const Center(child: Text("No notes"))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(notes[index][myDb!.Col_title]),
                  subtitle: Text(notes[index][myDb!.Col_desc]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              titleController.text =
                                  notes[index][myDb!.Col_title];
                              descriptionController.text =
                                  notes[index][myDb!.Col_desc];
                              return NoteInputBottomSheet(
                                  titleController: titleController,
                                  descriptionController: descriptionController,
                                  getNotes: getNotes,
                                  update: true,
                                  index: notes[index][myDb!.Col_Sno]);
                            },
                          );
                          getNotes();
                        },
                        child: const Icon(Icons.edit),
                      ),
                      const SizedBox(width: 30),
                      InkWell(
                        onTap: () {
                          myDb!.deleteRecord(notes[index][myDb!.Col_Sno]);
                          getNotes();
                        },
                        child: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          titleController.clear();
          descriptionController.clear();
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return NoteInputBottomSheet(
                titleController: titleController,
                descriptionController: descriptionController,
                getNotes: getNotes,
                update: false,
                index: 0,
              );
            },
          );
        },
      ),
    );
  }
}

class NoteInputBottomSheet extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Function getNotes;
  final bool update;
  final int index;

  const NoteInputBottomSheet({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.getNotes,
    required this.update,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the content
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Ensure the column doesn't take the full height
        children: [
          const SizedBox(height: 20),
          TextFormField(
            style: const TextStyle(color: Colors.black),
            controller: titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue, // Set the color of the border
                  width: 2.0, // Set the width of the border
                ),
              ),
              hintText: "Title",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            style: const TextStyle(color: Colors.black),
            controller: descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue, // Set the color of the border
                  width: 2.0, // Set the width of the border
                ),
              ),
              hintText: "Description",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (update) {
                    DbHelper.getInstatnce.updateRecord(
                      title: titleController.text,
                      description: descriptionController.text,
                      sno: index,
                    );
                    // Refresh the notes
                  } else {
                    // Add the note to the database
                    DbHelper.getInstatnce.addNote(
                      title: titleController.text,
                      description: descriptionController.text,
                    );
                    // Refresh the notes

                    // Close the bottom sheet
                  }
                  titleController.clear();
                  descriptionController.clear();
                  getNotes();
                  Navigator.pop(context);
                  // Clear the controllers
                },
                child: const Text("Add"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Close the bottom sheet on cancel
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
