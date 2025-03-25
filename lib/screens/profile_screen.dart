import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _goalsController = TextEditingController();
  String? _riskPreference;
  final List<String> _riskOptions = ['Low', 'Medium', 'High'];

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'goals': _goalsController.text,
          'risk_preference': _riskPreference,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile saved!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _goalsController,
                decoration: InputDecoration(labelText: 'Financial Goals'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your financial goals';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _riskPreference,
                hint: Text('Select Risk Preference'),
                items: _riskOptions.map((String risk) {
                  return DropdownMenuItem<String>(
                    value: risk,
                    child: Text(risk),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _riskPreference = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a risk preference';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}