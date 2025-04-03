import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;
  String _name = "John Doe";
  String _email = "johndoe@email.com";
  bool _isLoading = true;
  final String _profileKey = 'user_profile';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateProfileData(String newName, String newEmail) async {
    setState(() {
      _name = newName;
      _email = newEmail;
    });
    // Save to local storage
    await _saveProfileToLocal();
  }

  Future<void> _saveProfileToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _profileKey,
          json.encode({
            'name': _name,
            'email': _email,
          }));
    } catch (e) {
      debugPrint('Error saving profile to local storage: $e');
    }
  }

  Future<void> _loadProfileFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileStr = prefs.getString(_profileKey);
      if (profileStr != null) {
        final profileData = json.decode(profileStr);
        setState(() {
          _name = profileData['name'] ?? _name;
          _email = profileData['email'] ?? _email;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile from local storage: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    // First load from local storage
    await _loadProfileFromLocal();
    // Then try to fetch from server
    await _fetchProfile();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await http
          .get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: ApiConfig.headers,
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _name = data['name'] ?? _name;
          _email = data['email'] ?? _email;
        });
        // Save the fetched data to local storage
        await _saveProfileToLocal();
      } else if (response.statusCode == 404) {
        // Profile endpoint doesn't exist, use local data
        debugPrint('Profile endpoint not found, using local data');
        return;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // Only show error message if we don't have local data
      if (_name == "John Doe" && _email == "johndoe@email.com") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchProfile,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      ProfileView(name: _name, email: _email),
      UpdateProfileView(
        initialName: _name,
        initialEmail: _email,
        onUpdate: _updateProfileData,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit), label: "Edit Profile"),
        ],
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  final String name;
  final String email;

  const ProfileView({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                profileItem(Icons.movie, "My Shows"),
                profileItem(Icons.favorite, "Favorites"),
                profileItem(Icons.settings, "Settings"),
                profileItem(Icons.logout, "Logout"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profileItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}

class UpdateProfileView extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final Function(String, String) onUpdate;

  const UpdateProfileView({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.onUpdate,
  });

  @override
  _UpdateProfileViewState createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<UpdateProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email cannot be empty")),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      // Call the parent's update function
      widget.onUpdate(
        _nameController.text.trim(),
        _emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile: ${e.toString()}"),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _updateProfile,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "Update Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Full Name",
              prefixIcon: const Icon(Icons.person),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: const Icon(Icons.email),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isUpdating ? null : _updateProfile,
            child: _isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Save Changes", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
