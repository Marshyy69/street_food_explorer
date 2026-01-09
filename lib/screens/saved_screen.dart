import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; 
import 'food_details_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in first.")));
    }

    return Scaffold(
      appBar: AppBar(
        // Colored Header
        backgroundColor: theme.colorScheme.primary, 
        foregroundColor: Colors.white, // White text
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.white), // Header Icon
            SizedBox(width: 10),
            Text("My Favorites", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }

          // --- BEAUTIFUL EMPTY STATE ---
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_border, size: 80, color: Colors.brown[300]),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No favorites yet",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                  ),
                  const SizedBox(height: 8),
                  Text("Mark items with a ♥ to find them here!", style: TextStyle(color: Colors.brown[400])),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              return FoodCard(
                data: data,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodDetailsScreen(
                        foodData: data, 
                        docId: docs[index].id 
                      )
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}