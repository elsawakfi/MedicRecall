import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/app_bar.dart';

const double _spacing = 16.0;
const double _cardWidth = 750;

class ExplanationScreen extends StatelessWidget {
  const ExplanationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
        title: 'How does MedicRecall work?',
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Container(
              padding: EdgeInsets.only(left: _spacing, right: _spacing, bottom: _spacing),
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: _cardWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        _buildSection(
                          context,
                          icon: Icons.calendar_today,
                          title: "Create Your Tailored Study Schedule",
                          content:
                          "Set up a personalised plan that integrates official resources with our GMC-based content.\n\n"
                          "Your schedule is designed to fit around your clinical work and gives you autonomy in choosing what resources you want to use and how many repetitions to complete for each.",
                        ),
                        SizedBox(height: _spacing),
                        _buildSection(
                          context,
                          icon: Icons.school,
                          title: "Start Learning Using Evidence-Based Study",
                          content:
                          "Engage with time-efficient preparation by utilising active recall, interleaved practice, and concept mapping to understand the key domains tested in the exam.",
                        ),
                        SizedBox(height: _spacing),
                        _buildSection(
                          context,
                          icon: Icons.replay,
                          title: "Internalise GMC Rationales Through Spaced Repetition",
                          content:
                          "By following your study schedule and using our spaced repetition algorithms, you will begin to understand and internalise the intricacies of how the GMC and HEE rationalise professionalism scenarios.",
                        ),
                        SizedBox(height: _spacing),
                        _buildSection(
                          context,
                          icon: Icons.assessment,
                          title: "Track Your Progress and Stay Motivated",
                          content:
                          "Compare your performance with peers to see where you stand.\n\n"
                          "Use detailed stats to monitor your improvement and identify areas needing more focus.",
                        ),
                        SizedBox(height: _spacing),
                        _buildSection(
                          context,
                          icon: Icons.update,
                          title: "Adapt and Optimise Your Study Plan",
                          content:
                          "Adjust your schedule as needed to balance preparation with your clinical commitments.",
                        ),
                        SizedBox(height: _spacing),
                        _buildSection(
                          context,
                          icon: Icons.timeline,
                          title: "Peak at the Right Time for Your Exam",
                          content:
                          "Follow your structured yet flexible plan to build knowledge steadily.\n\n"
                          "Arrive at your exam fully prepared, confident, and performing at your best.",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }

  Widget _buildSection(BuildContext context,
      {required IconData icon, required String title, required String content}) {
    final theme = Theme.of(context);
    return SizedBox(
      width: _cardWidth,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(_spacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(height: 8.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                content,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
