import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed for User ID
import 'user_input_screen.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> foodData;
  // We need the Doc ID to identify the food uniquely in the database
  final String? docId; 

  // Update constructor to accept docId (optional but recommended)
  const FoodDetailsScreen({super.key, required this.foodData, this.docId});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;
  double _basePrice = 0.0;
  bool _isFavorite = false; // State to track heart icon
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    String priceString = widget.foodData['price'] ?? '10';
    _basePrice = double.tryParse(priceString.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 10.0;
    
    _checkIfFavorite(); // Check status on load
  }

  // 1. Check if this food is already in favorites
  void _checkIfFavorite() async {
    if (user == null) return;
    
    // Use the food Name as ID if docId is missing (fallback for your current setup)
    String foodId = widget.docId ?? widget.foodData['name'];

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(foodId)
        .get();

    if (mounted) {
      setState(() {
        _isFavorite = doc.exists;
      });
    }
  }

  // 2. Toggle Favorite Logic
  void _toggleFavorite() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to save items")));
      return;
    }

    String foodId = widget.docId ?? widget.foodData['name'];
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(foodId);

    if (_isFavorite) {
      // If currently favorite -> Remove it
      await favRef.delete();
      if (mounted) setState(() => _isFavorite = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from saved")));
    } else {
      // If not favorite -> Add it
      await favRef.set(widget.foodData); // Save the whole food object so we can show it later
      if (mounted) setState(() => _isFavorite = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to favorites!")));
    }
  }

  void _incrementQuantity() => setState(() => _quantity++);
  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.foodData['description'] ?? "No description available.";
    final culture = widget.foodData['culturalBackdrop'] ?? "A classic local favorite.";
    final hygiene = widget.foodData['hygieneGrade'] ?? 'A';
    
    Color hygieneColor = hygiene == 'A' ? Colors.green : (hygiene == 'B' ? Colors.orange : Colors.red);

    return Scaffold(
      backgroundColor: Colors.white,
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
          // 3. The Interactive Heart Button
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(icon: const Icon(Icons.share, color: Colors.black), onPressed: () {}),
        ],
      ),
      
      // ... (Keep the rest of your UI exactly the same) ...
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: widget.foodData['imageUrl'] != null && widget.foodData['imageUrl'].isNotEmpty
                          ? DecorationImage(image: NetworkImage(widget.foodData['imageUrl']), fit: BoxFit.cover)
                          : null,
                      ),
                      child: widget.foodData['imageUrl'] == null 
                          ? const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.grey)) 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.foodData['name'] ?? "Food Name",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hygieneColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: hygieneColor),
                        ),
                        child: Text("Grade $hygiene", style: TextStyle(color: hygieneColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text("${widget.foodData['rating'] ?? '5.0'}", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(Icons.location_on_outlined, widget.foodData['location'] ?? "KL"),
                      _buildInfoCard(Icons.access_time, "15-20 min"),
                      _buildInfoCard(Icons.attach_money, widget.foodData['price'] ?? "RM 10"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(description, style: TextStyle(color: Colors.grey[600], height: 1.5)),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_edu, color: Colors.orange[800], size: 20),
                            const SizedBox(width: 8),
                            Text("Cultural Origin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(culture, style: TextStyle(color: Colors.orange[900], fontSize: 13, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Price", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("RM ${(_basePrice * _quantity).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
                  child: const Text("Book This Tour"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}