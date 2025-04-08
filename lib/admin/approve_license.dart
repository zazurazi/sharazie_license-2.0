import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveLicensePage extends StatefulWidget {
  @override
  _ApproveLicensePageState createState() => _ApproveLicensePageState();
}

class _ApproveLicensePageState extends State<ApproveLicensePage> {
  Future<void> updateLicenseStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('certificates').doc(docId).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? "License approved! User can now generate a PDF."
                : "License rejected.",
          ),
          backgroundColor: status == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print("Error updating license: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update license."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Image.asset('lib/assets/logo.jpeg', width: 35, height: 35),
            const SizedBox(width: 0),
            const Text(
              "License Approvals",
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('certificates')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No pending licenses.",
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            );
          }

          var licenses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: licenses.length,
            itemBuilder: (context, index) {
              var license = licenses[index];
              var data = license.data() as Map<String, dynamic>? ?? {};

              final name = data['name'] ?? 'Unknown';
              final phone = data['referenceNumber'] ?? 'Phone not available';
              final createdBy = data['createdBy'] ?? 'Unknown email';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  shadowColor: Colors.black.withOpacity(0.3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(29),
                      border: Border.all(color: Colors.black),
                    ),
                    child: ListTile(
                      title: Text(
                        "License ID: ${license.id}",
                        style: const TextStyle(
                          fontFamily: 'SFProRounded',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            "Applicant: $name",
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Phone: $phone",
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Submitted by: $createdBy",
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => updateLicenseStatus(license.id, 'approved'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => updateLicenseStatus(license.id, 'rejected'),
                          ),
                        ],
                      ),
                    ),
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
