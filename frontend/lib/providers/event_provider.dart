import 'package:flutter/material.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();
  List<dynamic> _events = [];
  bool _isLoading = false;

  List<dynamic> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();
    try {
      _events = await _eventService.getEvents();
    } catch (e) {
      print(e);
      // Handle error cleanly or expose it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(Map<String, dynamic> eventData) async {
    try {
      final newEvent = await _eventService.createEvent(eventData);
      _events.insert(0, newEvent); // Add to top
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadImage(List<int> bytes, String filename) async {
    return await _eventService.uploadImage(bytes, filename);
  }

  Future<void> registerForEvent(String eventId) async {
    try {
      await _eventService.registerForEvent(eventId);
      await fetchEvents(); // Refresh to get updated attendee list
    } catch (e) {
      rethrow;
    }
  }
}
