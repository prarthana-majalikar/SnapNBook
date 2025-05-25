import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _useSavedCard = false;

  Future<void> _submitPayment() async {
    if (!_useSavedCard && !_formKey.currentState!.validate()) {
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
        await _showPaymentDialog(
          title: 'Payment Successful',
          message: 'Your payment was processed successfully',
          isSuccess: true,
        );
      } else {
        await _showPaymentDialog(
          title: 'Payment Failed',
          message: 'Something went wrong. Please try again',
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      await _showPaymentDialog(
        title: 'Error',
        message: 'An error occurred while processing the payment',
        isSuccess: false,
      );
    }
  }

  Future<void> _showPaymentDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  ctx.pop();
                  if (isSuccess) ctx.go("/bookings");
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String formatAmount(String amount) {
    print(amount);
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

              // Saved card tile
              TextFormField(
                controller: _nameController,
                enabled: !_useSavedCard,
                decoration: const InputDecoration(labelText: 'Name on Card'),
                validator: (value) {
                  if (_useSavedCard) return null;
                  return (value == null || value.isEmpty)
                      ? 'Enter name on card'
                      : null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cardNumberController,
                enabled: !_useSavedCard,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_useSavedCard) return null;
                  if (value == null || value.isEmpty) {
                    return 'Enter card number';
                  }
                  if (!RegExp(r'^\d{16}$').hasMatch(value)) {
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      enabled: !_useSavedCard,
                      decoration: const InputDecoration(labelText: 'MM/YY'),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (_useSavedCard) return null;
                        if (value == null || value.isEmpty) {
                          return 'Enter expiry';
                        }
                        final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                        if (!regex.hasMatch(value)) {
                          return 'Invalid format (MM/YY)';
                        }

                        final parts = value.split('/');
                        final int enteredMonth = int.parse(parts[0]);
                        final int enteredYear = int.parse('20${parts[1]}');

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
                      enabled: !_useSavedCard,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (_useSavedCard) return null;
                        if (value == null || value.isEmpty) {
                          return 'Enter CVV';
                        }
                        if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _useSavedCard = !_useSavedCard;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        _useSavedCard
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                    border: Border.all(
                      color:
                          _useSavedCard ? Colors.green : Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: _useSavedCard ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visa Ending in 4242',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Expires 12/${DateTime.now().year % 100 + 1}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        _useSavedCard
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: _useSavedCard ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

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
