import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _dbService.fetchDiagnoses();
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF008F6B);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Patient History | የታካሚ ታሪክ",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: emeraldGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: emeraldGreen),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error loading history: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No records found.",
                    style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final records = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = records[index];
              final bool isEmergency = record['isEmergency'] == 1;
              final DateTime date = DateTime.parse(record['timestamp']);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isEmergency
                        ? Colors.red.withValues(alpha: 0.1)
                        : emeraldGreen.withValues(alpha: 0.1),
                    child: Icon(
                      isEmergency ? Icons.report_problem : Icons.medication,
                      color: isEmergency ? Colors.red : emeraldGreen,
                    ),
                  ),
                  title: Text(
                    record['patientName'] ?? "Unknown Patient",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${record['rdtResult']} | ${record['weight']}kg",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(date),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    isEmergency ? Icons.priority_high : Icons.check_circle,
                    color: isEmergency ? Colors.red : emeraldGreen,
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
