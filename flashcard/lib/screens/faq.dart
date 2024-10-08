import 'dart:core';

import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawMain(),
        appBar: AppBar(
            title: Align(
              alignment: const Alignment(-0.05,0),
              child: Stack(
                children: [
                  Positioned(
                    top: 2.3,
                    child: Image.asset(
                      'assets/newlogo.png',
                      fit: BoxFit.cover,
                      height: 34,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 32),
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('FAQs',
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            leading: Builder(
                builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(
                        Icons.menu,
                      ),
                    ))),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              child: Center(
                                  child: Column(
                        children: const [
                          Text("FAQs..."),
                          Text(
                            "What is the forgetting curve?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "The forgetting curve is a concept in psychology that describes the rate at which information is forgotten over time. It was first introduced by German psychologist Hermann Ebbinghaus in the late 19th century and has been studied and confirmed by researchers since then. The forgetting curve demonstrates how, when we learn new information, we initially retain a large amount of it. However, over time, our retention of that information decreases unless we actively work to reinforce it. The rate of forgetting varies depending on a number of factors, such as the complexity of the information, the strength of our initial memory, and the amount of time that has elapsed since we learned the information. Research has shown that we typically forget a large percentage of what we learn within just 24 hours. However, if we actively work to reinforce the information, such as through spaced repetition or active recall, we can slow down the rate of forgetting and improve our long-term retention of the material.\n"),
                          Text(
                            "What is spaced repetition?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "Spaced repetition is a learning technique that involves reviewing information at increasing intervals of time in order to improve long-term retention. The idea behind spaced repetition is based on combating the effects of the forgetting curve. The intervals between review sessions are determined by an algorithm that takes into account how well you have learned the material. If you are able to recall the information easily, the algorithm will increase the interval between review sessions. If you struggle to recall the information, the algorithm will decrease the interval to ensure that you review the material more frequently.\n"),
                          Text(
                            "How does we use spaced repetition?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "We encourage users to revise one flashcard topic at a time, at spaced intervals. When users first see a new flashcard, they must rate whether they found the content difficult or easy. If they find the card difficult, it will re-appear before they finish that topic review. Once the user has correctly completed each flashcard in the topic, the topic will turn green, indicating that it has been successfully reviewed recently. Our algorithm will then schedule a second review of this topic at a spaced interval, indicated by the topic turning red. Over time, the intervals between reviews get longer as the user demonstrates mastery of the material. This allows the user to review the material less frequently as it becomes more firmly ingrained in their long-term memory.\n"),
                          Text(" What is active recall?\n",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              "Active recall is a learning technique that involves actively retrieving information from memory in order to reinforce and strengthen your understanding of a particular topic or concept. This is in contrast to passive review, which involves simply reading or reviewing information without actively engaging with it. The process of active recall typically involves asking yourself questions about the material you are trying to learn, then trying to answer those questions from memory. This could involve writing out answers to questions or practising with flashcards.Active recall is an effective learning technique because it helps to strengthen the neural pathways in your brain associated with the material you are trying to learn. By actively engaging with the material and recalling it from memory, you are reinforcing those neural pathways and making it easier to retrieve that information in the future. When active recall is used in conjunction with spaced repetition, you create a powerful and effective learning system that can help you retain information over the long term.\n"),
                          Text(
                            "What is concept mapping?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "Concept mapping is a learning strategy that involves creating a visual representation of the relationships between different concepts and ideas. It is a way to organise and structure information in a way that is easy to understand and remember.Concept mapping can be a powerful learning tool because it helps to identify the key concepts and relationships between them. By creating a visual representation of the material, you can see the relationships between different concepts in a way that is easier to understand and remember than simply reading or listening to information. We apply active recall to the SJT by breaking down the key domain tested in the exam into topics and subtopics to help the user compartmentalise their learning for easier recall. \n"),
                          Text(
                            "Can I add my own flashcards?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "Use our flashcard editor feature. You can create your own flashcard and have them seamlessly added to our existing decks. Make sure you are using reliable resources to create new flashcards!\n"),
                          Text(
                            "How do I use the calendar feature?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "We recommend that you use the calendar feature to schedule your revision around other commitments. First, input your exam date. Then, schedule sessions to complete and review the official past paper and PearsonVue unofficial mark scheme at spaced intervals.\n"),
                          Text(
                            "What is the discussion feature?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "Using this feature, you can collaborate with your colleagues, discussing the answers to flashcards and scenarios together.\n"),
                          Text(
                            "Any other questions?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "Please direct any issues or questions to medicrecall@gmail.com.\n"),
                          Text(
                            "Are you interested in the project? Want to get involved?\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "Email your CV and 200 words about yourself for medicrecall@gmail.com "),
                        ],
                      )))),
                    ]))));
  }
}
