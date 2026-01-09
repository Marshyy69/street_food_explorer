import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBookingScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> currentData;

  const EditBookingScreen({super.key, required this.docId, required this.currentData});

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // State variables
  late int _participants;
  late String _mealTime;
  late String _packageType;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill data from the existing booking
    _participants = widget.currentData['participants'] ?? 1;
    _mealTime = widget.currentData['mealTime'] ?? 'Dinner';
    _packageType = widget.currentData['packageType'] ?? 'Basic';
    _status = widget.currentData['status'] ?? 'Confirmed';
  }

  void _updateBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update Firestore
      await FirebaseFirestore.instance.collection('bookings').doc(widget.docId).update({
        'participants': _participants,
        'mealTime': _mealTime,
        'packageType': _packageType,
        'status': _status,
        // We don't recalculate price here to keep it simple for now, 
        // but real apps would re-run the math logic.
      });

      if (mounted) {
        Navigator.pop(context); // Go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking Updated Successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Booking"), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Customer Info"),
              Text("Customer: ${widget.currentData['customerName'] ?? 'Unknown'}", style: const TextStyle(fontSize: 16)),
              Text("Tour: ${widget.currentData['foodName'] ?? 'Unknown'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              _buildSectionTitle("Edit Details"),
              
              // 1. Status Dropdown (Admin specific)
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: "Booking Status", border: OutlineInputBorder()),
                items: ['Confirmed', 'Completed', 'Cancelled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),

              // 2. Participants
              TextFormField(
                initialValue: _participants.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Pax (Participants)", border: OutlineInputBorder()),
                onChanged: (val) => setState(() => _participants = int.tryParse(val) ?? _participants),
              ),
              const SizedBox(height: 16),

              // 3. Meal Time
              DropdownButtonFormField<String>(
                value: _mealTime,
                decoration: const InputDecoration(labelText: "Meal Session", border: OutlineInputBorder()),
                items: ['Breakfast', 'Lunch', 'Dinner', 'Supper'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _mealTime = val!),
              ),
              const SizedBox(height: 16),

              // 4. Package Type
              DropdownButtonFormField<String>(
                value: _packageType,
                decoration: const InputDecoration(labelText: "Package Type", border: OutlineInputBorder()),
                items: ['Basic', 'Premium', 'Full Tour'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _packageType = val!),
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _isLoading ? null : _updateBooking,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
    );
  }
}