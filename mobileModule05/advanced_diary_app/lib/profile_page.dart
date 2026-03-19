import 'diary_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 24, 0),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('entries')
                        .where('email', isEqualTo: user.email)
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 104, 24, 0),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final allDocs = snapshot.data?.docs ?? [];
                      final lastTwo = allDocs.take(2).toList();
                      final total = allDocs.length;

                      if (allDocs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
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

                      // ── Calcul feeling stats ──────────────────────────
                      final Map<String, int> counts = {};
                      for (final doc in allDocs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final feeling = data['feeling'] ?? 'happy';
                        counts[feeling] = (counts[feeling] ?? 0) + 1;
                      }
                      final sorted = counts.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      return Column(
                        children: [
                          // ── Box Last diary entries ────────────────────
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 104, 24, 0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Last diary entries',
                                        style: TextStyle(
                                          fontFamily: 'PixelPolice',
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Total: $total',
                                        style: const TextStyle(
                                          fontFamily: 'PixelPolice',
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  itemCount: lastTwo.length,
                                  itemBuilder: (context, index) {
                                    final doc = lastTwo[index];
                                    final data = doc.data() as Map<String, dynamic>;
                                    final date = (data['date'] as Timestamp)
                                        .toDate()
                                        .toString()
                                        .substring(0, 10);

                                    return Card(
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        onTap: () => DiaryService.readEntry(context, data),
                                        leading: Icon(
                                          DiaryService.feelingIcons[data['feeling']] ??
                                              Icons.sentiment_satisfied,
                                          color: const Color.fromARGB(255, 104, 24, 0),
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
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () => DiaryService.deleteEntry(doc.id),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // ── Box Feeling stats ─────────────────────────
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 104, 24, 0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
                                  child: Text(
                                    'Feeling stats',
                                    style: TextStyle(
                                      fontFamily: 'PixelPolice',
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Divider(
                                  indent: 16,
                                  endIndent: 16,
                                  color: Colors.white,
                                ),
                                ...sorted.map((e) {
                                  final percent = (e.value / total * 100).round();
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          DiaryService.feelingIcons[e.key] ??
                                              Icons.sentiment_satisfied,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          e.key,
                                          style: const TextStyle(
                                            fontFamily: 'PixelPolice',
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '$percent%',
                                          style: const TextStyle(
                                            fontFamily: 'PixelPolice',
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              // ─── Bouton New Entry ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => DiaryService.createEntry(context, user.email!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 104, 24, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
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