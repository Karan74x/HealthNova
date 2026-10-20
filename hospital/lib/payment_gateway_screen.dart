import 'package:flutter/material.dart';
import 'package:hospital/payment_gateway_screen.dart';
// import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Payment Gateway Screen
class PaymentGatewayScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final double amount;

  const PaymentGatewayScreen({
    required this.appointmentId,
    required this.doctorName,
    required this.amount,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  int _currentStep = 0;
  String _selectedPaymentMethod = 'card';
  bool _agreeTerms = false;

  // Form Controllers
  final cardNumberController = TextEditingController();
  final cardholderController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final upiController = TextEditingController();
  final bankController = TextEditingController();

  @override
  void dispose() {
    cardNumberController.dispose();
    cardholderController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    upiController.dispose();
    bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0066CC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Gateway',
          style: TextStyle(
            color: Color(0xFF0066CC),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOrderSummary(),
            SizedBox(height: 24),
            _buildPaymentMethodSelector(),
            SizedBox(height: 24),
            _buildPaymentMethodForm(),
            SizedBox(height: 24),
            _buildTermsCheckbox(),
            SizedBox(height: 24),
            _buildPaymentButton(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF0066CC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Appointment ID: ${widget.appointmentId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0066CC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Doctor', widget.doctorName),
                SizedBox(height: 12),
                _buildSummaryRow('Consultation Fee', '₹${widget.amount}'),
                SizedBox(height: 12),
                _buildSummaryRow('Convenience Fee', '₹0'),
                Divider(color: Color(0xFFEEEEEE), height: 16),
                _buildSummaryRow(
                  'Total Amount',
                  '₹${widget.amount}',
                  isBold: true,
                  isAmount: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isAmount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isAmount ? Color(0xFF0066CC) : Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 16),
          _buildPaymentMethodOption(
            'card',
            'Credit/Debit Card',
            Icons.credit_card_outlined,
          ),
          _buildPaymentMethodOption(
            'upi',
            'UPI',
            Icons.account_balance_wallet_outlined,
          ),
          _buildPaymentMethodOption(
            'netbanking',
            'Net Banking',
            Icons.account_balance_outlined,
          ),
          _buildPaymentMethodOption(
            'wallet',
            'Digital Wallet',
            Icons.wallet_giftcard_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFF0066CC).withOpacity(0.08)
              : Color(0xFFF5F7FA),
          border: Border.all(
            color: isSelected ? Color(0xFF0066CC) : Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: Color(0xFF0066CC),
            ),
            SizedBox(width: 12),
            Icon(icon, color: Color(0xFF0066CC), size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodForm() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 16),
          if (_selectedPaymentMethod == 'card') _buildCardForm(),
          if (_selectedPaymentMethod == 'upi') _buildUPIForm(),
          if (_selectedPaymentMethod == 'netbanking') _buildNetBankingForm(),
          if (_selectedPaymentMethod == 'wallet') _buildWalletForm(),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextField(
          controller: cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card, color: Color(0xFF0066CC)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
        SizedBox(height: 12),
        TextField(
          controller: cardholderController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'John Doe',
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF0066CC)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry (MM/YY)',
                  hintText: '12/25',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Color(0xFF0066CC),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUPIForm() {
    return Column(
      children: [
        TextField(
          controller: upiController,
          decoration: InputDecoration(
            labelText: 'UPI ID',
            hintText: 'yourname@upi',
            prefixIcon: Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF0066CC),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF00BFA5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF00BFA5), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will receive a push notification on your UPI app to authorize the payment',
                  style: TextStyle(fontSize: 12, color: Color(0xFF00BFA5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetBankingForm() {
    return Column(
      children: [
        TextField(
          controller: bankController,
          decoration: InputDecoration(
            labelText: 'Select Bank',
            hintText: 'Choose your bank',
            prefixIcon: Icon(
              Icons.account_balance_outlined,
              color: Color(0xFF0066CC),
            ),
            suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF0066CC)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
          ),
          readOnly: true,
          onTap: _showBankSelector,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF3498DB), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will be redirected to your bank\'s website for authentication',
                  style: TextStyle(fontSize: 12, color: Color(0xFF3498DB)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletForm() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹2,500',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066CC),
                    ),
                  ),
                ],
              ),
              Icon(Icons.wallet, size: 40, color: Color(0xFF0066CC)),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF27AE60).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFF27AE60),
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your wallet has sufficient balance for this payment',
                  style: TextStyle(fontSize: 12, color: Color(0xFF27AE60)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBankSelector() {
    final banks = ['HDFC Bank', 'ICIC Bank', 'SBI', 'Axis Bank', 'Kotak Bank'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Bank'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: banks.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(banks[index]),
              onTap: () {
                setState(() => bankController.text = banks[index]);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Checkbox(
            value: _agreeTerms,
            onChanged: (value) => setState(() => _agreeTerms = value ?? false),
            activeColor: Color(0xFF0066CC),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0066CC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0066CC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: _agreeTerms ? _processPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0066CC),
          disabledBackgroundColor: Colors.grey.shade300,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline),
            SizedBox(width: 8),
            Text(
              'Pay Securely - ₹${widget.amount}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    if (!_validatePaymentDetails()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF0066CC)),
            ),
            SizedBox(height: 16),
            Text('Processing Payment...'),
            SizedBox(height: 8),
            Text(
              'Please do not close this screen',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context); // Close processing dialog
      _showPaymentSuccessDialog();
    });
  }

  bool _validatePaymentDetails() {
    if (_selectedPaymentMethod == 'card') {
      return cardNumberController.text.length == 16 &&
          cardholderController.text.isNotEmpty &&
          expiryController.text.isNotEmpty &&
          cvvController.text.length >= 3;
    } else if (_selectedPaymentMethod == 'upi') {
      return upiController.text.contains('@');
    } else if (_selectedPaymentMethod == 'netbanking') {
      return bankController.text.isNotEmpty;
    } else if (_selectedPaymentMethod == 'wallet') {
      return true;
    }
    return false;
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF27AE60).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF27AE60),
                size: 64,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 12),
            Text(
              '₹${widget.amount} has been deducted',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF0066CC),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your appointment is confirmed',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction ID:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'TXN${DateTime.now().millisecondsSinceEpoch}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date & Time:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close payment screen
                // Navigate to appointment confirmation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0066CC),
              ),
              child: Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
