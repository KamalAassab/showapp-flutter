import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'add_show_page.dart';
import 'profile_page.dart';
import 'update_show_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> movies = [];
  List<dynamic> anime = [];
  List<dynamic> series = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShows();
  }

  Future<void> fetchShows() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      debugPrint('Fetching shows from: ${ApiConfig.baseUrl}/shows');

      // Add timeout and retry logic
      int retryCount = 0;
      const maxRetries = 3;
      const timeout = Duration(seconds: 10);

      while (retryCount < maxRetries) {
        try {
          final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/shows'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ).timeout(timeout);

          debugPrint('Response status code: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');

          if (!mounted) return;

          if (response.statusCode == 200) {
            List<dynamic> allShows = jsonDecode(response.body);
            debugPrint('Successfully decoded ${allShows.length} shows');

            setState(() {
              movies = allShows
                  .where((show) => show['category'] == 'movie')
                  .toList();
              anime = allShows
                  .where((show) => show['category'] == 'anime')
                  .toList();
              series = allShows
                  .where((show) => show['category'] == 'serie')
                  .toList();
              isLoading = false;
            });
            return; // Success, exit the function
          } else {
            throw HttpException(
                'Failed to load shows: ${response.statusCode}\nResponse: ${response.body}');
          }
        } on TimeoutException {
          retryCount++;
          if (retryCount == maxRetries) {
            throw TimeoutException(
                'Connection timed out after $maxRetries attempts. Please check your internet connection and try again.');
          }
          // Wait before retrying
          await Future.delayed(const Duration(seconds: 2));
          continue;
        } on SocketException catch (e) {
          throw SocketException(
              'Unable to connect to the server. Please check if the server is running and your internet connection.\nError: ${e.message}');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching shows: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!mounted) return;
      setState(() => isLoading = false);

      String errorMessage = 'An error occurred while fetching shows.';
      if (e is SocketException) {
        errorMessage =
            'Unable to connect to the server. Please check your internet connection and server status.';
      } else if (e is TimeoutException) {
        errorMessage =
            'Connection timed out. Please check your internet connection and try again.';
      } else if (e is HttpException) {
        errorMessage = e.message;
      } else if (e is FormatException) {
        errorMessage = 'Invalid response format from server.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: fetchShows,
          ),
        ),
      );
    }
  }

  Future<bool> deleteShow(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/shows/$id'),
      );

      if (!mounted) return false;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Show deleted successfully")),
        );
        await fetchShows();
        return true;
      } else {
        throw Exception('Failed to delete show: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete show: ${e.toString()}")),
      );
      return false;
    }
  }

  Future<void> confirmDelete(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Show"),
        content: const Text("Are you sure you want to delete this show?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteShow(id);
    }
  }

  Widget _getBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<dynamic> currentShows;
    switch (_selectedIndex) {
      case 0:
        currentShows = movies;
        break;
      case 1:
        currentShows = anime;
        break;
      case 2:
        currentShows = series;
        break;
      default:
        currentShows = [];
    }

    if (currentShows.isEmpty) {
      return const Center(
        child: Text(
          "No shows available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ShowList(shows: currentShows, onDelete: confirmDelete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show App", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchShows,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Colors.blueAccent),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Show App Menu",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Show"),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddShowPage()),
                );
                if (result == true) {
                  fetchShows();
                }
              },
            ),
          ],
        ),
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Anime"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"),
        ],
      ),
    );
  }
}

class ShowList extends StatelessWidget {
  final List<dynamic> shows;
  final Function(int) onDelete;

  const ShowList({super.key, required this.shows, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: shows.length,
      itemBuilder: (context, index) {
        final show = shows[index];
        return Dismissible(
          key: Key(show['id'].toString()),
          direction: DismissDirection.horizontal,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Edit action
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateShowPage(show: show),
                ),
              );
              if (result == true) {
                // Refresh the list
                (context.findAncestorStateOfType<_HomePageState>())
                    ?.fetchShows();
              }
              return false;
            } else {
              // Delete action
              await onDelete(show['id']);
              return false;
            }
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateShowPage(show: show),
                  ),
                ).then((result) {
                  if (result == true) {
                    (context.findAncestorStateOfType<_HomePageState>())
                        ?.fetchShows();
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: show['image'] != null
                          ? Image.network(
                              ApiConfig.getImageUrl(show['image']),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.movie,
                                      color: Colors.grey),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child:
                                  const Icon(Icons.movie, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            show['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            show['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
