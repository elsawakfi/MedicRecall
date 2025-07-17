import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> updateFlashcardTitles() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('flashcards');
  CollectionReference flashcardRef =
        FirebaseFirestore.instance.collection('flashcards');
  QuerySnapshot all =
        await flashcardRef.where("owner", isEqualTo: "all").get();

   for (var doc in all.docs) { //This loads all the cards during the dashboard screen loading process...
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final topic = data['topic'];
        final subtopic = data["subtopic"];
        
        
        if(topic is String && topic == "Coping with pressure"){
          if(subtopic == "Managing workload"){
            await collection.doc(doc.id).update({
            'subtopic': "Managing Worload",
           });
          }
        
        await collection.doc(doc.id).update({
        'topic': "Coping With Pressure",
        });

       if(topic == "Team working"){
        if(subtopic == "Working with senior colleagues"){
            await collection.doc(doc.id).update({
            'subtopic': "Working With Senior Colleagues",
           });
          }

          if(subtopic == "Working with the MDT"){
            await collection.doc(doc.id).update({
            'subtopic': "Working With The MDT",
           });
          }

          if(subtopic == "Working with junior colleagues"){
            await collection.doc(doc.id).update({
            'subtopic': "Working With Junior Colleagues",
           });
          }
        
        await collection.doc(doc.id).update({
        'topic': "Team Working",
      });}

       if(topic == "Patient focus"){

        if(subtopic == "Intimate examination"){
            await collection.doc(doc.id).update({
            'subtopic': "Intimate Examination",
           });
          }

        if(subtopic == "Maintaining patient focus"){
            await collection.doc(doc.id).update({
            'subtopic': "Maintaining Patient Focus",
           });
          }
     await collection.doc(doc.id).update({
        'topic': "Patient Focus",
      });
    }

    if (topic == "Confidentiality"){
      if(subtopic == "Child protection rules"){
            await collection.doc(doc.id).update({
            'subtopic': "Child Protection Rules",
           });
          }
    }
    
    if(topic == "Acting within your remit"){
     await collection.doc(doc.id).update({
        'topic': "Acting Within Your Remit",
      });
    }

     if(topic == "Commitment to professionalism"){
      if(subtopic == "Social media"){
            await collection.doc(doc.id).update({
            'subtopic': "Social Media",
           });
          }

       if(subtopic == "Clinical incidents"){
            await collection.doc(doc.id).update({
            'subtopic': "Clinical Incidents",
           });
          }
     
     await collection.doc(doc.id).update({
        'topic': "Commitment To Professionalism",
      });
    }

     if(topic == "Effective communication"){
     await collection.doc(doc.id).update({
        'topic': "Effective Communication",
      });
    }
      }
    }
   }
}

String _toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}