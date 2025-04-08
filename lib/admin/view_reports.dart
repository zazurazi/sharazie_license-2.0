import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewReports extends StatefulWidget {
  const ViewReports({Key? key}) : super(key: key);

  @override
  State<ViewReports> createState() => _ViewReportsState();
}

class _ViewReportsState extends State<ViewReports> {
  final CollectionReference reportsRef =
  FirebaseFirestore.instance.collection('reports');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo.jpeg', // Ensure this path is correct
              height: 35,
            ),
            const SizedBox(width: 8),
            const Text(
              "View Reports",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'SFProRounded',
                color: Colors.black,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: reportsRef.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading reports",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No reports available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          var reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              var report = reports[index];

              // ✅ Safely extract data with error handling
              Map<String, dynamic>? reportData =
              report.data() as Map<String, dynamic>?;

              if (reportData == null) {
                return const SizedBox(); // Skip if data is null
              }

              String title = reportData['title'] ?? "No Title";
              String description = reportData['description'] ?? "No Description";
              String reportedBy = reportData['reportedBy'] ?? "Unknown";

              // ✅ Handle missing or incorrect date format
              dynamic dateField = reportData['date'];
              String formattedDate = "No Date";

              if (dateField is Timestamp) {
                formattedDate =
                "${dateField.toDate().day}/${dateField.toDate().month}/${dateField.toDate().year}"; // Format as DD/MM/YYYY
              } else if (dateField is String) {
                formattedDate = dateField; // If already stored as a string
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.black, width: 2.5),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SFProRounded',
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(fontFamily: 'SFProRounded'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Reported by: $reportedBy",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        "Date: $formattedDate",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
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
}
