import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_booking_screen.dart'; 

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Reservations", style: TextStyle(color: Colors.white)),
        backgroundColor: theme.colorScheme.primary, // Brown
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.event_busy, size: 60, color: Colors.brown[200]),
                   const SizedBox(height: 10),
                   Text("No reservations yet.", style: TextStyle(color: Colors.brown[300])),
                 ],
               ),
             );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              
              // Status Logic
              Color statusColor = Colors.green;
              Color statusBg = Colors.green.shade50;
              if (data['status'] == 'Cancelled') {
                statusColor = Colors.red;
                statusBg = Colors.red.shade50;
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              data['status'] ?? 'Confirmed',
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          Text(
                            data['mealTime'] ?? '',
                            style: TextStyle(color: Colors.brown[400], fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Food Name
                      Text(
                        data['foodName'] ?? 'Tour', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary)
                      ),
                      const SizedBox(height: 4),
                      Text("Customer: ${data['customerName']}", style: TextStyle(color: Colors.grey[700])),
                      
                      const Divider(height: 24),
                      
                      // Footer Row (Details + Buttons)
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text("${data['participants']} Pax", style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(width: 16),
                          Text(
                            "RM ${data['totalPrice']?.toStringAsFixed(2)}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                          
                          const Spacer(),
                          
                          // Action Buttons
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
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
                               // Keep existing delete dialog logic
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
                      )
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