import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditFoodScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? currentData;

  const AddEditFoodScreen({super.key, this.docId, this.currentData});

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _cultureController = TextEditingController(); // NEW: Cultural Backdrop
  final _imageController = TextEditingController(); 
  
  String _selectedHygiene = 'A'; // NEW: Default Hygiene Grade
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.currentData != null) {
      _nameController.text = widget.currentData!['name'];
      _priceController.text = widget.currentData!['price'];
      _descController.text = widget.currentData!['description'] ?? '';
      _cultureController.text = widget.currentData!['culturalBackdrop'] ?? ''; // Load Culture
      _imageController.text = widget.currentData!['imageUrl'] ?? '';
      _selectedHygiene = widget.currentData!['hygieneGrade'] ?? 'A'; // Load Hygiene
    }
  }

  void _saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'price': _priceController.text.trim(),
      'description': _descController.text.trim(),
      'culturalBackdrop': _cultureController.text.trim(), // Save Culture
      'hygieneGrade': _selectedHygiene, // Save Hygiene
      'imageUrl': _imageController.text.trim(),
      'rating': '5.0', 
    };

    try {
      if (widget.docId == null) {
        await FirebaseFirestore.instance.collection('foods').add(data);
      } else {
        await FirebaseFirestore.instance.collection('foods').doc(widget.docId).update(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Add New Place" : "Edit Details"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Stall / Food Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              // NEW: Hygiene Dropdown
              DropdownButtonFormField<String>(
                value: _selectedHygiene,
                decoration: const InputDecoration(labelText: "Hygiene Grade", border: OutlineInputBorder()),
                items: ['A', 'B', 'C'].map((grade) {
                  return DropdownMenuItem(
                    value: grade, 
                    child: Text("Grade $grade", style: const TextStyle(fontWeight: FontWeight.bold))
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedHygiene = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price (e.g. RM 12)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // NEW: Cultural Backdrop Field
              TextFormField(
                controller: _cultureController,
                decoration: const InputDecoration(
                  labelText: "Cultural Backdrop (History/Origins)",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _isLoading ? null : _saveFood,
                  child: Text(widget.docId == null ? "Add Place" : "Update Changes"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}