import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'diary_service.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Vérifie si deux dates sont le même jour
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 24, 0),
        title: const Text(
          'Agenda',
          style: TextStyle(
            fontFamily: 'PixelPolice',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
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
              // ── Calendrier ───────────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 104, 24, 0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    defaultTextStyle: TextStyle(
                      fontFamily: 'PixelPolice',
                      color: Colors.white,
                    ),
                    weekendTextStyle: TextStyle(
                      fontFamily: 'PixelPolice',
                      color: Colors.white70,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      fontFamily: 'PixelPolice',
                      color: Colors.white,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      fontFamily: 'PixelPolice',
                      color: Color.fromARGB(255, 104, 24, 0),
                      fontWeight: FontWeight.bold,
                    ),
                    outsideTextStyle: TextStyle(
                      fontFamily: 'PixelPolice',
                      color: Colors.white38,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontFamily: 'PixelPolice',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontFamily: 'PixelPolice',
                      color: Colors.white70,
                    ),
                    weekendStyle: TextStyle(
                      fontFamily: 'PixelPolice',
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),

              // ── Liste des entrées du jour sélectionné ─────────────────
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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

                    // Filtrer les entrées du jour sélectionné
                    final allDocs = snapshot.data?.docs ?? [];
                    final filtered = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final date = (data['date'] as Timestamp).toDate();
                      return _isSameDay(date, _selectedDay);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No entries for\n${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'PixelPolice',
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 24, 0),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final date = (data['date'] as Timestamp)
                            .toDate()
                            .toString()
                            .substring(0, 16);

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
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}