import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryService {
  // Icons for feelings 
  static const Map<String, IconData> feelingIcons = {
    'happy': Icons.sentiment_satisfied,
    'excited': Icons.sentiment_very_satisfied,
    'sad': Icons.sentiment_dissatisfied,
    'angry': Icons.sentiment_very_dissatisfied,
    'tired': Icons.bedtime,
  };

  // Create a new diary entry
  static Future<void> createEntry(
    BuildContext context, String userEmail) async {

    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedFeeling = 'happy';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color.fromARGB(255, 104, 24, 0), width: 3),
          ),
          backgroundColor: const Color(0xFFFFF7D2),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Entry',
                    style: TextStyle(
                      fontFamily: 'PixelPolice',
                      fontSize: 24,
                      color: Color.fromARGB(255, 104, 24, 0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Title'),
                  const SizedBox(height: 6),
                  _buildTextField(titleController, 'My entry...', 1),
                  const SizedBox(height: 16),
                  _buildLabel('Feeling'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color.fromARGB(255, 104, 24, 0),
                        width: 2,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFeeling,
                        isExpanded: true,
                        items: DiaryService.feelingIcons.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Row(
                                    children: [
                                      Icon(e.value,
                                          color: Color.fromARGB(255, 104, 24, 0),
                                          size: 28),
                                      const SizedBox(width: 12),
                                      Text(
                                        e.key,
                                        style: const TextStyle(
                                          fontFamily: 'PixelPolice',
                                          color: Color.fromARGB(255, 104, 24, 0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedFeeling = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Content'),
                  const SizedBox(height: 6),
                  _buildTextField(
                      contentController, 'Write your thoughts...', 5),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'PixelPolice',
                            color: Color.fromARGB(255, 128, 30, 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty) return;
                          await FirebaseFirestore.instance
                              .collection('entries')
                              .add({
                            'email': userEmail,
                            'title': titleController.text,
                            'content': contentController.text,
                            'feeling': selectedFeeling,
                            'date': Timestamp.now(),
                          });
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 104, 24, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: 'PixelPolice',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Delete an entry
  static Future<void> deleteEntry(String docId) async {
    await FirebaseFirestore.instance.collection('entries').doc(docId).delete();
  }

  // Read an entry (show details in a dialog)
  static void readEntry(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color.fromARGB(255, 104, 24, 0), width: 3),
        ),
        backgroundColor: const Color(0xFFFFF7D2),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      DiaryService.feelingIcons[data['feeling']] ??
                          Icons.sentiment_satisfied,
                      color: Color.fromARGB(255, 104, 24, 0),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['title'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'PixelPolice',
                          fontSize: 22,
                          color: Color.fromARGB(255, 104, 24, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  (data['date'] as Timestamp)
                      .toDate()
                      .toString()
                      .substring(0, 16),
                  style: const TextStyle(
                    fontFamily: 'PixelPolice',
                    color: Color(0xFF8B6336),
                    fontSize: 12,
                  ),
                ),
                const Divider(color: Color(0xFFDFC88A), height: 24),
                Text(
                  data['content'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'PixelPolice',
                    color: Color(0xFF5C3D11),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 104, 24, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'PixelPolice',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for building UI components
  static Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'PixelPolice',
        fontSize: 14,
        color: Color.fromARGB(255, 104, 24, 0),
      ),
    );
  }

  // Helper method to build styled text fields
  static Widget _buildTextField(
      TextEditingController controller, String hint, int maxLines) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'PixelPolice',
        color: Color.fromARGB(255, 104, 24, 0),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'PixelPolice',
          color: Color.fromARGB(255, 104, 24, 0).withOpacity(0.4),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color.fromARGB(255, 104, 24, 0), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color.fromARGB(255, 104, 24, 0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color.fromARGB(255, 143, 33, 0), width: 2.5),
        ),
      ),
    );
  }
}