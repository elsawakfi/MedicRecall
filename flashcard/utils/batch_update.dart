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
            'subtopic': "Managing Your Workload",
           });
          }

          if(subtopic == "Apology"){
            await collection.doc(doc.id).update({
            'subtopic': "Complaints",
           });
          }

           if(subtopic == "Handover"){
            await collection.doc(doc.id).update({
            'subtopic': "Personal and Staff Wellbeing",
           });
          }

          if(subtopic == "High-pressure scenarios"){
            await collection.doc(doc.id).delete();
            continue;
          }
        
        await collection.doc(doc.id).update({
        'topic': "Coping With Pressure",
        });}

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

          if(subtopic == "Common teamworking scenarios"){
            await collection.doc(doc.id).delete();
            continue;
          }
        
        await collection.doc(doc.id).update({
        'topic': "Team Working",
      });}

       if(topic == "Patient focus"){

        if(subtopic == "Intimate examination"){
            await collection.doc(doc.id).update({
            'subtopic': "Empathy and Sensitivity",
           });
          }

        if(subtopic == "Maintaining patient focus"){
            await collection.doc(doc.id).update({
            'subtopic': "Maintaining Patient Focus",
           });
          }
        if (subtopic == "Mental capacity"){
          await collection.doc(doc.id).update({
            'subtopic': "Mental Capacity Act"
          });
        }

        if(subtopic == "DNACPR"|| subtopic == "Driving"){
          await collection.doc(doc.id).delete();
          continue;
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
     if (subtopic == "Consent for procedures"){
      await collection.doc(doc.id).update({
        'subtopic': 'Procedures'
      });
      //Need to move consent questions to effective commmunication
     }

     if(subtopic == "Bleep"||subtopic == "Jobs"||subtopic == "Who's Who"){
      await collection.doc(doc.id).delete();
      continue;
      //delete empty topics
     }

     if (subtopic == "Discharge"){
      await collection.doc(doc.id).update({
        'subtopic': 'Discharging Patients'
      });
     }
     
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

        if(subtopic == "Staffing"|| subtopic == "Professional practice"){
          await collection.doc(doc.id).delete();
          continue;
        }

        if(subtopic == "Maintaining patient-doctor boundaries"){
          await collection.doc(doc.id).update({
            'subtopic': 'Maintaining the Doctor-Patient Relationship'
          });
        }
     
     await collection.doc(doc.id).update({
        'topic': "Professional Integrity",
      });
    }

    if(topic == "Effective communication"){
    await collection.doc(doc.id).update({
        'topic': "Effective Communication",
      });
    
    }
    
    if (topic == "Confidentiality"){
      if(subtopic == "Child protection rules"){
        await collection.doc(doc.id).update({
          'subtopic': 'Child Protection Guidlines'
        });
      }
    }
      }
    }
   }
