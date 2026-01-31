import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = "Academic";
  bool _pushNotification = true;
  bool _enableRSVP = false;
  bool _isSubmitting = false;
  XFile? _image;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (selected != null) {
      if (kIsWeb) {
        final bytes = await selected.readAsBytes();
        setState(() {
          _image = selected;
          _webImage = bytes;
        });
      } else {
        setState(() => _image = selected);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _uploadPoster(),
              const SizedBox(height: 24),

              _section("General Info"),
              _label("Event Title"),
              _input(_titleController, "e.g. Annual Tech Symposium"),
              const SizedBox(height: 16),

              _label("Category"),
              _categorySelector(),
              const SizedBox(height: 24),

              _section("Logistics"),
              Row(
                children: [
                  Expanded(child: _dateField()),
                  const SizedBox(width: 12),
                  Expanded(child: _timeField()),
                ],
              ),
              const SizedBox(height: 16),

              _label("Location"),
              _input(
                _locationController,
                "Student Union, Room 204",
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),

              _section("Description"),
              _descriptionBox(),
              const SizedBox(height: 24),

              _toggle(
                title: "Send Push Notification",
                subtitle: "Alert students immediately",
                value: _pushNotification,
                onChanged: (v) => setState(() => _pushNotification = v),
              ),
              _toggle(
                title: "Enable RSVP",
                subtitle: "Collect attendance headcount",
                value: _enableRSVP,
                onChanged: (v) => setState(() => _enableRSVP = v),
              ),

              const SizedBox(height: 32),
              _bottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= APP BAR =================
  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Cancel"),
      ),
      title: const Text("Create Event", style: TextStyle(color: Colors.black)),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: const Text(
            "Publish",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ================= UPLOAD POSTER =================
  Widget _uploadPoster() {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        dashPattern: const [6, 4],
        color: Colors.grey.shade400,
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: kIsWeb
                      ? (_webImage != null
                          ? Image.memory(
                              _webImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : const Center(child: CircularProgressIndicator()))
                      : Image.file(
                          File(_image!.path),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.camera_alt, color: Colors.blue),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Upload Event Poster",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Recommended size: 1200 x 630px",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _pickImage,
                      child: const Text(
                        "Add Image",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ================= CATEGORY =================
  Widget _categorySelector() {
    return Row(
      children: ["Academic", "Social", "Sports"].map((c) {
        final selected = _category == c;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(c),
            selected: selected,
            onSelected: (_) => setState(() => _category = c),
            backgroundColor: Colors.white,
            selectedColor: Colors.blue.withOpacity(0.15),
            side: BorderSide(
              color: selected ? Colors.blue : Colors.grey.shade300,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.blue : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================= DATE & TIME =================
  Widget _dateField() {
    return _input(
      _dateController,
      "Oct 24, 2023",
      icon: Icons.calendar_today_outlined,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          _dateController.text = "${date.month}/${date.day}/${date.year}";
        }
      },
    );
  }

  Widget _timeField() {
    return _input(
      _timeController,
      "10:00 AM",
      icon: Icons.access_time,
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null && mounted) {
          _timeController.text = time.format(context);
        }
      },
    );
  }

  // ================= DESCRIPTION =================
  Widget _descriptionBox() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: _decoration("Share the details about the event..."),
    );
  }

  // ================= TOGGLE =================
  Widget _toggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  // ================= BOTTOM BUTTONS =================
  Widget _bottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: const Text("Save Draft"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _submit,
            child: const Text("Publish Event"),
          ),
        ),
      ],
    );
  }

  // ================= SUBMIT =================
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      String? imageUrl;
      if (_image != null) {
        final bytes = _webImage ?? await _image!.readAsBytes();
        imageUrl = await eventProvider.uploadImage(bytes, _image!.name);
      }

      if (!mounted) return;

      await eventProvider.addEvent({
        "title": _titleController.text,
        "category": _category,
        "date": _dateController.text,
        "time": _timeController.text,
        "location": _locationController.text,
        "description": _descriptionController.text,
        "pushNotification": _pushNotification,
        "rsvp": _enableRSVP,
        "imageUrl": imageUrl,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ================= HELPERS =================
  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      t,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _label(String t) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t));

  Widget _input(
    TextEditingController c,
    String h, {
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: c,
      readOnly: readOnly,
      onTap: onTap,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: _decoration(h, icon: icon),
    );
  }

  InputDecoration _decoration(String h, {IconData? icon}) {
    return InputDecoration(
      hintText: h,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
