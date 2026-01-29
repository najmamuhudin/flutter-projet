import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import 'event_details_screen.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Event Data
    final List<Map<String, dynamic>> events = [
      {
        'title': 'Annual Tech Symposium 2024',
        'date': 'Oct 24',
        'time': '10:00 AM - 4:00 PM',
        'location': 'Main Auditorium',
        'category': 'ACADEMIC',
        'imageUrl': 'https://images.unsplash.com/photo-1523580846011-d3a5bc2546eb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1351&q=80',
        'description': 'The Annual Tech Symposium brings together leading industry experts, academic researchers, and student innovators for a day of inspiration.',
      },
      {
        'title': 'Basketball Finals',
        'date': 'Nov 02',
        'time': '5:00 PM - 8:00 PM',
        'location': 'Sports Complex',
        'category': 'SPORTS',
        'imageUrl': 'https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-1.2.1&auto=format&fit=crop&w=1351&q=80',
        'description': 'Cheer for your team at the inter-university basketball finals! Exciting matches and halftime shows await.',
      },
      {
        'title': 'Music Night',
        'date': 'Nov 10',
        'time': '7:00 PM - 10:00 PM',
        'location': 'Open Air Theatre',
        'category': 'CULTURAL',
        'imageUrl': 'https://images.unsplash.com/photo-1459749411177-287ce379a899?ixlib=rb-1.2.1&auto=format&fit=crop&w=1351&q=80',
        'description': 'A night of melodies and rhythm featuring performances by the university band and guest artists.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Events',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Column(
             children: [
               _buildEventCard(context, event),
               const SizedBox(height: 20),
             ],
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(event['imageUrl']),
            fit: BoxFit.cover,
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event['category'],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${event['date']} • ${event['location']}',
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
