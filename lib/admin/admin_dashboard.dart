import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_page.dart';
import 'manage_users.dart';
import 'view_reports.dart';
import 'admin_settings.dart';
import 'system_config.dart';
import 'approve_license.dart'; // Added missing import

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  int totalLicenses = 0;
  int pendingApplications = 0;
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      QuerySnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        totalUsers = userSnapshot.size;
      });

      QuerySnapshot licenseSnapshot = await FirebaseFirestore.instance
          .collection('licenses')
          .where('status', isEqualTo: 'approved')
          .get();

      QuerySnapshot pendingSnapshot = await FirebaseFirestore.instance
          .collection('licenses')
          .where('status', isEqualTo: 'pending')
          .get();

      QuerySnapshot invoiceSnapshot =
      await FirebaseFirestore.instance.collection('invoices').get();

      double revenue = invoiceSnapshot.docs.fold(
          0.0, (sum, doc) => sum + (doc['amount'] ?? 0.0));

      setState(() {
        totalLicenses = licenseSnapshot.size;
        pendingApplications = pendingSnapshot.size;
        totalRevenue = revenue;
      });
    } catch (e) {
      print("Error fetching analytics: $e");
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('lib/assets/logo.jpeg', width: 35, height: 35),
            const SizedBox(width: 0),
            const Text(
              "Admin Dashboard",
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'SFProRounded',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard Overview",
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'SFProRounded',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingStatCard("Total Users", totalUsers.toString()),
                _buildFloatingStatCard(
                    "Licenses Issued", totalLicenses.toString()),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingStatCard(
                    "Pending Applications", pendingApplications.toString()),
                _buildFloatingStatCard(
                    "Total Revenue", "\$${totalRevenue.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 50),

            const Text(
              "Manage System",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFProRounded',
                  color: Colors.black),
            ),
            const SizedBox(height: 20),

            _buildFloatingButton(
                "Manage Users", Icons.people, const ManageUsers()),
            const SizedBox(height: 15),
            _buildFloatingButton(
                "View Reports", Icons.bar_chart, const ViewReports()),
            const SizedBox(height: 15),
            _buildFloatingButton(
                "Admin Settings", Icons.settings, AdminSettingsPage()),
            const SizedBox(height: 15),
            _buildFloatingButton(
                "System Configurations", Icons.build, SystemConfigPage()),
            const SizedBox(height: 15),
            _buildFloatingButton(
                "Approve Licenses", Icons.verified, ApproveLicensePage()), // Fixed button
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'SFProRounded',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'SFProRounded',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(String text, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'SFProRounded',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
