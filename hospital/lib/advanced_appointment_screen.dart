import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models
class DoctorAppointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String profileImage;
  final double rating;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final String reason;
  final AppointmentStatus status;
  final double consultationFee;
  final PaymentStatus paymentStatus;
  final String patientName;
  final String patientPhone;
  final String clinicAddress;
  final String clinicPhone;

  DoctorAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.profileImage,
    required this.rating,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.reason,
    required this.status,
    required this.consultationFee,
    required this.paymentStatus,
    required this.patientName,
    required this.patientPhone,
    required this.clinicAddress,
    required this.clinicPhone,
  });
}

enum AppointmentStatus { scheduled, completed, cancelled, rescheduled }

enum PaymentStatus { pending, completed, failed, refunded }

// Advanced Appointment Screen
class AdvancedAppointmentScreen extends StatefulWidget {
  const AdvancedAppointmentScreen({super.key});

  @override
  State<AdvancedAppointmentScreen> createState() =>
      _AdvancedAppointmentScreenState();
}

class _AdvancedAppointmentScreenState extends State<AdvancedAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  // Sample appointment data
  final List<DoctorAppointment> allAppointments = [
    DoctorAppointment(
      id: 'APT001',
      doctorName: 'Dr. Rajesh Kumar',
      specialty: 'Cardiologist',
      profileImage:
          'https://i.pinimg.com/736x/bf/0c/76/bf0c7651ee5d65b983eed068bbbba1c8.jpg',
      rating: 4.8,
      appointmentDate: DateTime.now().add(Duration(days: 2)),
      appointmentTime: TimeOfDay(hour: 10, minute: 30),
      reason: 'Regular Checkup',
      status: AppointmentStatus.scheduled,
      consultationFee: 500,
      paymentStatus: PaymentStatus.pending,
      patientName: 'John Doe',
      patientPhone: '9876543210',
      clinicAddress: '123 Medical Plaza, Healthcare City',
      clinicPhone: '040-1234567',
    ),
    DoctorAppointment(
      id: 'APT002',
      doctorName: 'Dr. Priya Sharma',
      specialty: 'Dermatologist',
      profileImage:
          'https://i.pinimg.com/736x/bf/0c/76/bf0c7651ee5d65b983eed068bbbba1c8.jpg',
      rating: 4.6,
      appointmentDate: DateTime.now().add(Duration(days: 5)),
      appointmentTime: TimeOfDay(hour: 14, minute: 0),
      reason: 'Skin Treatment',
      status: AppointmentStatus.scheduled,
      consultationFee: 450,
      paymentStatus: PaymentStatus.completed,
      patientName: 'Jane Smith',
      patientPhone: '9876543211',
      clinicAddress: '456 Health Complex, Medical Street',
      clinicPhone: '040-1234568',
    ),
    DoctorAppointment(
      id: 'APT003',
      doctorName: 'Dr. Amit Patel',
      specialty: 'General Physician',
      profileImage:
          'https://i.pinimg.com/736x/bf/0c/76/bf0c7651ee5d65b983eed068bbbba1c8.jpg',
      rating: 4.7,
      appointmentDate: DateTime.now().subtract(Duration(days: 3)),
      appointmentTime: TimeOfDay(hour: 11, minute: 0),
      reason: 'Follow-up Visit',
      status: AppointmentStatus.completed,
      consultationFee: 400,
      paymentStatus: PaymentStatus.completed,
      patientName: 'Raj Kumar',
      patientPhone: '9876543212',
      clinicAddress: '789 Wellness Center, Health Avenue',
      clinicPhone: '040-1234569',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DoctorAppointment> _getFilteredAppointments(AppointmentStatus status) {
    return allAppointments.where((apt) {
      final matchesSearch =
          apt.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          apt.specialty.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = apt.status == status;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Appointments',
            style: TextStyle(
              color: Color(0xFF0066CC),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            'Manage your healthcare visits',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Color(0xFF0066CC)),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Color(0xFF0066CC)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search doctor or specialty...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF0066CC)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Color(0xFF0066CC)),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Color(0xFF0066CC),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFF0066CC),
        indicatorWeight: 3,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 14),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Completed'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAppointmentsList(AppointmentStatus.scheduled),
        _buildAppointmentsList(AppointmentStatus.completed),
        _buildAppointmentsList(AppointmentStatus.cancelled),
      ],
    );
  }

  Widget _buildAppointmentsList(AppointmentStatus status) {
    final appointments = _getFilteredAppointments(status);

    if (appointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No ${status.name} appointments',
        subtitle: 'Schedule your next appointment with a doctor',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) =>
          _buildAppointmentCard(appointments[index]),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(DoctorAppointment appointment) {
    return GestureDetector(
      onTap: () => _showAppointmentDetails(appointment),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with Doctor Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(appointment.profileImage),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF0066CC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              appointment.specialty,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0066CC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              SizedBox(width: 4),
                              Text(
                                '${appointment.rating}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(appointment.status),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Color(0xFFEEEEEE), height: 0),
                SizedBox(height: 16),
                // Appointment Details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormat(
                          'dd MMM yyyy',
                        ).format(appointment.appointmentDate),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.access_time_outlined,
                        label: 'Time',
                        value:
                            '${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.medical_services_outlined,
                        label: 'Reason',
                        value: appointment.reason,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Consultation Fee & Payment Status
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consultation Fee',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '₹${appointment.consultationFee}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                        ],
                      ),
                      _buildPaymentStatusBadge(appointment.paymentStatus),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Action Buttons
                if (appointment.status == AppointmentStatus.scheduled)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRescheduleDialog(appointment),
                          icon: Icon(Icons.edit_outlined),
                          label: Text('Reschedule'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF0066CC),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPaymentDialog(appointment),
                          icon: Icon(
                            Icons.payment_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Pay Now',
                            style: TextStyle(color: Colors.white),
                          ),
                          // labelStyle: TextStyle(color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0066CC),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (appointment.status == AppointmentStatus.completed)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            'View Report',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF27AE60),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.star_outline),
                          label: Text('Rate'),
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

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case AppointmentStatus.scheduled:
        bgColor = Color(0xFF0066CC).withOpacity(0.1);
        textColor = Color(0xFF0066CC);
        icon = Icons.schedule_outlined;
        label = 'Scheduled';
        break;
      case AppointmentStatus.completed:
        bgColor = Color(0xFF27AE60).withOpacity(0.1);
        textColor = Color(0xFF27AE60);
        icon = Icons.check_circle_outline;
        label = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        bgColor = Color(0xFFE74C3C).withOpacity(0.1);
        textColor = Color(0xFFE74C3C);
        icon = Icons.cancel_outlined;
        label = 'Cancelled';
        break;
      case AppointmentStatus.rescheduled:
        bgColor = Color(0xFFF39C12).withOpacity(0.1);
        textColor = Color(0xFFF39C12);
        icon = Icons.edit_calendar_outlined;
        label = 'Rescheduled';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBadge(PaymentStatus status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case PaymentStatus.pending:
        bgColor = Color(0xFFF39C12).withOpacity(0.1);
        textColor = Color(0xFFF39C12);
        icon = Icons.pending_actions_outlined;
        label = 'Pending';
        break;
      case PaymentStatus.completed:
        bgColor = Color(0xFF27AE60).withOpacity(0.1);
        textColor = Color(0xFF27AE60);
        icon = Icons.check_circle_outline;
        label = 'Paid';
        break;
      case PaymentStatus.failed:
        bgColor = Color(0xFFE74C3C).withOpacity(0.1);
        textColor = Color(0xFFE74C3C);
        icon = Icons.error_outline;
        label = 'Failed';
        break;
      case PaymentStatus.refunded:
        bgColor = Color(0xFF00BFA5).withOpacity(0.1);
        textColor = Color(0xFF00BFA5);
        icon = Icons.undo_outlined;
        label = 'Refunded';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {},
      icon: Icon(Icons.add, color: Colors.white),
      label: Text('Book Appointment', style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF0066CC),
    );
  }

  void _showAppointmentDetails(DoctorAppointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildAppointmentDetailsSheet(appointment),
    );
  }

  Widget _buildAppointmentDetailsSheet(DoctorAppointment appointment) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.all(24),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Title
            Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 24),
            // Doctor Information
            _buildDetailSection('Doctor Information', [
              _buildDetailRow('Name', appointment.doctorName),
              _buildDetailRow('Specialty', appointment.specialty),
              _buildDetailRow('Rating', '${appointment.rating} ⭐'),
            ]),
            SizedBox(height: 20),
            // Appointment Details
            _buildDetailSection('Appointment Details', [
              _buildDetailRow(
                'Date',
                DateFormat('dd MMM yyyy').format(appointment.appointmentDate),
              ),
              _buildDetailRow(
                'Time',
                '${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}',
              ),
              _buildDetailRow('Reason', appointment.reason),
              _buildDetailRow('Status', appointment.status.name.toUpperCase()),
            ]),
            SizedBox(height: 20),
            // Clinic Information
            _buildDetailSection('Clinic Information', [
              _buildDetailRow('Address', appointment.clinicAddress),
              _buildDetailRow('Phone', appointment.clinicPhone),
            ]),
            SizedBox(height: 20),
            // Payment Information
            _buildDetailSection('Payment Information', [
              _buildDetailRow(
                'Consultation Fee',
                '₹${appointment.consultationFee}',
              ),
              _buildDetailRow(
                'Payment Status',
                appointment.paymentStatus.name.toUpperCase(),
              ),
            ]),
            SizedBox(height: 24),
            // Action Buttons
            if (appointment.status == AppointmentStatus.scheduled &&
                appointment.paymentStatus == PaymentStatus.pending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPaymentDialog(appointment);
                  },
                  icon: Icon(Icons.payment_outlined),
                  label: Text('Proceed to Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0066CC),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            if (appointment.status == AppointmentStatus.scheduled)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.cancel_outlined),
                  label: Text('Cancel Appointment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFE74C3C),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0066CC).withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0066CC),
              ),
            ),
          ),
          ...List.generate(
            items.length,
            (index) => Column(
              children: [
                Padding(padding: EdgeInsets.all(16), child: items[index]),
                if (index < items.length - 1)
                  Divider(color: Color(0xFFEEEEEE), height: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(DoctorAppointment appointment) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(appointment: appointment),
    );
  }

  void _showRescheduleDialog(DoctorAppointment appointment) {
    showDialog(
      context: context,
      builder: (context) => RescheduleDialog(appointment: appointment),
    );
  }
}

// Payment Dialog
class PaymentDialog extends StatefulWidget {
  final DoctorAppointment appointment;

  const PaymentDialog({required this.appointment});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 24),
              // Appointment Summary
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            widget.appointment.profileImage,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.appointment.doctorName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.appointment.specialty,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(color: Color(0xFFEEEEEE), height: 0),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consultation Fee',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '₹${widget.appointment.consultationFee}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Convenience Fee',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '₹0',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(color: Color(0xFFEEEEEE), height: 0),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${widget.appointment.consultationFee}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF0066CC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Payment Methods
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 12),
              _buildPaymentMethodOption(
                'card',
                'Credit/Debit Card',
                Icons.credit_card,
              ),
              _buildPaymentMethodOption(
                'upi',
                'UPI',
                Icons.account_balance_wallet,
              ),
              _buildPaymentMethodOption(
                'netbanking',
                'Net Banking',
                Icons.account_balance,
              ),
              SizedBox(height: 24),
              // Payment Terms
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF27AE60),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your payment is secure and encrypted',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0066CC),
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Pay ₹${widget.appointment.consultationFee}',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String label, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == value
              ? Color(0xFF0066CC).withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? Color(0xFF0066CC)
                : Color(0xFFE0E0E0),
            width: _selectedPaymentMethod == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
              activeColor: Color(0xFF0066CC),
            ),
            Icon(icon, color: Color(0xFF0066CC)),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(Duration(seconds: 2));

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: Color(0xFF27AE60),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// Reschedule Dialog
class RescheduleDialog extends StatefulWidget {
  final DoctorAppointment appointment;

  const RescheduleDialog({required this.appointment});

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reschedule Appointment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectDate,
              icon: Icon(Icons.calendar_today_outlined, color: Colors.white),
              label: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : DateFormat('dd MMM yyyy').format(_selectedDate!),
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0066CC),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _selectTime,
              icon: Icon(Icons.access_time_outlined, color: Colors.white),
              label: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0066CC),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedDate != null && _selectedTime != null
                        ? _confirmReschedule
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0066CC),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.appointment.appointmentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: widget.appointment.appointmentTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _confirmReschedule() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment rescheduled to ${DateFormat('dd MMM yyyy').format(_selectedDate!)} at ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        ),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }
}
