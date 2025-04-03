import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';

class UpdateShowPage extends StatefulWidget {
  final Map<String, dynamic> show;

  const UpdateShowPage({
    super.key,
    required this.show,
  });

  @override
  _UpdateShowPageState createState() => _UpdateShowPageState();
}

class _UpdateShowPageState extends State<UpdateShowPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'movie';
  XFile? _imageFile;
  bool _isUploading = false;
  String? _imageUrl;

  final List<String> _categories = [
    'movie',
    'anime',
    'serie',
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.show['title'] ?? '';
    _descriptionController.text = widget.show['description'] ?? '';
    final category =
        widget.show['category']?.toString().toLowerCase() ?? 'movie';
    _selectedCategory = _categories.contains(category) ? category : 'movie';
    _imageUrl = widget.show['image'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = image;
          _imageUrl = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _updateShow() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}/shows/${widget.show['id']}');
      var request = http.MultipartRequest('PUT', uri);

      // Add headers
      request.headers.addAll(ApiConfig.headers);

      // Add form fields
      request.fields['title'] = _titleController.text.trim();
      request.fields['description'] = _descriptionController.text.trim();
      request.fields['category'] = _selectedCategory;

      // Handle image upload if a new image was selected
      if (_imageFile != null) {
        if (kIsWeb) {
          final bytes = await _imageFile!.readAsBytes();
          final stream = http.ByteStream.fromBytes(bytes);
          final length = bytes.length;
          final multipartFile = http.MultipartFile(
            'image',
            stream,
            length,
            filename: _imageFile!.name,
          );
          request.files.add(multipartFile);
        } else {
          final file = await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
            filename: _imageFile!.name,
          );
          request.files.add(file);
        }
      }

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'The connection has timed out. Please try again.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Show updated successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        String errorMessage = 'Failed to update show';
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);

      String errorMessage = 'Error: ${e.toString()}';
      if (e.toString().contains('Failed to fetch')) {
        errorMessage =
            'Could not connect to the server. Please make sure the backend is running.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Connection timed out. Please check your internet connection and try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _updateShow,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Show"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imageFile != null
                      ? kIsWeb
                          ? Image.network(
                              _imageFile!.path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            )
                      : _imageUrl != null
                          ? Image.network(
                              ApiConfig.getImageUrl(_imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Tap to add image',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 20),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category[0].toUpperCase() + category.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Update Button
              ElevatedButton(
                onPressed: _isUploading ? null : _updateShow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Update Show',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
