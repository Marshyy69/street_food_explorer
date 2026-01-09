import 'package:flutter/material.dart';
import 'user_input_screen.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> foodData;

  const FoodDetailsScreen({super.key, required this.foodData});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;
  double _basePrice = 0.0;

  @override
  void initState() {
    super.initState();
    // 1. Parse the price from "RM 8-12" to a number (e.g., 10.00) for calculation
    // We try to grab the first number found in the string or default to 10.0
    String priceString = widget.foodData['price'] ?? '10';
    _basePrice = double.tryParse(priceString.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 10.0;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepOrange;
    
    // 2. Handle missing data safely (in case DB doesn't have these fields yet)
    final description = widget.foodData['description'] ?? 
        "A famous Malaysian favorite! Stir-fried flat rice noodles with prawns, cockles, bean sprouts, and chives in a mix of soy sauce.";
    final ingredients = widget.foodData['ingredients'] as List<dynamic>? ?? 
        ['Noodles', 'Prawns', 'Bean Sprouts', 'Egg', 'Chives'];

    return Scaffold(
      backgroundColor: Colors.white,
      // 3. Custom App Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Food Details", style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share, color: Colors.black), onPressed: () {}),
        ],
      ),
      
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Food Image ---
                  Center(
                    child: Container(
                      height: 200,
                      width: 200, // Square aspect like wireframe
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: widget.foodData['imageUrl'] != null 
                          ? DecorationImage(image: NetworkImage(widget.foodData['imageUrl']), fit: BoxFit.cover)
                          : null,
                      ),
                      child: widget.foodData['imageUrl'] == null 
                          ? const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.grey)) 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Title & Rating ---
                  Text(
                    widget.foodData['name'] ?? "Food Name",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) => Icon(
                          index < 4 ? Icons.star : Icons.star_border, // Simple logic for demo
                          color: Colors.black87, 
                          size: 16
                        )),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${widget.foodData['rating'] ?? '4.5'} (124 reviews)",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Info Cards (Distance, Time, Price) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(Icons.location_on_outlined, "2.3 km"),
                      _buildInfoCard(Icons.access_time, "15-20 min"),
                      _buildInfoCard(Icons.attach_money, widget.foodData['price'] ?? "RM 10"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Description ---
                  const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // --- Ingredients ---
                  const Text("Ingredients", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ingredients.map((ing) => Chip(
                      label: Text(ing.toString()),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4), 
                        side: const BorderSide(color: Colors.black12)
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),

          // --- Bottom Action Section (Quantity + Cart) ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _decrementQuantity,
                            constraints: const BoxConstraints(), // Removes extra padding
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _incrementQuantity,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Total Price & Add Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Price", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            "RM ${(_basePrice * _quantity).toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Dark button per wireframe
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                       onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserInputScreen(foodData: widget.foodData),
                          ),
                        );
                      },
                      child: const Text("Book This Tour"), // Change label to match context
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for the small info boxes (Distance, Time, etc)
  Widget _buildInfoCard(IconData icon, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}