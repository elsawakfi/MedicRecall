import 'dart:core';

import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';


class Information extends StatelessWidget {
  const Information({Key? key}) : super(key: key);

  /*
    AnimationController controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );


   */


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawMain(),
        appBar: AppBar(
          // backgroundColor: Colors.blue,
            elevation: 0,
            title:  Align(
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
                    child: const Text('Professional Dilemmas Revision Guide',
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
                  Container(
                      width: double.infinity,
                      height: 130,
                      margin: const EdgeInsets.only(
                          bottom: 10.0, left: 30.0, right: 30.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                          child: SingleChildScrollView(
                            // allow for scrolling if its a long question
                            child: Center(
                                child: Text(
                                    "Our comprehensive revision guide for success in the Professional Dilemmas paper.",
                                    //get the question from the map
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                      fontSize: 20,
                                    ))),
                          ))),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // const Text(
                              //     "Our comprehensive, section-by-section, step-by-step guide for success in the SJT.\n",
                              //     style: TextStyle(
                              //       fontSize: 20,
                              //       color: Colors.black,
                              //     )),
                                Text(
                                  "We want to help students to score well in the SJT by helping them use the right resources in the right way. We do this by harnessing the benefits of spaced repetition and active recall when revising material taken exclusively from UKFPO or GMC guidelines.",
                                  style: TextStyle(fontSize: 20,color:  Theme.of(context).textTheme.titleMedium?.color ?? Colors.black )),
                              const SizedBox(height: 20),
                               Text("Can you revise for the Professional Dilemmas paper?",
                                  style: TextStyle(fontSize: 35, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,)),
                              const SizedBox(height: 20),
                               Text(
                                  "Many trainees believe it is impossible to revise for situational judgement tests such as the Professional Dilemmas paper and that only good luck or common sense can make you perform well compared to your peers. Although the answers to scenarios in the Professional Dilemmas paper can seem subjective, trainees can prepare effectively by using the right resources in the right way. \n\nThe Professional Dilemmas paper uses common scenarios you will encounter in FY2. You are tested on your ability to recognise the most important issues in each scenario and find the best, most direct and timely solution. By closely studying the guidance released by the UKFPO, HEE and GMC, you can learn how these governing bodies would like their doctors to tackle issues and balance their professional responsibilities when faced with complex clinical scenarios. \n\nCandidates must have a good understanding of common scenarios and a bank of general principles which are aligned with the UKFPO, GMC and HEE. On exam day, the candidate must apply this knowledge to each unique scenario in the exam. Therefore, we recommend that candidates closely study the material produced by these governing bodies and internalise their rationales. By using the correct resources, even if you are faced with an ambiguous scenario, you can fall back on the UKFPO and GMC values and score highly. \n\nTherefore, yes, you can revise for the situational judgement exams.",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,)),
                              const SizedBox(height: 20),
                              Image.asset(('assets/graph.png'),
                                  height: 500, fit: BoxFit.contain),
                              const SizedBox(height: 20),
                              const Divider(height: 20, thickness: 5),
                               Text("How to use the right resources in the right way? ",
                                  style: TextStyle(fontSize: 35, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                              Text(
                                  "Our platform is designed to help you use the right resources in the right way. We achieve this by presenting the content produced by the UKFPO, HEE and GMC in a way that maximises content recall, using the evidence-based techniques of active recall, spaced repetition, interleaved study and concept mapping. \n\nThe following study guide is broken down resource by resource for success in the Professional Dilemmas paper:",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                               Text("Rating Questions – 18 scenarios /456 marks",
                                  style: TextStyle(fontSize: 28, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                               Text(
                                "This section asks you to rate the appropriateness of an action given a particular clinical scenario. This section was only introduced in 2022, meaning there are limited official recourses and practice questions on this section. Due to the small set of official past paper questions in this format released by the UKFPO, using the Pearson Vue test paper with our unofficial mark scheme is the best way to prepare for these questions. The section consists of 18 scenarios, each with 4-8 responses to that scenario that your need to rank the appropriateness for.\n\nYou should judge each action as a separate entity, do not compare an answer to others from the same scenario. You score a maximum of 4 points for rating each action and will lose one mark for each step away from the correct answer. For example, if the correct answer is very appropriate and you answer your answer is somewhat inappropriate, you would score 2/4 (see the table below).",
                                style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                              ),
                              const SizedBox(height: 20),
                              DataTable(columns:  [
                                const DataColumn(label: Text("")),
                                const DataColumn(label: Text("")),
                                DataColumn(
                                    label: Text(
                                      "Answer Given",
                                      style: TextStyle(
                                          color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                                const DataColumn(label: Text("")),
                                const DataColumn(label: Text("")),
                              ], rows:  [
                                DataRow(cells: [
                                  DataCell(Text("Ideal Answer", style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("Very Appropriate",style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("Somewhat Appropriate", style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("Somewhat Inappropriate", style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("Inappropriate", style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("Very Appropriate", style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('1', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)))
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("Somewhat Appropriate", style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)))
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("Somewhat Inappropriate", style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)))
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("Inappropriate" , style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('1', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                    color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)))
                                ])
                              ]),
                              const SizedBox(height: 20),
                               Text(
                                  "Response breakdown:\n\nVery appropriate\nIt is important to note that any given scenario can have several responses that are very appropriate. Each action does not need to address all aspects of the scenario; if it tackles one important issue correctly, this is enough for a very appropriate answer. Therefore, for an answer to be very appropriate, the action must be a positive, appropriate act that handles at least one important aspect of the scenario in a direct and timely manner with no significant downside.\n\nSomewhat appropriate / somewhat inappropriate\nIt is often difficult to decide between somewhat appropriate and somewhat inappropriate. Here, you need to weigh up the positives and negatives of the response. If it has more positives than drawbacks, then it is somewhat appropriate. Actions that fall into the somewhat appropriate section are often answers that tackle an important issue in the scenario but have some minor drawbacks (e.g. the response is not as empathetic or diplomatic as it could be). Somewhat inappropriate responses can be thought of as a well-meaning attempt to solve the problem in the stem, but this is the wrong way to approach the situation. Therefore, these answers have several drawbacks that outweigh the positives, making the answer somewhat inappropriate. Additionally, if the action is again well intended but fails to address the urgent or important issue in the scenario, this may also be somewhat inappropriate.\n\nInappropriate\nInappropriate responses to answers can be relatively easy to identify.\nResponses are inappropriate if they are either:\n-    Directly against GMC guidance\n-    Will make the situation worse rather than better\n-    Ignore the issue at hand / are entirely unhelpful (e.g. asking for general advice from your registrar about how to request scans when your request for an urgent scan for an unwell patient has been rejected. This will not help you in any way to solve the problem, which is getting the urgent scan completed, so it is inappropriate).",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,)),
                              const SizedBox(height: 20),
                               Text(
                                  "Multiple Choice Questions - 19 scenarios /228 marks",
                                  style: TextStyle(fontSize: 28, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                               Text(
                                  "In the multiple-choice section, you must pick 3 actions out of 8 which together constitute the best way to deal with the issues raised by the scenario you are given. You score 4 points for each option you get correctly, making each scenario worth 12 points. There are 19 scenarios in this section. The key to approaching this section is to think of the 3 actions as if they are taken together and not individually. This differs from the rating and ranking sections, where each option should be judged as a stand-alone action. When doing these questions, think, ‘I would do option A AND option C AND option F to best solve this scenario. Because these options are taken together, one tactic for approaching these questions is grouping together options that address the same part of the scenario. You can then pick the best option from each group and rule out the other options to narrow down answers. This can be a very effective way of approaching this section.\n\nExample Scenario: You are an FY1 on a busy respiratory ward, working with two other FY1s. You feel that the workload is not being shared appropriately between you and that you are being left with all the ward jobs e.g. discharge summaries and the other FY1s are able to work on audit projects and observe procedures such as chest drains.\nChoose the THREE most appropriate actions to take in this situation.\nA. Organise a meeting with the other FY1s and the lead consultant on the surgical ward about this issue.\nB. Discuss the situation with your speciality trainee (registrar) to ask for advice.\nC. Refuse to do any more discharge summaries until the workload is shared more evenly.\nD. Speak to the lead consultant if it continues after you have raised the issue with your FY1 colleagues.\nE. Approach both FY1 colleagues about this issue and ask for their perspectives.\nF Ask your educational supervisor to speak with the FY1s about the issue.\nG. Ask the FY1s to complete some of your discharge summaries to even the workload\nH. Speak to a friend working on another ward about the situation.\n\nSeveral of these actions can be grouped together:\nGroup 1:\nA. Organise a meeting with the other FY1s and the lead consultant on the surgical ward about this issue.\nE. Approach both FY1 colleagues about this issue and ask for their perspectives.\nGroup 2:\nB. Discuss the situation with your speciality trainee (registrar) to ask for advice.\nH. Speak to a friend working on another ward about the situation.\nGroup 3:\nD. Speak to the lead consultant if it continues after you have raised the issue with your FY1 colleagues.\nF Ask your educational supervisor to speak with the FY1s about the issue.\nGroup 4:\nC. Refuse to do any more discharge summaries until the workload is shared more evenly.\nG. Ask the FY1s to complete some of your discharge summaries to even the workload\n\nGroup 1 – Both options here are asking for a meeting with your colleagues to address this problem (an appropriate thing to do). However, it would be more appropriate at this stage to resolve this issue directly with just the FY1s. If this can be solved amongst yourselves, there is no need to involve the consultant and escalate the scenario unnecessarily – making E the best option in this group.\n\nGroup 2 – Each option is about who you should get advice from. Speaking with your speciality trainee for advice is a better option than a friend. Your speciality trainee will have a much better insight into your team dynamics and how jobs should be allocated, making them the better person to get advice from.\n\nGroup 3 – These options are about escalating this issue to a senior. You should raise this with your consultant if this continues despite appropriate intervention. This is more appropriate than getting your educational supervisor to intervene before you have attempted to fix the problem (your consultant is also better placed than your educational supervisor to address this issue).\n\nGroup 4 – These answers do not fall into an obvious group. Still, you should be able to identify these as incorrect answers, especially as you have already identified three good answers that can be taken together. You should not address the problem by being passive-aggressive (G) or going on strike until things change (C).\n\nYou can then check your answer by using AND between each option. ‘I would approach the FY1s directly AND Discuss the situation with your speciality trainee (registrar) to ask for advice AND Speak to the lead consultant on the surgical ward if it continues after the meeting’. These options fit together well and address the problem at hand. Therefore, we can reason that the answer is EBD.",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                               Text("Ranking questions – 38 scenarios /760 marks",
                                  style: TextStyle(fontSize: 28, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                               Text(
                                  "This section of the paper contains the most marks. Each of the 38 ranking scenarios is worth 20 marks (760 marks total). Therefore, it is very important that you have a system that allows you to score highly on these questions consistently. For these questions, you are asked to rank five different options in order of importance or appropriateness given a particular scenario. You get 4 points for each option placed in the correct order. These questions are marked as follows…",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                              DataTable(columns:  [
                                const DataColumn(label: Text("")),
                                const DataColumn(label: Text("")),
                                DataColumn(
                                    label: Text(
                                      "Answer Given",
                                      style: TextStyle(
                                          color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                                const DataColumn(label: Text("")),
                                const DataColumn(label: Text("")),
                                const DataColumn(label: Text("")),
                              ], rows:  [
                                DataRow(cells: [
                                  DataCell(Text("Ideal Answer", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("A", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("B", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("C", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("D", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text("E", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("A", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('1', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('0', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)))
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("B", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('1', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)))
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("C", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)))
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("D", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('1', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text("E", style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('0', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('1', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('2', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('3', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black))),
                                  DataCell(Text('4', style: TextStyle(
                                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)))
                                ])
                              ]),
                              const SizedBox(height: 20),
                               Text(
                                  "For example, if the ideal answer was ABCDE and you put ACDBE, you would score – 4+3+3+2+4 = 16.\n\nA good way to approach these questions is to first identify the key problem in the scenario, e.g. patient safety. Once you have identified this, you can rank the options that aim to address the core problem higher than other options that either miss the point of the scenario or only tackle an unimportant or non-urgent issue.\n\nAnother high-yield strategy is getting into the habit of correctly identifying the most appropriate and least appropriate option first. If you can do this because of the way that these questions are marked, you will score a minimum of 16/20. Consistently identifying the best and worse option come exam day will put you in a great position to achieve top marks. Once you have dragged these options into their positions, you have now narrowed the options to 3 and can more clearly compare them to each other, giving yourself the best chance of scoring full marks.",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                              const Divider(height: 20, thickness: 5),
                               Text("Timings", style: TextStyle(fontSize: 35, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                              Text(
                                  "You will have 140 minutes to complete the SJT with an additional 10-minute optional break. It is crucial that you submit an answer for each question so getting your timings right is critical. Missing even one rating question means you are losing out on 20 marks which can significantly impact your score. If you run out of time, you should simply guess any questions you are yet to see. You will likely pick up some good marks by doing this. Never leave a question blank.\n\nThe exam is split into two halves. The first half consists of rating and multiple-choice questions, and the second half is the ranking section. These are to be completed separately, so after you have completed the first half (rating and multiple choice), you will not be able to go back and change these answers. You have 70 minutes for each half, with a 10-minute break between these sections. For Part 1, we recommend splitting your time equally by spending 35 minutes on the rating questions and 35 minutes on the multiple-choice scenarios. Although the rating questions are worth more marks, the rating and multiple-choice sections have the same number of scenarios to complete. Additionally, you should give yourself a time buffer to ensure that you complete all the multiple-choice questions on time. See the table below.",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                              Image.asset(("assets/timings.png"),
                                  height: 150, fit: BoxFit.contain),
                              const SizedBox(height: 20),
                               Text(
                                  "We highly recommend using the optional 10-minute break to have a snack/drink and clear your head for the ranking questions. You will quickly get decision fatigue if you attempt to power on to the rating section, so we could not recommend this break enough.\n\nOnce you have completed the first half of the exam (rating and multiple-choice questions), you cannot go back and change these answers. Therefore, use the entire 70 minutes and return to any flagged questions if needed before the break. Then, once you are on your break, put the first half of the exam behind you and start fresh. For the second half of the exam, the timings become easier as you are only tasked with completing one section - the ranking section. Just ensure that you are on target to finish on time by completing at least 19/38 questions once 35 minutes have elapsed. If you are short of this, you know that you should speed up. These numbers can be adjusted accordingly for those with extra time, but the same principles apply.\n\nAt the end of each section, you may have time to review flagged questions you were unsure about. We recommend you minimise any changes you make to your answers if you have time to review flagged questions at the end of each half. Only change a response if you believe that you have a new insight which you did not consider when you first tackled the question. Otherwise, go with your gut if you are unsure!\n\nNote: You will not be allowed to wear a watch in the exam – the time left for each section will appear in the corner of the screen.",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                              const Divider(height: 20, thickness: 5),
                               Text("What is the exam day like?",
                                  style: TextStyle(fontSize: 35, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                               Text(
                                  "Most people choose to go to a Pearson Vue test centre to complete the SJT (there is also an option to do the exam from home). These are the same test centres where people complete their driving theory or UKCAT. There will be SJT slots that you need to book in advance, but you may also be sitting alongside people completing other exams. The UKFPO will be in touch via email about when these slots are available. You will also have the choice to do the exam in December or January. In our experience, it does not make a big difference which exam week you choose, so pick the one that works best for you, given other commitments. Each participant is faced with a different set of questions, randomly selected from the UKFPO question bank. No two students will get the same exam, but there may be several questions within your exam that are the same as your colleagues.\n\nWhen you arrive at the centre, you must sign in and present your photo ID at the front desk. The receptionist will then ask you to lock up all your belongings except your snack and water bottle. Depending on how early you arrive, you will be asked to sit in a waiting room before your slot starts. After being called into the testing area, you will be given a whiteboard and pen by the attendant. You will also be offered earplugs at most test centres. Then, you will be escorted to your desk. At your desk, there will be a standard computer with over-ear headphones. We recommend wearing the headphones provided for the entire exam, not just for listening to the video scenarios. This should help you block out any background noise and allows you to focus on the exam.\n\nAfter 70 minutes, you should have finished the rating and multiple-choice section. Once the time is up, you will get a pop-up option to take a 10-minute break. You should choose yes to this option if you want to take it and then raise your hand to the invigilator who ensures the test is paused and lets you out of the exam room. You are free to leave the building during your break and get access to your locker. You also have time to have a snack, drink, and toilet break. Getting some fresh air may also be helpful. However, please ensure that you are back in time. If you take longer than 10 minutes, the exam will restart. This will eat into your remaining 70 minutes to complete the exam. Make a note of the time you left (remember that you won’t have a watch with you) and come back with a couple of minutes to spare.\n\nOnce you are on the second half of the exam, you are on the home straight. Towards the end of the exam, you might feel fatigued. Make sure you fully immerse yourself in each scenario until the last question. Once the timer is up, you have finished and are free to go and celebrate!",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                              const Divider(height: 20, thickness: 5),
                               Text("Summary: How should you revise for the Professional Dilemmas paper: ",
                                  style: TextStyle(fontSize: 35, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                               Text(
                                  "UKFPO practice papers (x2) + sample paper: Two or more repetitions each.\nPearson Vue past paper: Complete one or more repetitions. Use our unofficial mark scheme to review your answers.\nOur UKFPO and GMC Flashcard decks: Three repetitions in each domain using our spacing algorithm. \n\nUKFPO Practice papers \nWhat are these? \n2x Practice papers, including 60 ranking and multiple choice questions + mark scheme. \n1x Sample paper. 75 ranking, rating and multiple choice questions + mark scheme. \n\nThese papers are accompanied by a mark scheme which includes rationales for each answer, created by the UKFPO. \n\nWe strongly recommend maximising the use of these past papers in your revision by completing all three papers at least twice each over your revision period - the more, the better. Each time you complete the paper, do it under time pressure. Then, meticulously review the rationale for each question; think about why you chose the answer you did, how this differed from their rationale and how this compares to other questions you have done previously. The earlier you start revision, the more time you have to spread out each repetition of these papers. The usefulness of repeating this exercise may diminish if you repeat the papers in quick succession because you will find yourself simply remembering the answers rather than reasoning through the answers. That's why we recommend spreading these out as much as possible. \n\nPearson Vue Past Paper\nWhat is this\n\n75 rating, ranking and multiple-choice scenarios created by UKFPO. This paper was released on the PeasonVue website but has been deleted in 2023.\n\nThe Pearson Vue past paper has some overlap with the sample paper released by the UKFPO in 2023. However, approximately 50% of the questions are different. For the questions which do not have official rationales, we have released our unofficial mark scheme. How will this help your revision? By having an unofficial mark scheme for these extra questions, you will be exposed to another large bank of realistic questions written by the examiner. Therefore, we recommend completing this exam one or more times in your revision period\n\nDISCLAIMER: Although our unofficial rationales have been peer-reviewed by top-scoring trainees, our way of rationalising these questions may differ from the examiners. Therefore, these rationales should be used as a topic of discussion and reflection rather than internalised as facts. Also, exercise the same caution when using any content produced from third-party question banks or revision platforms.   \n\nGMC guidance\nWhat are these?\n\nThe General Medical Council (GMC) have released several documents which outline the values which they would like doctors in the UK to practice with. The over-arching document is the Good Medical Practice, which outlines the general principles for ethical and safe medical practice. They have also released several more specific documents with guidance on topics such as confidentiality or raising concerns.\n\nWe recommend printing out and reading through the Good Medical Practice. This is a good first step when embarking on revision for the Professional Dilemmas paper. Keep it on your desk as a point of reference and make annotations when you encounter a relevant practice question or a clinical scenario. Nevertheless, we found that it was difficult to digest the Good Medical Practice in a way that you can apply to specific scenarios. The other GMC guidelines do have actionable information on dealing with certain scenarios. Therefore, have condensed thisinformation, alongside facts taken from the UKFPO past papers, into flashcard format so you can study using the benefits of active recall and spaced repetition. To maximise your chances of success, complete each of our eight decks of flashcards at least three times during your revision period, spaced out at increasing intervals to maximise recall.\n\nFinal Tips\n1. Start your revision early and have a clear plan about how to prepare. Be realistic and schedule when you will be able to complete revision sessions. Enter the exam date into your calendar and work backwards from there.\n\n2. When completing Professional Dilemma questions, make a conscious effort to immerse yourself in each scenario, imagine being in that situation and consider which action best solves the core problem in the most direct and timely fashion.Imagine doing or saying each action, then ask yourself: does that sound right? Is it appropriate to call up your consultant and say that? Does this tackle the main problem in the scenario? \n\n3. Observe what happens in real life. Be observant when you are working in clinical practice. You will start to notice the same situations you have seen in practice questions unfolding for yourself or other colleagues. How were they dealt with? Was that the best way? However, please note that when you are answering the Professional Dilemma questions, answer them with what you should do according to best GMC practice, not by what happens in reality.\n\n4. Collaborate with your peers. Go through the past papers with your colleagues who are also preparing for the exam. Discuss the rationale behind your answer and their rationale, comparing this to the official answer. Active discussion is a great way to understand the key principles tested in the Professional Dilemmas paper and uncover patterns in how examiners rationalise scenarios.Our platform has a discussion section for each question to maximise the opinions and perspectives you are exposed to during your revision.\n\n5. Use spaced repetition, active recall, interleaved study, and concept mapping. Time is a valuable resource as a medical trainee, especially when preparing for exams. Therefore, to excel in medical exams, you must be smart about how you revise rather than simply putting the hours in. Use our platform to utilise effective studying techniques and pre-made content to excel in the MSRA. \n\nGood Luck!",
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)),
                              const SizedBox(height: 20),
                            ],
                          )))
                ],
              ),
            )));
  }
}

