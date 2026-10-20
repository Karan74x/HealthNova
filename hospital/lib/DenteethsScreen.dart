import 'package:flutter/material.dart';

class DentistScreen extends StatelessWidget {
  const DentistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),

        title: const Text("Dentist Profile"),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DentistHeader(),
            SizedBox(height: 20),
            DentistExperience(),
            SizedBox(height: 20),
            ClinicPhotos(),
            SizedBox(height: 20),
            AppointmentSection(),
          ],
        ),
      ),
    );
  }
}

/// Dentist photo + name
class DentistHeader extends StatelessWidget {
  const DentistHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(
            "https://randomuser.me/api/portraits/women/65.jpg",
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Dr. Anjali Mehta",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "BDS, MDS - 10+ Years Experience",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

/// Experience section
class DentistExperience extends StatelessWidget {
  const DentistExperience({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Experience",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Dr. Mehta specializes in cosmetic dentistry, root canal treatments, "
          "and pediatric dental care. She has successfully treated over 5000 patients.",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

/// Clinic photos gallery
/// Clinic photos gallery with small, fast-loading images
class ClinicPhotos extends StatelessWidget {
  const ClinicPhotos({super.key});

  // Use Unsplash with width parameter (?w=400) to reduce size
  final List<String> photoUrls = const [
    "https://images.unsplash.com/photo-1588776814546-4c7a3a3c9a3f?w=400",
    "https://images.unsplash.com/photo-1629904853711-bc3c4d9c3f1a?w=400",
    "https://images.unsplash.com/photo-1606813909027-7b6f3a3f3d9c?w=400",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Clinic Photos",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photoUrls.length,
            itemBuilder: (context, index) => _buildPhoto(photoUrls[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 160,
          fit: BoxFit.cover,
          // Add loading indicator to avoid blocking UI
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, size: 50),
        ),
      ),
    );
  }
}

/// Appointment booking section
class AppointmentSection extends StatelessWidget {
  const AppointmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Book Appointment",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        AppointmentForm(),
      ],
    );
  }
}

/// Appointment form with date & time picker
class AppointmentForm extends StatefulWidget {
  const AppointmentForm({super.key});

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(
            selectedDate == null
                ? "Select Date"
                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
          ),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (date != null) setState(() => selectedDate = date);
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.access_time),
          label: Text(
            selectedTime == null
                ? "Select Time"
                : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
          ),
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) setState(() => selectedTime = time);
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () {
            if (selectedDate != null && selectedTime != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Appointment booked on ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} "
                    "at ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                  ),
                ),
              );
            }
          },
          child: const Text(
            "Confirm Appointment",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
