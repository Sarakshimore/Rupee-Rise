import 'package:ai_fin_assist/screens/chat_screen.dart';
import 'package:flutter/material.dart';

// Goal-based investing screen
class GoalInvestingScreen extends StatefulWidget {
  @override
  _GoalInvestingScreenState createState() => _GoalInvestingScreenState();
}

class _GoalInvestingScreenState extends State<GoalInvestingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  final TextEditingController timeHorizonController = TextEditingController();

  String riskTolerance = 'Medium';
  String recommendation = '';

  // A simple calculation for a recommended monthly SIP.
  void calculateRecommendation() {
    if (_formKey.currentState!.validate()) {
      double target = double.parse(targetAmountController.text);
      double years = double.parse(timeHorizonController.text);
      // Basic calculation: monthly SIP = (target / (years * 12)) adjusted by a risk factor.
      double riskFactor = riskTolerance == 'Low'
          ? 1.1
          : riskTolerance == 'Medium'
          ? 1.0
          : 0.9;
      double monthlySIP = target / (years * 12) * riskFactor;
      setState(() {
        recommendation =
        'Based on your goal, a monthly SIP of ₹${monthlySIP.toStringAsFixed(2)} is recommended.';
      });
    }
  }

  // Helper function to build card widgets
  Widget buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Goal-Based Investing'),
          backgroundColor: Colors.green,
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  Text(
                    'Plan Your Investment Goals',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // Goal Input Field
                  buildCard(
                    title: 'Enter your investment goal:',
                    child: TextFormField(
                      controller: goalController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Buy a House',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a goal';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Target Amount Field
                  buildCard(
                    title: 'Target Amount (₹):',
                    child: TextFormField(
                      controller: targetAmountController,
                      decoration: InputDecoration(
                        hintText: 'e.g., 5000000',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Time Horizon Field
                  buildCard(
                    title: 'Time Horizon (Years):',
                    child: TextFormField(
                      controller: timeHorizonController,
                      decoration:
                      InputDecoration(hintText: 'e.g., 10', border: OutlineInputBorder()),
                      keyboardType:
                      TextInputType.number,
                      validator:
                          (value) {
                        if (value ==
                            null ||
                            value.isEmpty ||
                            double.tryParse(value) ==
                                null) {
                          return 'Please enter a valid number of years';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height:
                  16),

                  // Risk Tolerance Dropdown
                  buildCard(
                    title:
                    'Risk Tolerance:',
                    child:
                    DropdownButton<String>(
                      value:
                      riskTolerance,
                      isExpanded:
                      true,
                      onChanged:
                          (String? newValue) {
                        setState(() {
                          riskTolerance =
                          newValue!;
                        });
                      },
                      items:
                      <String>['Low', 'Medium', 'High']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value:
                          value,
                          child:
                          Text(value),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height:
                  24),

                  // Recommendation Button
                  Center(child:
                  ElevatedButton(style:
                  ElevatedButton.styleFrom(backgroundColor:
                  Colors.green, padding:
                  EdgeInsets.symmetric(horizontal:
                  24, vertical:
                  12), textStyle:
                  TextStyle(fontSize:
                  18)), onPressed:
                  calculateRecommendation, child:
                  Text('Get Recommendation'))),

                  SizedBox(height:
                  24),

                  // Recommendation Display
                  if (recommendation.isNotEmpty)
                    Container(padding:
                    EdgeInsets.all(16), decoration:
                    BoxDecoration(color:
                    Colors.grey[200], borderRadius:
                    BorderRadius.circular(12)), child:
                    Text(recommendation, style:
                    TextStyle(fontSize:
                    16, fontWeight:
                    FontWeight.bold))),
                ],
              ),
            ),
          ),
        ),

        // Floating Action Button for Chat Screen
        floatingActionButton:
        FloatingActionButton(backgroundColor:
        const Color(0xFF4CAF50), onPressed:
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );

            }, child:
        const Icon(Icons.chat,color:Colors.white))
    );
  }
}
