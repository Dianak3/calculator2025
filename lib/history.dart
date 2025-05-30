import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryManager {
  static final HistoryManager _instance = HistoryManager._internal();

  factory HistoryManager() => _instance;

  HistoryManager._internal();

  final CollectionReference _historyRef =
      FirebaseFirestore.instance.collection('history');

  Future<void> addHistory(String entry) async {
    await _historyRef.add({
      'entry': entry,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getHistory() async {
    final snapshot = await _historyRef
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc['entry'] as String).toList();
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История')),
      body: FutureBuilder<List<String>>(
        future: HistoryManager().getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!;
          if (history.isEmpty) {
            return const Center(child: Text('История пуста'));
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(history[index]),
              );
            },
          );
        },
      ),
    );
  }
}
