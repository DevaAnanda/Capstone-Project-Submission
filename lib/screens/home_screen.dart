import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/mood_provider.dart';
import '../models/mood_model.dart';
import 'add_edit_mood_screen.dart';
import 'mood_detail_screen.dart';
import 'statistics_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load moods when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MoodProvider>(context, listen: false).loadMoods();
    });
  }

  // Mood emoji mapping
  String getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'sangat bahagia':
        return '😄';
      case 'bahagia':
        return '😊';
      case 'netral':
        return '😐';
      case 'sedih':
        return '😢';
      case 'sangat sedih':
        return '😭';
      default:
        return '😐';
    }
  }

  // Mood color mapping
  Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'sangat bahagia':
        return Colors.green.shade700;
      case 'bahagia':
        return Colors.green.shade400;
      case 'netral':
        return Colors.grey;
      case 'sedih':
        return Colors.orange.shade400;
      case 'sangat sedih':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MoodTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistik',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          if (moodProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (moodProvider.moods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mood,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada mood tercatat',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambah mood',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: moodProvider.moods.length,
            itemBuilder: (context, index) {
              final mood = moodProvider.moods[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: getMoodColor(mood.mood),
                    child: Text(
                      getMoodEmoji(mood.mood),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  title: Text(
                    mood.mood,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mood.note.length > 50
                            ? '${mood.note.substring(0, 50)}...'
                            : mood.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(mood.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  trailing: mood.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(mood.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoodDetailScreen(mood: mood),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditMoodScreen(),
            ),
          );
        },
        tooltip: 'Tambah Mood',
        child: const Icon(Icons.add),
      ),
    );
  }
}
