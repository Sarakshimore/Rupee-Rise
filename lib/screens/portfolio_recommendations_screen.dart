import 'package:flutter/material.dart';

class PortfolioRecommendationsScreen extends StatefulWidget {
  @override
  _PortfolioRecommendationsScreenState createState() => _PortfolioRecommendationsScreenState();
}

class _PortfolioRecommendationsScreenState extends State<PortfolioRecommendationsScreen> {
  // Stage: quiz or result
  bool quizCompleted = false;
  int totalScore = 0;
  String riskProfile = "";
  String recommendation = "";

  // Budget controller for monthly budget input.
  TextEditingController budgetController = TextEditingController();

  // Define our quiz questions.
  final List<Question> questions = [
    Question(
      text: "How would you describe your investment experience?",
      options: [
        Option(text: "None", score: 1),
        Option(text: "Limited", score: 2),
        Option(text: "Moderate", score: 3),
        Option(text: "Extensive", score: 4),
      ],
    ),
    Question(
      text: "How do you react to market volatility?",
      options: [
        Option(text: "I panic and sell", score: 1),
        Option(text: "I feel uneasy but hold", score: 2),
        Option(text: "I see it as an opportunity", score: 3),
        Option(text: "I invest more", score: 4),
      ],
    ),
    Question(
      text: "What is your investment time horizon?",
      options: [
        Option(text: "Less than 1 year", score: 1),
        Option(text: "1-3 years", score: 2),
        Option(text: "3-5 years", score: 3),
        Option(text: "More than 5 years", score: 4),
      ],
    ),
  ];

  // Store the selected option score for each question.
  List<int?> selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(questions.length, null);
  }

  /// Completes the quiz, calculates the total score, and sets the risk profile.
  void completeQuiz() {
    totalScore = 0;
    bool allAnswered = true;
    for (var answer in selectedAnswers) {
      if (answer == null) {
        allAnswered = false;
        break;
      }
      totalScore += answer!;
    }
    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }

    // Score range: 3 (all 1's) to 12 (all 4's)
    // Simple logic: lower scores → Low risk, mid → Medium risk, high scores → High risk.
    if (totalScore <= 6) {
      riskProfile = "Low";
    } else if (totalScore <= 9) {
      riskProfile = "Medium";
    } else {
      riskProfile = "High";
    }

    setState(() {
      quizCompleted = true;
    });
  }

  /// Generates a portfolio recommendation based on the risk profile and monthly budget.
  void generateRecommendation() {
    double? budget = double.tryParse(budgetController.text);
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid budget")),
      );
      return;
    }

    // Simulate portfolio recommendations based on risk profile.
    if (riskProfile == "Low") {
      recommendation =
      "Based on your low risk tolerance, we recommend a diversified portfolio with approximately 20% in equities, 50% in balanced mutual funds, and 30% in bonds. For a monthly budget of ₹${budget.toStringAsFixed(0)}, a monthly SIP of around ₹${(budget * 0.8).toStringAsFixed(0)} could work well.";
    } else if (riskProfile == "Medium") {
      recommendation =
      "With a medium risk tolerance, a balanced portfolio with about 40% in equities, 40% in mutual funds, and 20% in bonds is suggested. For a monthly budget of ₹${budget.toStringAsFixed(0)}, consider a monthly SIP of around ₹${(budget * 0.8).toStringAsFixed(0)}.";
    } else {
      recommendation =
      "Given your high risk tolerance, a growth-oriented portfolio with around 70% in equities, 20% in mutual funds, and 10% in bonds might be ideal. For a monthly budget of ₹${budget.toStringAsFixed(0)}, a monthly SIP of approximately ₹${(budget * 0.8).toStringAsFixed(0)} is recommended.";
    }

    setState(() {}); // Trigger UI update.
  }

  @override
  Widget build(BuildContext context) {
    if (!quizCompleted) {
      // Display the risk assessment quiz.
      return Scaffold(
        appBar: AppBar(
          title: Text("Risk Assessment Quiz"),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(questions.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questions[index].text,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(questions[index].options.length, (optionIndex) {
                      return RadioListTile<int>(
                        title: Text(questions[index].options[optionIndex].text),
                        value: questions[index].options[optionIndex].score,
                        groupValue: selectedAnswers[index],
                        onChanged: (value) {
                          setState(() {
                            selectedAnswers[index] = value;
                          });
                        },
                      );
                    }),
                    SizedBox(height: 16),
                  ],
                );
              }),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: completeQuiz,
                  child: Text("Submit Quiz"),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // After the quiz: show risk profile, input for budget, and recommendation.
      return Scaffold(
        appBar: AppBar(
          title: Text("Portfolio Recommendations"),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your risk profile is: $riskProfile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text("Enter your monthly budget (₹):", style: TextStyle(fontSize: 18)),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "e.g., 10000"),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: generateRecommendation,
                  child: Text("Get Recommendation"),
                ),
              ),
              SizedBox(height: 16),
              if (recommendation.isNotEmpty)
                Text(
                  recommendation,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      );
    }
  }
}

class Question {
  final String text;
  final List<Option> options;
  Question({required this.text, required this.options});
}

class Option {
  final String text;
  final int score;
  Option({required this.text, required this.score});
}
