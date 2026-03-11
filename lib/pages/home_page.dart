import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open note box
  void openNoteBox(BuildContext context , String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(controller: textController),
        actions: [
          ElevatedButton(
            onPressed: () {

              if(docID == null){
                firestoreService.addNote(textController.text);
              }
              else{
                firestoreService.updateNote(docID, textController.text);
              }

              textController.clear();

              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose(); // important
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note app')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(context , null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String DOC_ID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String note = data['note'];

                return ListTile(
                  title: Text(note),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //update button
                      IconButton(
                      onPressed: () => openNoteBox(context , DOC_ID),
                      icon: const Icon(Icons.settings),
                      ),
                      //delete button
                      IconButton(
                      onPressed: () => firestoreService.deleteNote(DOC_ID),
                      icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('An error occurred'));
          }
          // if there is no data
        },
      ),
    );
  }
}
