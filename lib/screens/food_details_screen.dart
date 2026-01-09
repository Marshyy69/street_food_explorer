import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_input_screen.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> foodData;
  final String? docId; 

  const FoodDetailsScreen({super.key, required this.foodData, this.docId});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;
  double _basePrice = 0.0;
  bool _isFavorite = false;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    String priceString = widget.foodData['price'] ?? '10';
    _basePrice = double.tryParse(priceString.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 10.0;
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    if (user == null) return;
    String foodId = widget.docId ?? widget.foodData['name'];
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('favorites').doc(foodId).get();
    if (mounted) setState(() => _isFavorite = doc.exists);
  }

  void _toggleFavorite() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to save items")));
      return;
    }
    String foodId = widget.docId ?? widget.foodData['name'];
    final favRef = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('favorites').doc(foodId);

    if (_isFavorite) {
      await favRef.delete();
      if (mounted) setState(() => _isFavorite = false);
    } else {
      await favRef.set(widget.foodData);
      if (mounted) setState(() => _isFavorite = true);
    }
  }

  void _incrementQuantity() => setState(() => _quantity++);
  void _decrementQuantity() { if (_quantity > 1) setState(() => _quantity--); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = widget.foodData['description'] ?? "No description available.";
    final culture = widget.foodData['culturalBackdrop'] ?? "A classic local favorite with rich history.";
    final hygiene = widget.foodData['hygieneGrade'] ?? 'A';
    // NEW: Get ingredients as list
    final List<dynamic> ingredients = widget.foodData['ingredients'] ?? ['Secret Recipe'];
    
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
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.black),
            onPressed: _toggleFavorite,
          ),
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
                  // Image
                  Center(
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.brown[50],
                        borderRadius: BorderRadius.circular(20),
                        image: widget.foodData['imageUrl'] != null && widget.foodData['imageUrl'].isNotEmpty
                          ? DecorationImage(image: NetworkImage(widget.foodData['imageUrl']), fit: BoxFit.cover)
                          : null,
                      ),
                      child: widget.foodData['imageUrl'] == null 
                          ? Center(child: Icon(Icons.fastfood, size: 50, color: Colors.brown[200])) 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title & Hygiene
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.foodData['name'] ?? "Food Name",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
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

                  // Description
                  Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text(description, style: TextStyle(color: Colors.grey[600], height: 1.5)),
                  const SizedBox(height: 24),

                  Text("Ingredients", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ingredients.map((ing) => Chip(
                      label: Text(ing.toString(), style: TextStyle(color: Colors.brown[900])),
                      backgroundColor: Colors.orange[50], // Theme Color
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.orange.withOpacity(0.3))),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.brown.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.brown.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_edu, color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text("Cultural Origin", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(culture, style: TextStyle(color: Colors.brown[900], fontSize: 13, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action
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
                    Text("RM ${(_basePrice * _quantity).toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.primary)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
          Icon(icon, size: 20, color: Colors.brown[400]),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}