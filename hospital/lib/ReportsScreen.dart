import 'package:flutter/material.dart';
import 'package:hospital/PredictionScreen.dart';
import 'package:hospital/models/prediction.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/widgets/common.dart';

// Report Model
class MedicalReport {
  final String id;
  final String patientName;
  final int age;
  final String gender;
  final String diagnosis;
  final String
  reportType; // Lab Test, X-Ray, Blood Test, CT Scan, Prescription, etc.
  final DateTime reportDate;
  final String doctorName;
  final String clinic;
  final String description;
  final List<String> findings;
  final List<String> recommendations;
  final String severity; // Normal, Mild, Moderate, Severe
  final String status; // Pending, Completed, Reviewed
  final String fileUrl;
  final String testResults; // JSON or detailed results
  final double cost;
  final bool isPrescription;
  final List<String> medicines; // If prescription

  MedicalReport({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.diagnosis,
    required this.reportType,
    required this.reportDate,
    required this.doctorName,
    required this.clinic,
    required this.description,
    required this.findings,
    required this.recommendations,
    required this.severity,
    required this.status,
    required this.fileUrl,
    required this.testResults,
    required this.cost,
    required this.isPrescription,
    required this.medicines,
  });
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedFilter = "All";
  String selectedSortBy = "Recent";
  TextEditingController searchController = TextEditingController();

  // Sample comprehensive reports data
  final List<MedicalReport> allReports = [
    MedicalReport(
      id: "R001",
      patientName: "John Doe",
      age: 32,
      gender: "Male",
      diagnosis: "Flu (Influenza Type A)",
      reportType: "Lab Test",
      reportDate: DateTime(2024, 8, 20),
      doctorName: "Dr. Sarah Smith",
      clinic: "City Medical Center",
      description:
          "Complete blood count and viral panel conducted. Results show elevated white blood cell count indicating viral infection.",
      findings: [
        "WBC: 12.5 K/uL (High)",
        "RBC: 4.8 M/uL (Normal)",
        "Hemoglobin: 14.2 g/dL (Normal)",
        "Influenza A: Positive",
      ],
      recommendations: [
        "Rest for 7-10 days",
        "Antiviral medication (Oseltamivir)",
        "Increase fluid intake",
        "Follow-up after 5 days",
      ],
      severity: "Mild",
      status: "Completed",
      fileUrl: "reports/R001.pdf",
      testResults:
          "CBC Results: Normal with elevated WBC. Viral panel positive for Influenza A.",
      cost: 1500,
      isPrescription: false,
      medicines: [],
    ),
    MedicalReport(
      id: "R002",
      patientName: "Sarah Khan",
      age: 45,
      gender: "Female",
      diagnosis: "Type 2 Diabetes",
      reportType: "Blood Test",
      reportDate: DateTime(2024, 8, 21),
      doctorName: "Dr. Michael Brown",
      clinic: "Endocrine Specialist Clinic",
      description:
          "Fasting blood glucose and HbA1c tests to monitor diabetes control. Results indicate pre-diabetic state.",
      findings: [
        "Fasting Glucose: 126 mg/dL (High)",
        "HbA1c: 6.8% (High)",
        "Triglycerides: 180 mg/dL (High)",
        "HDL Cholesterol: 35 mg/dL (Low)",
      ],
      recommendations: [
        "Dietary modifications (low sugar, high fiber)",
        "Regular exercise (30 mins daily)",
        "Metformin 500mg twice daily",
        "Follow-up in 3 months",
        "Recheck HbA1c quarterly",
      ],
      severity: "Moderate",
      status: "Reviewed",
      fileUrl: "reports/R002.pdf",
      testResults:
          "Blood work shows elevated glucose levels requiring intervention.",
      cost: 2500,
      isPrescription: false,
      medicines: [],
    ),
    MedicalReport(
      id: "R003",
      patientName: "Ravi Patel",
      age: 29,
      gender: "Male",
      diagnosis: "Forearm Fracture (Right)",
      reportType: "X-Ray",
      reportDate: DateTime(2024, 8, 22),
      doctorName: "Dr. Priya Sharma",
      clinic: "Orthopedic Center",
      description:
          "X-ray imaging shows complete fracture of radius and ulna bones. Requires surgical intervention.",
      findings: [
        "Complete fracture of radius",
        "Complete fracture of ulna",
        "Displacement: 2-3mm",
        "No neurovascular compromise",
        "Soft tissue swelling present",
      ],
      recommendations: [
        "Immediate surgical fixation (ORIF)",
        "Immobilization post-surgery",
        "Physical therapy starting week 3",
        "Avoid weight-bearing for 6-8 weeks",
        "Follow-up X-rays at 2 weeks and 6 weeks",
      ],
      severity: "Severe",
      status: "Completed",
      fileUrl: "reports/R003.pdf",
      testResults:
          "X-ray imaging reveals significant bone injury requiring surgery.",
      cost: 5000,
      isPrescription: false,
      medicines: [],
    ),
    MedicalReport(
      id: "R004",
      patientName: "Kevin Smith",
      age: 35,
      gender: "Male",
      diagnosis: "Prescription: Post-Surgery Recovery",
      reportType: "Prescription",
      reportDate: DateTime(2024, 8, 23),
      doctorName: "Dr. Alex Doe",
      clinic: "General Practice",
      description:
          "Post-operative prescription for pain management and infection prevention following appendectomy.",
      findings: [],
      recommendations: [
        "Take antibiotics as prescribed",
        "Pain management medication",
        "Wound care instructions",
        "Avoid strenuous activities",
      ],
      severity: "Mild",
      status: "Pending",
      fileUrl: "reports/R004.pdf",
      testResults: "",
      cost: 800,
      isPrescription: true,
      medicines: [
        "Amoxicillin 500mg - 3 times daily for 7 days",
        "Paracetamol 500mg - Every 6 hours as needed",
        "Ibuprofen 400mg - Every 8 hours for inflammation",
      ],
    ),
    MedicalReport(
      id: "R005",
      patientName: "James Bond",
      age: 49,
      gender: "Male",
      diagnosis: "Ankle Fracture (Left)",
      reportType: "CT Scan",
      reportDate: DateTime(2024, 8, 24),
      doctorName: "Dr. Raj Patel",
      clinic: "Diagnostic Imaging Center",
      description:
          "CT scan showing complex ankle fracture with multiple fragments. Requires surgical evaluation.",
      findings: [
        "Complex ankle fracture",
        "Talus fracture fragment",
        "Fibula fracture at syndesmosis",
        "Moderate soft tissue injury",
        "No neurovascular compromise",
      ],
      recommendations: [
        "Orthopedic surgery consultation",
        "Possible surgical fixation",
        "Cast immobilization initially",
        "Elevate and ice for swelling",
        "Follow-up with orthopedic surgeon",
      ],
      severity: "Severe",
      status: "Pending",
      fileUrl: "reports/R005.pdf",
      testResults:
          "CT imaging shows complex fracture pattern requiring specialist evaluation.",
      cost: 8000,
      isPrescription: false,
      medicines: [],
    ),
    MedicalReport(
      id: "R006",
      patientName: "Ama Watson",
      age: 39,
      gender: "Female",
      diagnosis: "High Fever (39.5°C)",
      reportType: "Blood Test",
      reportDate: DateTime(2024, 8, 26),
      doctorName: "Dr. Emily Johnson",
      clinic: "Urgent Care Center",
      description:
          "Fever workup with blood culture and comprehensive metabolic panel. Awaiting culture results.",
      findings: [
        "Temperature: 39.5°C",
        "WBC: 14.2 K/uL (Elevated)",
        "CRP: 45 mg/L (Elevated)",
        "Liver enzymes: Slightly elevated",
        "Blood culture: Pending",
      ],
      recommendations: [
        "Acetaminophen 500mg every 6 hours",
        "Broad-spectrum antibiotics pending culture",
        "Increased fluid intake",
        "Follow-up blood culture results",
        "Repeat blood work in 48 hours",
      ],
      severity: "Moderate",
      status: "Reviewed",
      fileUrl: "reports/R006.pdf",
      testResults:
          "Laboratory findings consistent with infectious process. Awaiting culture.",
      cost: 1800,
      isPrescription: false,
      medicines: [],
    ),
    MedicalReport(
      id: "R007",
      patientName: "John Doe",
      age: 32,
      gender: "Male",
      diagnosis: "Prescription: Allergy Management",
      reportType: "Prescription",
      reportDate: DateTime(2024, 8, 19),
      doctorName: "Dr. Sarah Smith",
      clinic: "Allergy & Immunology",
      description: "Prescription for seasonal allergy management.",
      findings: [],
      recommendations: [
        "Take allergy medication before seasonal exposure",
        "Avoid allergen triggers",
        "Use nasal saline spray",
        "Maintain clean environment",
      ],
      severity: "Mild",
      status: "Completed",
      fileUrl: "reports/R007.pdf",
      testResults: "",
      cost: 500,
      isPrescription: true,
      medicines: [
        "Cetirizine 10mg - Once daily",
        "Fluticasone nasal spray - 2 sprays each nostril daily",
      ],
    ),
  ];

  List<MedicalReport> getFilteredReports() {
    List<MedicalReport> filtered = allReports;

    // Filter by type
    if (selectedFilter != "All") {
      filtered = filtered
          .where((report) => report.reportType == selectedFilter)
          .toList();
    }

    // Search filter
    String query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((report) {
        return report.patientName.toLowerCase().contains(query) ||
            report.diagnosis.toLowerCase().contains(query) ||
            report.reportType.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    if (selectedSortBy == "Recent") {
      filtered.sort((a, b) => b.reportDate.compareTo(a.reportDate));
    } else if (selectedSortBy == "Oldest") {
      filtered.sort((a, b) => a.reportDate.compareTo(b.reportDate));
    } else if (selectedSortBy == "Severity") {
      Map<String, int> severityMap = {
        "Severe": 0,
        "Moderate": 1,
        "Mild": 2,
        "Normal": 3,
      };
      filtered.sort(
        (a, b) => severityMap[a.severity]!.compareTo(severityMap[b.severity]!),
      );
    }

    return filtered;
  }

  List<String> get reportTypes {
    return ["All", ...allReports.map((r) => r.reportType).toSet().toList()];
  }

  @override
  Widget build(BuildContext context) {
    List<MedicalReport> filteredReports = getFilteredReports();

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Medical Reports'),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.blue[400],
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              controller: searchController,
              onChanged: (value) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by patient name, diagnosis...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Report Type Filter
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterDropdown(
                    "Type",
                    reportTypes,
                    selectedFilter,
                    (value) {
                      setState(() => selectedFilter = value);
                    },
                  ),
                ),

                // Sort By Filter
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterDropdown(
                    "Sort",
                    ["Recent", "Oldest", "Severity"],
                    selectedSortBy,
                    (value) {
                      setState(() => selectedSortBy = value);
                    },
                  ),
                ),

                // Results Count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Text(
                    "${filteredReports.length} Reports",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: filteredReports.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(filteredReports[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
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
            const SizedBox(width: 4),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.file_present, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "No reports found",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters or search",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(MedicalReport report) {
    Color severityColor = _getSeverityColor(report.severity);
    Color statusColor = _getStatusColor(report.status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(report: report),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Header with status and severity
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  border: Border(
                    bottom: BorderSide(color: severityColor.withOpacity(0.3)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getReportIcon(report.reportType),
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              report.reportType,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(report.reportDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: severityColor),
                          ),
                          child: Text(
                            report.severity,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            report.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Report Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Info
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            report.patientName[0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.patientName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${report.age} years | ${report.gender}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Diagnosis
                    _buildInfoRow(
                      Icons.medical_information,
                      "Diagnosis",
                      report.diagnosis,
                    ),

                    const SizedBox(height: 8),

                    // Doctor Info
                    _buildInfoRow(Icons.person, "Doctor", report.doctorName),

                    const SizedBox(height: 8),

                    // Clinic Info
                    _buildInfoRow(Icons.location_on, "Clinic", report.clinic),

                    const SizedBox(height: 12),

                    // Cost
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                color: Colors.orange[600],
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Cost",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "₹${report.cost}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReportDetailScreen(report: report),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[400],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.description, size: 18),
                            label: const Text("View Details"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Downloading ${report.patientName}'s report...",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              alignment: Alignment.center,
                              foregroundColor: Colors.blue[600],
                              side: BorderSide(color: Colors.blue[600]!),
                            ),
                            icon: const Icon(Icons.download, size: 15),
                            label: const Text(
                              "Download",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share),
                            color: Colors.blue[600],
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Sharing ${report.patientName}'s report...",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[600], size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case "Severe":
        return Colors.red;
      case "Moderate":
        return Colors.orange;
      case "Mild":
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Reviewed":
        return Colors.blue;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportIcon(String reportType) {
    switch (reportType) {
      case "Lab Test":
        return Icons.tab_rounded;
      case "X-Ray":
        return Icons.image;
      case "Blood Test":
        return Icons.bloodtype;
      case "CT Scan":
        return Icons.scanner;
      case "Prescription":
        return Icons.medication;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

// Report Detail Screen
class ReportDetailScreen extends StatelessWidget {
  final MedicalReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Report Details",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Section
            Container(
              color: Colors.blue[400],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.reportType,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(report.reportDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBadge(
                            report.severity,
                            _getSeverityColor(report.severity),
                          ),
                          const SizedBox(height: 8),
                          _buildBadge(
                            report.status,
                            _getStatusColor(report.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Patient Information
            _buildSection("Patient Information", [
              _buildDetailItem("Name", report.patientName),
              _buildDetailItem("Age", "${report.age} years"),
              _buildDetailItem("Gender", report.gender),
              _buildDetailItem("ID", report.id),
            ]),

            // Medical Information
            _buildSection("Medical Information", [
              _buildDetailItem("Diagnosis", report.diagnosis),
              _buildDetailItem("Doctor", report.doctorName),
              _buildDetailItem("Clinic", report.clinic),
            ]),

            // Description
            if (report.description.isNotEmpty)
              _buildSection("Report Description", [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    report.description,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
              ]),

            // Findings
            if (report.findings.isNotEmpty)
              _buildSection(
                "Findings",
                report.findings
                    .map(
                      (finding) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                finding,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),

            // Recommendations
            if (report.recommendations.isNotEmpty)
              _buildSection(
                "Recommendations",
                report.recommendations
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  "${entry.key + 1}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),

            // Medicines (if prescription)
            if (report.isPrescription && report.medicines.isNotEmpty)
              _buildSection(
                "Prescribed Medicines",
                report.medicines
                    .map(
                      (medicine) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.medication,
                                color: Colors.green[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  medicine,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

            // Cost & Payment
            _buildSection("Cost & Payment", [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.currency_rupee, color: Colors.orange[600]),
                        Text(
                          "Total Cost",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "₹${report.cost}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Downloading ${report.patientName}'s report...",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        "Download Report (PDF)",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Sharing ${report.patientName}'s report...",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[600],
                        side: BorderSide(color: Colors.blue[600]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.share),
                      label: const Text("Share Report"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Report added to favorites"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber[700],
                        side: BorderSide(color: Colors.amber[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.favorite_border),
                      label: const Text("Add to Favorites"),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case "Severe":
        return Colors.red;
      case "Moderate":
        return Colors.orange;
      case "Mild":
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Reviewed":
        return Colors.blue;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
