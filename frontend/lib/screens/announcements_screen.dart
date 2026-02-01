import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import 'post_announcement_screen.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAnnouncements();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Announcements',
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
      body: Column(
        children: [
          // Tabs
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: const Color(0xFF3A4F9B),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Academic'),
                Tab(text: 'Urgent'),
              ],
            ),
          ),

          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, _) {
                if (adminProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final announcements = adminProvider.announcements;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFilteredList(announcements, 'General'),
                    _buildFilteredList(announcements, 'Academic'),
                    _buildFilteredList(announcements, 'Urgent'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList(List<dynamic> all, String type) {
    List<dynamic> filtered;
    if (type == 'Urgent') {
      filtered = all.where((a) => a['urgent'] == true).toList();
    } else {
      // If the backend doesn't have a specific category yet, we show all in general or filter by a field if exists
      // Assuming audience or some other field might be used, or just showing all for now
      filtered = all;
    }

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No $type announcements found.",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final a = filtered[index];
        return _buildAnnouncementCard(
          announcement: a,
          title: a['title'] ?? 'Untitled',
          category: (a['urgent'] == true) ? 'URGENT' : 'GENERAL',
          date: _formatDate(a['createdAt']),
          description: a['message'] ?? '',
          isUrgent: a['urgent'] == true,
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return '';
    }
  }

  Widget _buildAnnouncementCard({
    required Map<String, dynamic> announcement,
    required String title,
    required String category,
    required String date,
    required String description,
    bool isUrgent = false,
  }) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final bool isAdmin = user != null && user['role'] == 'admin';
    final color = isUrgent ? Colors.red : const Color(0xFF3A4F9B);
    final icon = isUrgent ? Icons.warning_amber_rounded : Icons.campaign;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostAnnouncementScreen(
                            announcement: announcement,
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Announcement"),
                          content: const Text(
                            "Are you sure you want to delete this announcement?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await Provider.of<AdminProvider>(
                          context,
                          listen: false,
                        ).deleteAnnouncement(announcement['_id']);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Color(0xFF3A4F9B)),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                )
              else
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                date,
                style: TextStyle(color: Colors.grey[400], fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
