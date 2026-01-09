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
  
  // Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController(); // NEW
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _ingredientsController = TextEditingController(); // NEW
  final _ratingController = TextEditingController(text: "5.0"); // NEW (Default 5.0)
  final _cultureController = TextEditingController();
  final _imageController = TextEditingController();
  
  String _selectedHygiene = 'A';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.currentData != null) {
      _nameController.text = widget.currentData!['name'] ?? '';
      _locationController.text = widget.currentData!['location'] ?? ''; // NEW
      _priceController.text = widget.currentData!['price'] ?? '';
      _descController.text = widget.currentData!['description'] ?? '';
      _cultureController.text = widget.currentData!['culturalBackdrop'] ?? '';
      _imageController.text = widget.currentData!['imageUrl'] ?? '';
      _ratingController.text = widget.currentData!['rating']?.toString() ?? '5.0'; // NEW
      _selectedHygiene = widget.currentData!['hygieneGrade'] ?? 'A';

      // Handle Ingredients List -> String
      List<dynamic> ingList = widget.currentData!['ingredients'] ?? [];
      _ingredientsController.text = ingList.join(', '); // "Egg, Flour, Sugar"
    }
  }

  void _saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Convert comma-separated string to List
    List<String> ingredientsList = _ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final data = {
      'name': _nameController.text.trim(),
      'location': _locationController.text.trim(), // NEW
      'price': _priceController.text.trim(),
      'description': _descController.text.trim(),
      'ingredients': ingredientsList, // NEW: Saves as Array ["Egg", "Flour"]
      'rating': _ratingController.text.trim(), // NEW
      'culturalBackdrop': _cultureController.text.trim(),
      'hygieneGrade': _selectedHygiene,
      'imageUrl': _imageController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.docId == null) {
        // Add New
        data['createdAt'] = FieldValue.serverTimestamp(); // Add timestamp for new items
        await FirebaseFirestore.instance.collection('foods').add(data);
      } else {
        // Update Existing
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Add New Place" : "Edit Details", style: const TextStyle(color: Colors.white)),
        backgroundColor: theme.colorScheme.primary, // Brown Header
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Basic Info"),
              _buildTextField(_nameController, "Food Name (e.g. Roti Canai)"),
              const SizedBox(height: 16),
              _buildTextField(_locationController, "Location (e.g. Mamak Stall, KL)"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, "Price (e.g. RM 1.5)")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_ratingController, "Rating (0.0 - 5.0)", isNumber: true)),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader("Details"),
              
              // Hygiene Dropdown
              DropdownButtonFormField<String>(
                value: _selectedHygiene,
                decoration: const InputDecoration(labelText: "Hygiene Grade", border: OutlineInputBorder()),
                items: ['A', 'B', 'C'].map((grade) {
                  return DropdownMenuItem(
                    value: grade, 
                    child: Text("Grade $grade", style: TextStyle(fontWeight: FontWeight.bold, color: grade == 'A' ? Colors.green : Colors.orange))
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedHygiene = val!),
              ),
              const SizedBox(height: 16),

              _buildTextField(_descController, "Description", maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_ingredientsController, "Ingredients (separate with commas)", maxLines: 2),
              const SizedBox(height: 8),
              Text("Example: Flour, Eggs, Ghee, Sugar", style: TextStyle(fontSize: 12, color: Colors.grey[600])),

              const SizedBox(height: 16),
              _buildTextField(_cultureController, "Cultural History / Origin", maxLines: 3),

              const SizedBox(height: 32),
              _buildSectionHeader("Media"),
              _buildTextField(_imageController, "Image URL (Paste from Google)"),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary, // Orange Button
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _saveFood,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.docId == null ? "Add Place" : "Save Changes", style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title, 
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: Theme.of(context).colorScheme.primary
        )
      ),
    );
  }
}