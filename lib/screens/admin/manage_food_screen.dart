import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_food_screen.dart';

class ManageFoodScreen extends StatelessWidget {
  const ManageFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Stalls"), backgroundColor: Colors.orange),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to Add Screen (passing null means 'Add New')
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditFoodScreen()));
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('foods').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return ListTile(
                leading: data['imageUrl'] != null 
                  ? Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood),
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Text("Price: ${data['price']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Navigate to Edit Screen (passing existing data)
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AddEditFoodScreen(docId: docId, currentData: data)
                        ));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('foods').doc(docId).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}