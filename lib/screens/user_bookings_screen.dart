import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserBookingsScreen extends StatelessWidget {
  const UserBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) return const Center(child: Text("Please login first"));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary, // Brown Header
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number, color: Colors.white), // Ticket Icon
            SizedBox(width: 10),
            Text("My Bookings", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid) 
            // .orderBy('timestamp', descending: true)
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
                      color: Colors.orange[50], // Orange tint for bookings
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.airplane_ticket_outlined, size: 80, color: Colors.orange[300]),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No bookings yet",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                  ),
                  const SizedBox(height: 8),
                  Text("Your culinary adventure awaits!", style: TextStyle(color: Colors.brown[400])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              
              // Status Color Logic
              Color statusColor = Colors.green;
              if (data['status'] == 'Cancelled') statusColor = Colors.red;
              
              return Card(
                elevation: 4,
                shadowColor: Colors.brown.withOpacity(0.2),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['foodName'] ?? 'Tour',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              data['status'] ?? 'Confirmed',
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildInfoRow(Icons.card_giftcard, "Package", data['packageType']),
                      _buildInfoRow(Icons.calendar_today, "Session", data['mealTime']),
                      _buildInfoRow(Icons.people, "Pax", "${data['participants']} people"),
                      
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Paid", style: TextStyle(color: Colors.brown[700])),
                            Text(
                              "RM ${data['totalPrice']?.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}