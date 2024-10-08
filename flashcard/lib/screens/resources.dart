import 'dart:core';

import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';



class Resources extends StatelessWidget {
  const Resources({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawMain(),
        appBar: AppBar(
          // backgroundColor: Colors.blue,
            elevation: 0,
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
                    child:  Text('Resources',style: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black)
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
                          child: Column(
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
                                  child:  Center(
                                      child: SingleChildScrollView(
                                        // allow for scrolling if its a long question
                                        child: Center(
                                            child: Text(
                                                "Our complete list of reliable resources that you should use for success in the MSRA professional dilemmas paper. ",
                                                //get the question from the map
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                                  fontSize: 20,
                                                ))),
                                      ))),
                              Text.rich(TextSpan(
                                  style: const TextStyle(
                                    fontSize: 27,
                                  ),
                                  children: [
                                     TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "\nThe Professional Dilemmas paper is a subjective exam, which can be frustrating for applicants. Because each scenario can be rationalised differently, there is not always a consensus about which answers are correct. Therefore, it is crucial that applicants only use reliable resources which are made from content produced by the UK governing bodies: UKFPO, HEE or GMC. The aim of revising for this exam is to understand and internalise the rationales and principles that the UK governing bodies would like their doctors to use when practising medicine. Therefore, using other third-party revision courses or books that include their own practice questions with rationales can negatively affect your performance in the Professional Dilemmas paper. Our recommended list is as follows:\n\n"),
                                     TextSpan(
                                        style: TextStyle(
                                            fontSize: 27, fontWeight: FontWeight.bold,color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text: "UKFPO Past Papers 1 and 2\n"),
                                     TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "These two past papers, alongside the sample paper below, are the gold standard resources you should use to test yourself. The scenarios in these papers will be very similar to the ones you will encounter in your exam. Additionally, the rationales are written by the same people who write the questions for the MSRA, so you should study these answers closely. \nLink: "),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                            decoration: TextDecoration.underline),
                                        //make link blue and underline
                                        text:
                                        "https://foundationprogramme.nhs.uk/resources/situational-judgement-test-sjt/practice-sjt-papers/",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            //on tap code here, you can navigate to other page or URL
                                            String url =
                                                "https://foundationprogramme.nhs.uk/resources/situational-judgement-test-sjt/practice-sjt-papers/";
                                            var urllaunchable = await canLaunchUrlString(
                                                url); //canLaunch is from url_launcher package
                                            if (urllaunchable) {
                                              await launchUrlString(
                                                  url); //launch is from url_launcher package to launch URL
                                            } else {
                                              if (kDebugMode) {
                                                print("URL can't be launched.");
                                              }
                                            }
                                          }),
                                     TextSpan(
                                        style: TextStyle(
                                            fontSize: 27, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "\n\nUKFPO Sample paper 2023 (Introduced in 2023)\n"),
                                     TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "This is another gold standard bank of questions. It gives insight into how the UKFPO rationalises their answers to scenarios. Pay special attention to the rating questions in this document. These are the only rating questions that the UKFPO has released with rationales on how to answer them.\nLink: "),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                            decoration: TextDecoration.underline),
                                        //make link blue and underline
                                        text:
                                        "https://foundationprogramme.nhs.uk/resources/situational-judgement-test-sjt/practice-sjt-papers/",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            //on tap code here, you can navigate to other page or URL
                                            String url =
                                                "https://foundationprogramme.nhs.uk/resources/situational-judgement-test-sjt/practice-sjt-papers/";
                                            var urllaunchable = await canLaunchUrlString(
                                                url); //canLaunch is from url_launcher package
                                            if (urllaunchable) {
                                              await launchUrlString(
                                                  url); //launch is from url_launcher package to launch URL
                                            } else {
                                              if (kDebugMode) {
                                                print("URL can't be launched.");
                                              }
                                            }
                                          }),
                                     TextSpan(
                                        style: TextStyle(
                                            fontSize: 27, fontWeight: FontWeight.bold,color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text: "\n\nUKFPO 2012 Practice paper\n"),
                                     TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "This practice paper is not available on the foundation programme website. It is a 60-minute-long paper containing multiple-choice and ranking questions. It is very similar to Paper 1, which is on the UKFPO website. However, there are two questions which are slightly different. Therefore, this is not mandatory reading but may be helpful if you wish to maximise the official questions you are exposed to fully. \nLink: "),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                            decoration: TextDecoration.underline),
                                        //make link blue and underline
                                        text:
                                        "https://warwick.ac.uk/services/careers/options/jobsectors/medical/fy1_sjt_practice_paper_answer_and_rationales_large_print.pdf",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            //on tap code here, you can navigate to other page or URL
                                            String url =
                                                "https://warwick.ac.uk/services/careers/options/jobsectors/medical/fy1_sjt_practice_paper_answer_and_rationales_large_print.pdf";
                                            var urllaunchable = await canLaunchUrlString(
                                                url); //canLaunch is from url_launcher package
                                            if (urllaunchable) {
                                              await launchUrlString(
                                                  url); //launch is from url_launcher package to launch URL
                                            } else {
                                              if (kDebugMode) {
                                                print("URL can't be launched.");
                                              }
                                            }
                                          }),
                                     TextSpan(
                                        style: TextStyle(
                                            fontSize: 27, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text: "\n\nPearson Vue UKFPO sample paper\n"),
                                    TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "This is a full-sized example paper including rating, ranking and multiple-choice questions. It replicates the format you will see on test day. There is some overlap with the UKFPO sample paper. However, this paper does not have answers or rationales provided. We have made an unofficial mark scheme to address this. The unofficial mark scheme maximises the number of reliable questions (created by the examiner) that you are exposed to. You should study this paper in the same way as you would with the UKFPO mocks. \nLink: "),
                                    TextSpan(
                                        style:  TextStyle(
                                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                            decoration: TextDecoration.underline),
                                        //make link blue and underline
                                        text: "https://home.pearsonvue.com/ukfp ",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            //on tap code here, you can navigate to other page or URL
                                            String url = "https://home.pearsonvue.com/ukfp";
                                            var urllaunchable = await canLaunchUrlString(
                                                url); //canLaunch is from url_launcher package
                                            if (urllaunchable) {
                                              await launchUrlString(
                                                  url); //launch is from url_launcher package to launch URL
                                            } else {
                                              if (kDebugMode) {
                                                print("URL can't be launched.");
                                              }
                                            }
                                          }),
                                     TextSpan(
                                        style: TextStyle(
                                            fontSize: 27, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text: "\n\nGMC Guidelines\n"),
                                     TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "The GMC (General Medical Council - the governing body for the medical profession) have released several detailed guidelines on the values junior doctors should adhere to: The Good Medical practice\nThis document sets out the principles of good practice. It is the foundation on which all other guidelines are built. However, it is challenging to retain the information outlined in this document and apply their general principles to specific questions in the Professional Dilemmas paper.\nLink:"),
                                    TextSpan(
                                        style:  TextStyle(
                                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                            decoration: TextDecoration.underline),
                                        //make link blue and underline
                                        text:
                                        "https://www.gmc-uk.org/ethical-guidance/ethical-guidance-for-doctors/good-medical-practice",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            //on tap code here, you can navigate to other page or URL
                                            String url =
                                                "https://www.gmc-uk.org/ethical-guidance/ethical-guidance-for-doctors/good-medical-practice";
                                            var urllaunchable = await canLaunchUrlString(
                                                url); //canLaunch is from url_launcher package
                                            if (urllaunchable) {
                                              await launchUrlString(
                                                  url); //launch is from url_launcher package to launch URL
                                            } else {
                                              if (kDebugMode) {
                                                print("URL can't be launched.");
                                              }
                                            }
                                          }),
                                     TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "\n\nOther GMC guidelines include:\nConfidentiality, Maintaining professionalism, Children and young people, Prescribing, Decision-making and consent, Leadership and Management, Candour and raising concerns, Cosmetic interventions and research. \nEach guideline is a lengthy document. However, within these documents, the GMC outlines clear advice on common scenarios tested in the Professional Dilemmas paper. Again, simply reading these documents does not lead to good information retention. Therefore, in our banks of flashcards, we present the important, actionable information taken from these guidelines in a format that maximises retention. \nLink:"),
                                    TextSpan(
                                        style:  TextStyle(
                                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                            decoration: TextDecoration.underline),
                                        //make link blue and underline
                                        text: "https://www.gmc-uk.org/ethical-guidance",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            //on tap code here, you can navigate to other page or URL
                                            String url =
                                                "https://www.gmc-uk.org/ethical-guidance";
                                            var urllaunchable = await canLaunchUrlString(
                                                url); //canLaunch is from url_launcher package
                                            if (urllaunchable) {
                                              await launchUrlString(
                                                  url); //launch is from url_launcher package to launch URL
                                            } else {
                                              if (kDebugMode) {
                                                print("URL can't be launched.");
                                              }
                                            }
                                          }),
                                     TextSpan(
                                        style: TextStyle(
                                            fontSize: 27, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text: "\n\nGMC in practice\n"),
                                     TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                        text:
                                        "This website guides you through scenarios created by the GMC, demonstrating how their guidelines can be used in clinical practice. It is helpful to go through these before the exam. Although not all the scenarios apply to FY1s, the rationales behind each scenario are the same, so pay close attention to these. \nLink: "),
                                    TextSpan(
                                        style:  TextStyle(
                                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
                                            decoration: TextDecoration.underline),
                                        //make link blue and underline
                                        text: "https://www.gmc-uk.org/gmpinaction/",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            //on tap code here, you can navigate to other page or URL
                                            String url =
                                                "https://www.gmc-uk.org/gmpinaction/";
                                            var urllaunchable = await canLaunchUrlString(
                                                url); //canLaunch is from url_launcher package
                                            if (urllaunchable) {
                                              await launchUrlString(
                                                  url); //launch is from url_launcher package to launch URL
                                            } else {
                                              if (kDebugMode) {
                                                print("URL can't be launched.");
                                              }
                                            }
                                          }),
                                     TextSpan(
                                        style: TextStyle(
                                            fontSize: 27, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                            text: "\n\nPrivate revision courses\n"),
                                     TextSpan(
                                        style: TextStyle(fontSize: 27, color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black),
                                            text:
                                                  "Private revision courses are available. The format of these courses is usually a 1-day webinar in which a doctor will explain what the MSRA is and their ways of tackling specific issues, such as rectifying an error or addressing a dispute between colleagues. They will also discuss the answers to their sample questions and the rationale for each scenario. Some courses will also give you access to a question bank which they have created with explanations. Alternatively, you can purchase subscriptions to question banks such as PassMedicine.The problem with these private courses is that practice questions and rationales produced by third-party organisations will differ from the UKFPO, HEE and GMC. To excel in the professional dilemmas paper, you need to internalise the rationales and principles that the governing bodies want their doctors to use. Therefore, using third-party mock questions and rationales can confuse an applicant's thought process and harm performance. This is why at MedicRecall, we only encourage applicants to use content directly taken from reliable sources."),
                                  ])),
                              const Text("", style: TextStyle(fontSize: 20)),
                              const SizedBox(height: 20),
                            ],
                          )))
                ],
              ),
            )));
  }
}