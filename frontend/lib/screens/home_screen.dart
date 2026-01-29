import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import 'event_details_screen.dart';
import 'profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user; // Get user data
    final userName = user?['name'] ?? 'Student';
    final userEmail = user?['email'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      // Drawer removed for custom Zoom Drawer implementation
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          size: 30,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // Reset to Home tab whenever menu is clicked
                          Provider.of<NavigationProvider>(
                            context,
                            listen: false,
                          ).setIndex(0);
                          // Toggles the custom Zoom Drawer
                          ZoomDrawer.of(context)?.toggle();
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        }, // Link to Profile
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user?['profileImage'] ??
                                'https://i.pravatar.cc/150?u=student',
                          ),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Handle error
                          },
                          child: (user?['profileImage'] == null)
                              ? const Icon(Icons.person)
                              : null,
                          radius: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName, // Dynamic Name
                      style: GoogleFonts.merriweather(
                        // Serif font for name if available, or just Bold Inter
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar removed or kept? User didn't explicitly ask to remove, but previous design has it commented out.
              // I'll keep the structure as is, focusing on adding the drawer.

              // Featured Events Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Events',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'See all',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Scrollable Events
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFeaturedEventCard(
                      context,
                      'Annual Spring Fest',
                      'March 20 • Main Quad',
                      'https://images.unsplash.com/photo-1523050853063-913a6e046732?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                    ),
                    const SizedBox(width: 16),
                    _buildFeaturedEventCard(
                      context,
                      'Hackathon 2024',
                      'April 15 • Tech Hub',
                      'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Campus News Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Campus News',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // News List
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildNewsItem(
                    category: 'ACADEMIC',
                    title: 'New Library Hours Announced for Finals Week',
                    time: '2 hours ago',
                    description:
                        'Starting next Monday, the campus library will be open 24/7 to accommodate students...',
                    imageUrl:
                        'https://images.unsplash.com/photo-1523580846011-d3a5bc2546eb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                  ),
                  const SizedBox(height: 24),
                  _buildNewsItem(
                    category: 'COMMUNITY',
                    title: 'Student Union Election Results Are In!',
                    time: '5 hours ago',
                    description:
                        'The votes have been counted and we are excited to announce your new student...',
                    imageUrl:
                        'https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                  ),
                ],
              ),
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[800]),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[900],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildFeaturedEventCard(
    BuildContext context,
    String title,
    String subtitle,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        // specific featured event data
        final event = {
          'title': title,
          'date': subtitle.split('•')[0].trim(),
          'location': subtitle.split('•').length > 1
              ? subtitle.split('•')[1].trim()
              : 'Campus',
          'imageUrl': imageUrl,
          'category': 'FEATURED',
          'description':
              'This is a featured event on campus. Don\'t miss out on this exciting opportunity!',
          'time': 'TBA',
        };
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
        );
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem({
    required String category,
    required String title,
    required String time,
    required String description,
    required String imageUrl,
  }) {
    // Based on the second screenshot (light mode list)
    // The screenshot shows a list where images are sometimes on the right or hidden?
    // Wait, the "Campus News" screenshot (3rd image) has big images for "Featured" but "Campus News" items look like standard cards or tiles.
    // Let's implement them as cards with a small chip for category.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            Row(
              children: [
                Icon(Icons.share, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
