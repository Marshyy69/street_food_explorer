import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_booking_screen.dart'; // IMPORT THE NEW SCREEN

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Reservations"), backgroundColor: Colors.blue),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Center(child: Text("No reservations found."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              
              // Color code the status
              Color statusColor = Colors.green;
              if (data['status'] == 'Cancelled') statusColor = Colors.red;
              if (data['status'] == 'Completed') statusColor = Colors.grey;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['foodName'] ?? 'Unknown Tour', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer: ${data['customerName']}"),
                      const SizedBox(height: 4),
                      Text("Status: ${data['status'] ?? 'Confirmed'}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                      Text("Pax: ${data['participants']} | ${data['mealTime']}"),
                    ],
                  ),
                  // ADD EDIT AND DELETE BUTTONS HERE
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to Edit Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBookingScreen(docId: docId, currentData: data),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Confirm Delete
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Booking?"),
                              content: const Text("This cannot be undone."),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance.collection('bookings').doc(docId).delete();
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
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
}