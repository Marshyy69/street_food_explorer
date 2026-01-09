import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; // To reuse the FoodCard
import 'food_details_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in to view saved items.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Favorites"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      // We look into 'users/{uid}/favorites' to get the saved list
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No favorites yet. Go save some food!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              // Reuse your FoodCard widget!
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FoodCard(
                  title: data['name'] ?? '',
                  subtitle: data['location'] ?? '',
                  rating: data['rating'] ?? '5.0',
                  price: data['price'] ?? '',
                  imageUrl: data['imageUrl'] ?? '',
                  primaryColor: Colors.deepOrange,
                  onTap: () {
                    // Navigate to details when clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodDetailsScreen(
                          foodData: data, 
                          docId: docs[index].id // Pass the ID so the heart icon works
                        )
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}