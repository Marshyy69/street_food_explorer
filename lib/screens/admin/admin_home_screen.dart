import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'admin_bookings_screen.dart';
import 'manage_food_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final theme = Theme.of(context); // Access the Brown/Orange theme

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Cream Background
      body: Column(
        children: [
          // --- 1. Custom Admin Header ---
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary, // Heritage Brown
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Portal",
                      style: TextStyle(fontSize: 14, color: Colors.orange[100]),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Logout Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await auth.signOut();
                      if (context.mounted) {
                         Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (_) => const LoginScreen()), 
                          (route) => false
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),

          // --- 2. Dashboard Grid ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GridView.count(
                crossAxisCount: 1, // 1 Card per row for a focused look
                childAspectRatio: 2.2, // Wide cards
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _AdminCard(
                    icon: Icons.confirmation_number_outlined,
                    title: "View Reservations",
                    subtitle: "Check & Edit customer bookings",
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
                  ),
                  _AdminCard(
                    icon: Icons.storefront_outlined,
                    title: "Manage Stalls",
                    subtitle: "Add, Edit or Remove food spots",
                    color: Colors.orange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageFoodScreen())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon, 
    required this.title, 
    required this.subtitle, 
    required this.color, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.brown.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Icon Circle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      color: Colors.brown[900], 
                      fontWeight: FontWeight.bold, 
                      fontSize: 18
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle, 
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}