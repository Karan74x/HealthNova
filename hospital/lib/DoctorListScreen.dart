import 'package:flutter/material.dart';
import 'package:hospital/Home_screen.dart';
import 'package:hospital/bottombar.dart';

// Doctor Model
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int experience;
  final String nextAvailable;
  final String image;
  final String qualifications;
  final int consultationFee;
  final List<String> languages;
  final String clinic;
  final String phone;
  final bool isAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experience,
    required this.nextAvailable,
    required this.image,
    required this.qualifications,
    required this.consultationFee,
    required this.languages,
    required this.clinic,
    required this.phone,
    required this.isAvailable,
  });
}

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final searchController = TextEditingController();
  String selectedSpecialty = "All";
  String selectedRating = "All";
  bool availableOnly = false;
  String sortBy = "Rating";

  // Sample doctor data with more details
  final List<Doctor> allDoctors = [
    Doctor(
      id: "1",
      name: "Dr. Alex Doe",
      specialty: "Cardiologist",
      rating: 4.5,
      experience: 12,
      nextAvailable: "12:30 PM",
      image: "https://randomuser.me/api/portraits/men/1.jpg",
      qualifications: "MD, DM Cardiology",
      consultationFee: 500,
      languages: ["English", "Hindi", "Gujarati"],
      clinic: "Heart Care Clinic",
      phone: "+91-98765-43210",
      isAvailable: true,
    ),
    Doctor(
      id: "2",
      name: "Dr. John Doe",
      specialty: "Cardiologist",
      rating: 4.5,
      experience: 12,
      nextAvailable: "12:30 PM",
      image: "https://randomuser.me/api/portraits/men/2.jpg",
      qualifications: "MD, DM Cardiology",
      consultationFee: 450,
      languages: ["English", "Hindi"],
      clinic: "Heart Care Clinic",
      phone: "+91-98765-43211",
      isAvailable: true,
    ),
    Doctor(
      id: "3",
      name: "Dr. Sarah Smith",
      specialty: "Dermatologist",
      rating: 4.8,
      experience: 8,
      nextAvailable: "2:00 PM",
      image: "https://randomuser.me/api/portraits/women/1.jpg",
      qualifications: "MBBS, MD Dermatology",
      consultationFee: 400,
      languages: ["English", "Hindi", "Gujarati"],
      clinic: "Skin Care Center",
      phone: "+91-98765-43212",
      isAvailable: true,
    ),
    Doctor(
      id: "4",
      name: "Dr. Michael Brown",
      specialty: "Neurologist",
      rating: 4.6,
      experience: 15,
      nextAvailable: "3:30 PM",
      image: "https://randomuser.me/api/portraits/men/3.jpg",
      qualifications: "MD, DM Neurology",
      consultationFee: 550,
      languages: ["English", "Hindi"],
      clinic: "Neuro Specialist Clinic",
      phone: "+91-98765-43213",
      isAvailable: true,
    ),
    Doctor(
      id: "5",
      name: "Dr. Emily Johnson",
      specialty: "Pediatrician",
      rating: 4.9,
      experience: 10,
      nextAvailable: "1:00 PM",
      image: "https://randomuser.me/api/portraits/women/2.jpg",
      qualifications: "MBBS, MD Pediatrics",
      consultationFee: 350,
      languages: ["English", "Hindi", "Gujarati"],
      clinic: "Child Care Clinic",
      phone: "+91-98765-43214",
      isAvailable: true,
    ),
    Doctor(
      id: "6",
      name: "Dr. Raj Patel",
      specialty: "Dentist",
      rating: 4.7,
      experience: 9,
      nextAvailable: "4:00 PM",
      image: "https://randomuser.me/api/portraits/men/4.jpg",
      qualifications: "BDS, MDS",
      consultationFee: 300,
      languages: ["English", "Hindi", "Gujarati"],
      clinic: "Dental Excellence",
      phone: "+91-98765-43215",
      isAvailable: false,
    ),
    Doctor(
      id: "7",
      name: "Dr. Priya Sharma",
      specialty: "Orthopedic",
      rating: 4.4,
      experience: 11,
      nextAvailable: "10:00 AM",
      image: "https://randomuser.me/api/portraits/women/3.jpg",
      qualifications: "MBBS, MS Orthopedic",
      consultationFee: 480,
      languages: ["English", "Hindi"],
      clinic: "Bone & Joint Care",
      phone: "+91-98765-43216",
      isAvailable: true,
    ),
  ];

  List<Doctor> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    filteredDoctors = allDoctors;
    searchController.addListener(_filterDoctors);
  }

  void _filterDoctors() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredDoctors = allDoctors.where((doctor) {
        bool matchesSearch =
            query.isEmpty ||
            doctor.name.toLowerCase().contains(query) ||
            doctor.specialty.toLowerCase().contains(query);

        bool matchesSpecialty =
            selectedSpecialty == "All" || doctor.specialty == selectedSpecialty;

        bool matchesRating =
            selectedRating == "All" ||
            (selectedRating == "4+" && doctor.rating >= 4.0) ||
            (selectedRating == "4.5+" && doctor.rating >= 4.5);

        bool matchesAvailability = !availableOnly || doctor.isAvailable == true;

        return matchesSearch &&
            matchesSpecialty &&
            matchesRating &&
            matchesAvailability;
      }).toList();

      // Sort doctors
      if (sortBy == "Rating") {
        filteredDoctors.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (sortBy == "Experience") {
        filteredDoctors.sort((a, b) => b.experience.compareTo(a.experience));
      } else if (sortBy == "Fee (Low to High)") {
        filteredDoctors.sort(
          (a, b) => a.consultationFee.compareTo(b.consultationFee),
        );
      }
    });
  }

  List<String> get specialties {
    return ["All", ...allDoctors.map((d) => d.specialty).toSet().toList()];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => bottom_screen()),
            );
          },
          icon: const Icon(
            Icons.chevron_left_sharp,
            size: 30,
            color: Colors.white,
          ),
        ),
        title: const Text("Find Doctors"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                controller: searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Search by name or specialty",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter Section
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // Specialty Filter
                  _buildFilterChip(
                    "Specialty",
                    specialties,
                    selectedSpecialty,
                    (value) {
                      setState(() => selectedSpecialty = value);
                      _filterDoctors();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Rating Filter
                  _buildFilterChip(
                    "Rating",
                    ["All", "4+", "4.5+"],
                    selectedRating,
                    (value) {
                      setState(() => selectedRating = value);
                      _filterDoctors();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Sort Filter
                  _buildFilterChip(
                    "Sort",
                    ["Rating", "Experience", "Fee (Low to High)"],
                    sortBy,
                    (value) {
                      setState(() => sortBy = value);
                      _filterDoctors();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Available Only Toggle
                  GestureDetector(
                    onTap: () {
                      setState(() => availableOnly = !availableOnly);
                      _filterDoctors();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: availableOnly ? Colors.green[300] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: availableOnly
                              ? Colors.green
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: availableOnly ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Available",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Found ${filteredDoctors.length} doctors",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Display filtered doctors
            filteredDoctors.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No doctors found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try adjusting your filters",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      Doctor doctor = filteredDoctors[index];
                      return _buildDoctorCard(doctor);
                    },
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    List<String> options,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return options.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Row(
              children: [
                if (choice == selectedValue)
                  const Icon(Icons.check, color: Colors.blue, size: 20),
                if (choice == selectedValue) const SizedBox(width: 8),
                Text(choice),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 5),
            Text(
              selectedValue,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctor: doctor),
            ),
          );
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Doctor Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage(doctor.image),
                        ),
                        if (!doctor.isAvailable)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    // Doctor Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doctor.specialty,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber[600],
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${doctor.rating}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.cases,
                                color: Colors.blue[600],
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${doctor.experience} yrs",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Next Available",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor.nextAvailable,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Fee",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₹${doctor.consultationFee}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Book",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Doctor Detail Screen with full information
class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Doctor Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with doctor image
            Container(
              color: Colors.blue[100],
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(doctor.image),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.specialty,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoBadge(
                        Icons.star,
                        "${doctor.rating}",
                        Colors.amber,
                      ),
                      const SizedBox(width: 16),
                      _buildInfoBadge(
                        Icons.cases,
                        "${doctor.experience} yrs",
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildInfoBadge(
                        Icons.currency_rupee,
                        "₹${doctor.consultationFee}",
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Qualifications
                  _buildDetailSection(
                    "Qualifications",
                    doctor.qualifications,
                    Icons.school,
                  ),
                  const SizedBox(height: 20),

                  // Clinic Information
                  _buildDetailSection(
                    "Clinic",
                    doctor.clinic,
                    Icons.location_on,
                  ),
                  const SizedBox(height: 20),

                  // Languages
                  _buildDetailSection(
                    "Languages",
                    doctor.languages.join(", "),
                    Icons.language,
                  ),
                  const SizedBox(height: 20),

                  // Contact
                  _buildDetailSection("Phone", doctor.phone, Icons.phone),
                  const SizedBox(height: 20),

                  // Status
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: doctor.isAvailable
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: doctor.isAvailable
                            ? Colors.green[300]!
                            : Colors.red[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          doctor.isAvailable
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: doctor.isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          doctor.isAvailable
                              ? "Available for consultation"
                              : "Currently unavailable",
                          style: TextStyle(
                            fontSize: 14,
                            color: doctor.isAvailable
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Book Appointment Button
                  if (doctor.isAvailable)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookAppointmentScreen(doctor: doctor),
                            ),
                          );
                        },
                        child: const Text(
                          "Book Appointment",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}

// Book Appointment Screen
class BookAppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedReason;
  TextEditingController notesController = TextEditingController();

  final List<String> appointmentReasons = [
    "First Consultation",
    "Follow-up",
    "Checkup",
    "Emergency",
    "Other",
  ];

  List<DateTime> getAvailableDates() {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    for (int i = 1; i <= 30; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Book Appointment",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.doctor.image),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.doctor.specialty,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reason for visit
            Text(
              "Reason for Visit",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: appointmentReasons.map((reason) {
                return ChoiceChip(
                  label: Text(reason),
                  selected: selectedReason == reason,
                  onSelected: (selected) {
                    setState(() => selectedReason = selected ? reason : null);
                  },
                  selectedColor: Colors.blue[400],
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: selectedReason == reason
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Date Selection
            Text(
              "Select Date",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue[300]!),
              ),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDate == null
                    ? "Select a date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),

            const SizedBox(height: 20),

            // Time Selection
            Text(
              "Select Time",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue[300]!),
              ),
              icon: const Icon(Icons.access_time),
              label: Text(
                selectedTime == null
                    ? "Select a time"
                    : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
              ),
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => selectedTime = time);
                }
              },
            ),

            const SizedBox(height: 20),

            // Additional Notes
            Text(
              "Additional Notes (Optional)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Any specific concerns or medical history...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 30),

            // Confirmation & Fee Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Consultation Fee",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${widget.doctor.consultationFee}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.info, color: Colors.orange[600]),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[500],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (selectedDate != null &&
                      selectedTime != null &&
                      selectedReason != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Appointment booked with ${widget.doctor.name} on ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all required fields"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Confirm Appointment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
