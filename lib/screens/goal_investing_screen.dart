import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goal-Based Investing'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter your investment goal:', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: goalController,
                  decoration: InputDecoration(hintText: 'e.g., Buy a House'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a goal';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text('Target Amount (₹):', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: targetAmountController,
                  decoration: InputDecoration(hintText: 'e.g., 5000000'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text('Time Horizon (Years):', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: timeHorizonController,
                  decoration: InputDecoration(hintText: 'e.g., 10'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                      return 'Please enter a valid number of years';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text('Risk Tolerance:', style: TextStyle(fontSize: 18)),
                DropdownButton<String>(
                  value: riskTolerance,
                  onChanged: (String? newValue) {
                    setState(() {
                      riskTolerance = newValue!;
                    });
                  },
                  items: <String>['Low', 'Medium', 'High']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: calculateRecommendation,
                    child: Text('Get Recommendation'),
                  ),
                ),
                SizedBox(height: 16),
                if (recommendation.isNotEmpty)
                  Text(
                    recommendation,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
