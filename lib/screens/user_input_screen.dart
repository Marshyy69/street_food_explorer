import 'package:flutter/material.dart';
import 'price_display_screen.dart'; // We will create this in the next step

class UserInputScreen extends StatefulWidget {
  final Map<String, dynamic> foodData;

  const UserInputScreen({super.key, required this.foodData});

  @override
  State<UserInputScreen> createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  // 1. Form State Variables
  int _participants = 2;
  String _mealTime = 'Lunch';
  String _packageType = 'Basic';
  
  // Add-ons State
  bool _addTransport = false;
  bool _addGuide = false;
  bool _addDessert = false;

  // Pricing Logic (Hardcoded for now, can be dynamic later)
  final double _transportPrice = 30.0;
  final double _guidePrice = 50.0;
  final double _dessertPrice = 20.0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepOrange;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Customize Your Tour", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Number of Participants
            _buildSectionTitle("1. Quantity of Participants"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pax", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          if (_participants > 1) _participants--;
                        }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text("$_participants", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => setState(() {
                          _participants++;
                        }),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Preferred Meal Time
            _buildSectionTitle("2. Preferred Meal Time"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _boxDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _mealTime,
                  isExpanded: true,
                  items: ['Breakfast', 'Lunch', 'Dinner', 'Supper'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _mealTime = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Package Type
            _buildSectionTitle("3. Type of Package"),
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text("Basic Package (Food Only)"),
                    value: 'Basic',
                    groupValue: _packageType,
                    activeColor: primaryColor,
                    onChanged: (value) => setState(() => _packageType = value.toString()),
                  ),
                  RadioListTile(
                    title: const Text("Premium (Food + Drink)"),
                    value: 'Premium',
                    groupValue: _packageType,
                    activeColor: primaryColor,
                    onChanged: (value) => setState(() => _packageType = value.toString()),
                  ),
                  RadioListTile(
                    title: const Text("Full Tour (All Inclusive)"),
                    value: 'Full Tour',
                    groupValue: _packageType,
                    activeColor: primaryColor,
                    onChanged: (value) => setState(() => _packageType = value.toString()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 4: Extras (Add-ons)
            _buildSectionTitle("4. Extras"),
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text("Transport (+RM $_transportPrice)"),
                    value: _addTransport,
                    activeColor: primaryColor,
                    onChanged: (val) => setState(() => _addTransport = val!),
                  ),
                  CheckboxListTile(
                    title: Text("Tour Guide (+RM $_guidePrice)"),
                    value: _addGuide,
                    activeColor: primaryColor,
                    onChanged: (val) => setState(() => _addGuide = val!),
                  ),
                  CheckboxListTile(
                    title: Text("Dessert Tasting (+RM $_dessertPrice)"),
                    value: _addDessert,
                    activeColor: primaryColor,
                    onChanged: (val) => setState(() => _addDessert = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Calculate Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Dark button per wireframe
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Navigate to Price Display with all the data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PriceDisplayScreen(
                      foodData: widget.foodData,
                      participants: _participants,
                      mealTime: _mealTime,
                      packageType: _packageType,
                      addTransport: _addTransport,
                      addGuide: _addGuide,
                      addDessert: _addDessert,
                    ),
                  ),
                );
              },
              child: const Text("Calculate Total Price", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for consistent styling
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    );
  }
}