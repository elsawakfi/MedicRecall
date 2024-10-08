import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

class FolderGridView extends StatelessWidget {
  final CollectionReference flashcards =
      FirebaseFirestore.instance.collection('flashcards');

  FolderGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.cyan[800],
        // elevation: 0,
        title: const Text("Folders"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () =>
              Navigator.popUntil(context, ModalRoute.withName(HomePage.id)),
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: StreamBuilder<dynamic>(
          stream: flashcards.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  // text for icons
                  // icons
                  return Container(
                    padding: const EdgeInsets.all(8),
                    // 3
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 4
                        Expanded(
                          // 5
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/folder_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // 6
                        const SizedBox(height: 10),
                        // 7
                        Text(
                          snapshot.data.docs[index]['topic'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        Text(
                          snapshot.data.docs[index]['subtopic'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
