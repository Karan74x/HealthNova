import 'package:flutter/material.dart';
import 'package:hospital/Login_screen.dart';
import 'package:hospital/services/api_config.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/services/session.dart';
import 'package:hospital/widgets/common.dart';

/// The patient's own details, which they can edit, and logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// The values the backend's user schema accepts, with what to show.
  static const Map<String, String> _genders = {
    '': 'Prefer not to say',
    'Male': 'Male',
    'Female': 'Female',
    'other': 'Other',
  };

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String _email = '';
  String _gender = '';
  DateTime? _dob;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final account = await HealthNovaApi.getMe();
      if (!mounted) return;
      final gender = account['gender']?.toString() ?? '';
      setState(() {
        nameController.text = account['name']?.toString() ?? '';
        phoneController.text = account['phone']?.toString() ?? '';
        _email = account['email']?.toString() ?? '';
        _gender = _genders.containsKey(gender) ? gender : '';
        // Read the calendar day as stored (UTC), so no timezone shifts it
        final dob = DateTime.tryParse(account['dob']?.toString() ?? '');
        _dob = dob == null ? null : DateTime(dob.year, dob.month, dob.day);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = errorText(error);
        _loading = false;
      });
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final dob = _dob;
      await HealthNovaApi.updateMe({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': _gender,
        'dob': dob == null ? '' : HealthNovaApi.dateOnly(dob),
      });
      if (!mounted) return;
      showMessage(context, 'Your details were saved.');
    } catch (error) {
      if (!mounted) return;
      showMessage(context, errorText(error), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need your email and password to sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await Session.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  String get _initials {
    final source = nameController.text.trim().isNotEmpty
        ? nameController.text.trim()
        : _email;
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
    return source[0].toUpperCase();
  }

  Widget _body() {
    if (_loading) return const LoadingView();
    final error = _error;
    if (error != null) return ErrorView(message: error, onRetry: _load);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          elevation: 7,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                InitialsAvatar(initials: _initials, radius: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameController.text.isNotEmpty
                            ? nameController.text
                            : 'Your profile',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(_email, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: _decoration('Full name', Icons.person),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: phoneController,
                decoration: _decoration('Phone number', Icons.phone),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) =>
                    RegExp(r'^[0-9]{10}$').hasMatch((value ?? '').trim())
                        ? null
                        : 'Enter a valid 10-digit phone number',
              ),
              const SizedBox(height: 4),
              InputDecorator(
                decoration: _decoration('Gender', Icons.wc),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _gender,
                    isDense: true,
                    isExpanded: true,
                    items: [
                      for (final entry in _genders.entries)
                        DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                    ],
                    onChanged: (value) => setState(() => _gender = value ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: _pickDob,
                child: InputDecorator(
                  decoration: _decoration('Date of birth', Icons.cake),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_dob == null ? 'Not set' : formatDate(_dob)),
                      ),
                      if (_dob != null)
                        GestureDetector(
                          onTap: () => setState(() => _dob = null),
                          child: const Icon(Icons.close, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red[700],
            side: BorderSide(color: Colors.red[300]!),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
        const SizedBox(height: 16),
        Text(
          'Connected to ${ApiConfig.baseUrl}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
      ),
      body: _body(),
    );
  }
}
