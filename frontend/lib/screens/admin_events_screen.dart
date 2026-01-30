import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/navigation_provider.dart';
import '../utils/constants.dart';
import 'event_details_screen.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final String adminId = user?['_id'] ?? '';
    final String adminName = user?['name'] ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          'My Events',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Provider.of<NavigationProvider>(context, listen: false).setIndex(0);
          },
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final myEvents = eventProvider.events.where((event) {
            // Updated: The backend model uses 'user' for the creator
            final creator = event['user'];

            if (creator == null) return false;

            // Handle both String ID and populated User object
            if (creator is String) {
              return creator == adminId;
            } else if (creator is Map) {
              return creator['_id'] == adminId;
            }

            return false;
          }).toList();

          if (myEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You haven't created any events yet.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Switch to Dashboard to create one!",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myEvents.length,
            itemBuilder: (context, index) {
              final event = myEvents[index];
              return _buildEventCard(context, event);
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, dynamic event) {
    final String title = event['title'] ?? 'Untitled Event';
    final String date = event['date'] ?? '';
    final String location = event['location'] ?? 'Campus';

    String imageUrl = event['imageUrl'] ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = '${AppConstants.baseImageUrl}$imageUrl';
    }

    final String category = (event['category'] ?? 'EVENT').toUpperCase();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey[300],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A4F9B),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$date • $location',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
