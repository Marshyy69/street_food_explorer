import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'home_screen.dart';

class PriceDisplayScreen extends StatelessWidget {
  final Map<String, dynamic> foodData;
  final int participants;
  final String mealTime;
  final String packageType;
  final bool addTransport;
  final bool addGuide;
  final bool addDessert;

  const PriceDisplayScreen({
    super.key,
    required this.foodData,
    required this.participants,
    required this.mealTime,
    required this.packageType,
    required this.addTransport,
    required this.addGuide,
    required this.addDessert,
  });

  @override
  Widget build(BuildContext context) {
    // --- Calculation Logic ---
    String priceString = foodData['price'] ?? '10';
    double basePricePerPax = double.tryParse(priceString.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 10.0;
    
    if (packageType == 'Premium') basePricePerPax += 15;
    if (packageType == 'Full Tour') basePricePerPax += 30;

    double subtotalFood = basePricePerPax * participants;
    
    double addOnTotal = 0;
    if (addTransport) addOnTotal += 30;
    if (addGuide) addOnTotal += 50;
    if (addDessert) addOnTotal += 20;

    double subtotal = subtotalFood + addOnTotal;
    double serviceFee = subtotal * 0.05; 
    double grandTotal = subtotal + serviceFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Price Summary", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text("Price Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  const Divider(thickness: 1, height: 30),
                  
                  _buildRow("Package Type", packageType),
                  _buildRow("Participants", "$participants pax"),
                  _buildRow("Base Price", "RM ${subtotalFood.toStringAsFixed(2)}"),
                  
                  if (addOnTotal > 0) ...[
                    const SizedBox(height: 10),
                    const Text("Add-ons:", style: TextStyle(fontWeight: FontWeight.bold)),
                    if (addTransport) _buildRow(" - Transport", "RM 30.00"),
                    if (addGuide) _buildRow(" - Guide", "RM 50.00"),
                    if (addDessert) _buildRow(" - Dessert", "RM 20.00"),
                  ],

                  const SizedBox(height: 10),
                  _buildRow("Service Fee (5%)", "RM ${serviceFee.toStringAsFixed(2)}"),
                  
                  const Divider(thickness: 1, height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("RM ${grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.deepOrange)),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    // 1. Get Current User Info
                    final user = FirebaseAuth.instance.currentUser;
                    String userName = 'Unknown User';
                    String userId = '';

                    if (user != null) {
                      userId = user.uid;
                      // Fetch name from Firestore 'users' collection
                      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                      if (userDoc.exists) {
                        userName = userDoc['name'] ?? user.email ?? 'User';
                      }
                    }

                    // 2. Save to Firebase with REAL Name
                    await FirebaseFirestore.instance.collection('bookings').add({
                      'foodName': foodData['name'] ?? 'Unknown Food',
                      'customerName': userName, // <--- FIXED
                      'userId': userId,         // <--- NEW: To filter for "My Bookings"
                      'participants': participants,
                      'mealTime': mealTime,
                      'packageType': packageType,
                      'extras': {
                        'transport': addTransport,
                        'guide': addGuide,
                        'dessert': addDessert,
                      },
                      'totalPrice': grandTotal,
                      'status': 'Confirmed',
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.pop(context); // Close spinner
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking Successful!"), backgroundColor: Colors.green)
                      );

                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (context) => const HomeScreen()), 
                        (route) => false
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
                    );
                  }
                },
                child: const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ],
      ),
    );
  }
}