import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/mood_model.dart';
import '../services/mood_provider.dart';

class AddEditMoodScreen extends StatefulWidget {
  final MoodEntry? mood;

  const AddEditMoodScreen({super.key, this.mood});

  @override
  State<AddEditMoodScreen> createState() => _AddEditMoodScreenState();
}

class _AddEditMoodScreenState extends State<AddEditMoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  String _selectedMood = 'Netral';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _moodOptions = [
    'Sangat Bahagia',
    'Bahagia',
    'Netral',
    'Sedih',
    'Sangat Sedih',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.mood != null) {
      _selectedMood = widget.mood!.mood;
      _noteController.text = widget.mood!.note;
      if (widget.mood!.imagePath != null) {
        _selectedImage = File(widget.mood!.imagePath!);
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error mengambil foto: $e')),
        );
      }
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memilih gambar: $e')),
        );
      }
    }
  }

  // Show image source selection
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Save mood
  Future<void> _saveMood() async {
    if (_formKey.currentState!.validate()) {
      final moodEntry = MoodEntry(
        id: widget.mood?.id,
        mood: _selectedMood,
        note: _noteController.text,
        date: widget.mood?.date ?? DateTime.now(),
        imagePath: _selectedImage?.path,
      );

      final moodProvider = Provider.of<MoodProvider>(context, listen: false);

      if (widget.mood == null) {
        await moodProvider.addMood(moodEntry);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mood berhasil ditambahkan')),
          );
        }
      } else {
        await moodProvider.updateMood(moodEntry);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mood berhasil diperbarui')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // Get mood emoji
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.mood != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Mood' : 'Tambah Mood'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Mood Selection
            const Text(
              'Bagaimana perasaanmu?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _moodOptions.map((mood) {
                final isSelected = _selectedMood == mood;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(getMoodEmoji(mood), style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 4),
                      Text(mood),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Note Input
            const Text(
              'Ceritakan lebih detail',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Apa yang membuatmu merasa demikian?',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mohon ceritakan perasaanmu';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Image Selection
            const Text(
              'Foto (opsional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Tambah Foto'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveMood,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                isEditing ? 'Perbarui Mood' : 'Simpan Mood',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
