import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<dynamic> _announcements = [];
  List<dynamic> _inquiries = [];
  bool _isLoading = false;

  List<dynamic> get announcements => _announcements;
  List<dynamic> get inquiries => _inquiries;
  bool get isLoading => _isLoading;

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();
    try {
      _announcements = await _adminService.getAnnouncements();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postAnnouncement(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminService.postAnnouncement(data);
      await fetchAnnouncements();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInquiries() async {
    _isLoading = true;
    notifyListeners();
    try {
      _inquiries = await _adminService.getInquiries();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendInquiry(String subject, String message) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminService.postInquiry({'subject': subject, 'message': message});
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveInquiry(String id) async {
    try {
      await _adminService.resolveInquiry(id);
      await fetchInquiries();
    } catch (e) {
      rethrow;
    }
  }
}
