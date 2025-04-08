import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({Key? key}) : super(key: key);

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  String searchQuery = "";

  Future<void> updateUserRole(String userId, String newRole) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({'role': newRole});
    setState(() {});
  }

  Future<void> deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // Keep AppBar white
        elevation: 0, // Remove shadow
        scrolledUnderElevation: 0, // Prevents color change when scrolling
        title: Row(
          children: [
            Image.asset('lib/assets/logo.jpeg', width: 35, height: 35), // Add logo
            const SizedBox(width: 0),
            const Text(
              "Manage Users",
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),


      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search Users",
                labelStyle: const TextStyle(fontFamily: 'SFProRounded'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs.where((doc) {
                  var name = doc['name'].toString().toLowerCase();
                  var email = doc['email'].toString().toLowerCase();
                  return name.contains(searchQuery) || email.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'SFProRounded',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Role: ${user['role']}\nEmail: ${user['email']}",
                          style: const TextStyle(fontFamily: 'SFProRounded'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent, // Transparent background for the button
                                borderRadius: BorderRadius.circular(12), // Rounded corners
                                border: Border.all(color: Colors.black, width: 1), // Optional border
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: user['role'],
                                  dropdownColor: Colors.white.withOpacity(0.9), // Transparent dropdown menu
                                  style: const TextStyle(fontFamily: 'SFProRounded', color: Colors.black),
                                  borderRadius: BorderRadius.circular(12), // Rounded dropdown menu
                                  items: ["user", "admin"].map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(role),
                                    );
                                  }).toList(),
                                  onChanged: (newRole) {
                                    if (newRole != null) {
                                      updateUserRole(user.id, newRole);
                                    }
                                  },
                                ),
                              ),
                            ),


                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteUser(user.id);
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
          ),
        ],
      ),
    );
  }
}
