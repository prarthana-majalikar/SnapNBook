import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String amount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    final url = Uri.parse(
      'https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/Payments/${widget.bookingId}',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': double.parse(widget.amount).toInt()}),
      );

      setState(() => _isProcessing = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Payment successful')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ Payment failed')));
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('⚠️ Payment error')));
    }
  }

  String formatAmount(String amount) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return formatter.format(double.tryParse(amount) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Pay ${formatAmount(widget.amount)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name on Card'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter name on card'
                            : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Enter card number';
                  if (!RegExp(r'^\d{16}$').hasMatch(value))
                    return 'Card number must be 16 digits';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(labelText: 'MM/YY'),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter expiry';
                        final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                        if (!regex.hasMatch(value))
                          return 'Invalid format (MM/YY)';

                        final parts = value.split('/');
                        final int enteredMonth = int.parse(parts[0]);
                        final int enteredYear = int.parse(
                          '20${parts[1]}',
                        ); // handles 'YY' → '20YY'

                        final now = DateTime.now();
                        final currentMonth = now.month;
                        final currentYear = now.year;

                        if (enteredYear < currentYear ||
                            (enteredYear == currentYear &&
                                enteredMonth < currentMonth)) {
                          return 'Card expired';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter CVV';
                        if (!RegExp(r'^\d{3,4}$').hasMatch(value))
                          return 'Invalid CVV';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    onPressed: _submitPayment,
                    icon: const Icon(Icons.payment),
                    label: const Text("Pay Now"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
