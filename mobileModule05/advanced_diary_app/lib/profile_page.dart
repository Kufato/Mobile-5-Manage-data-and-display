import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diary_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D2),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 104, 24, 0),
        title: Text(
          user.email ?? '',
          style: const TextStyle(
            fontFamily: 'PixelPolice',
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_profil.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('entries')
                      .where('email', isEqualTo: user.email)
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 104, 24, 0)));
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No entries yet.\nTap the button to create one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PixelPolice',
                            fontSize: 18,
                            color: Color.fromARGB(255, 104, 24, 0),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final date = (data['date'] as Timestamp)
                            .toDate()
                            .toString()
                            .substring(0, 10);

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: Color.fromARGB(255, 104, 24, 0), width: 1.5),
                          ),
                          child: ListTile(
                            onTap: () => DiaryService.readEntry(context, data),
                            leading: Icon(
                              DiaryService.feelingIcons[data['feeling']] ??
                                  Icons.sentiment_satisfied,
                              color: Color.fromARGB(255, 104, 24, 0),
                              size: 32,
                            ),
                            title: Text(
                              data['title'] ?? '',
                              style: const TextStyle(
                                fontFamily: 'PixelPolice',
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 104, 24, 0),
                              ),
                            ),
                            subtitle: Text(
                              date,
                              style: const TextStyle(
                                fontFamily: 'PixelPolice',
                                color: Color.fromARGB(255, 104, 24, 0),
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => DiaryService.deleteEntry(doc.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => DiaryService.createEntry(context, user.email!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 104, 24, 0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'New Entry +',
                    style: TextStyle(
                      fontFamily: 'PixelPolice',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}