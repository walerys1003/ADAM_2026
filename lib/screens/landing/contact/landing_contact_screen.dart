/// SilverTech Agent Adam — Landing Page Contact Form
/// Lead capture, inquiry types, validation, email notification

import 'package:flutter/material.dart';
import '../../../config/app_config.dart';

class LandingContactScreen extends StatefulWidget {
  const LandingContactScreen({super.key});

  @override
  State<LandingContactScreen> createState() => _LandingContactScreenState();
}

class _LandingContactScreenState extends State<LandingContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String _inquiryType = 'Informacja o usłudze';
  bool _agreeContact = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  final _inquiryTypes = [
    'Informacja o usłudze',
    'Wycena dla rodziny',
    'Współpraca (B2B)',
    'Demo / Prezentacja',
    'Pomoc techniczna',
    'Inne',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildFormSection(),
            _buildContactInfo(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: const Column(
        children: [
          Text('Skontaktuj się z nami',
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white)),
          SizedBox(height: 12),
          Text('Odpowiadamy w ciągu 24h. Bezpłatna konsultacja.',
              style: TextStyle(fontSize: 17, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    if (_isSubmitted) return _buildSuccessState();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Formularz kontaktowy',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Imię i nazwisko', Icons.person),
                validator: (v) => v == null || v.trim().isEmpty ? 'Proszę podać imię' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email', Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Proszę podać email';
                  if (!v.contains('@')) return 'Proszę podać prawidłowy email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('Telefon (opcjonalnie)', Icons.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Inquiry type
              DropdownButtonFormField<String>(
                value: _inquiryType,
                decoration: _inputDecoration('Rodzaj zapytania', Icons.category),
                items: _inquiryTypes.map((t) =>
                    DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _inquiryType = v!),
              ),
              const SizedBox(height: 16),

              // Message
              TextFormField(
                controller: _messageController,
                decoration: _inputDecoration('Wiadomość', Icons.message),
                maxLines: 5,
                validator: (v) => v == null || v.trim().isEmpty ? 'Proszę wpisać wiadomość' : null,
              ),
              const SizedBox(height: 20),

              // Consent
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeContact,
                    onChanged: (v) => setState(() => _agreeContact = v ?? false),
                    activeColor: AppConfig.brandNavy,
                  ),
                  Expanded(
                    child: Text(
                      'Wyrażam zgodę na kontakt telefoniczny i mailowy w sprawie przedstawienia oferty SilverTech. Administratorem danych jest SilverTech Sp. z o.o.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || !_agreeContact) ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.brandNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Wyślij zapytanie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppConfig.brandNavy, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });
  }

  Widget _buildSuccessState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 44, color: Colors.green),
            ),
            const SizedBox(height: 24),
            const Text('Dziękujemy za kontakt!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('Odpowiemy w ciągu 24 godzin na podany adres email.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => setState(() => _isSubmitted = false),
              child: const Text('Wyślij kolejne zapytanie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
        ),
        child: Column(
          children: [
            const Text('Inne sposoby kontaktu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            _buildContactRow(Icons.phone, 'Telefon', '+48 22 123 45 67'),
            const SizedBox(height: 16),
            _buildContactRow(Icons.email, 'Email', 'kontakt@silvertech.ai'),
            const SizedBox(height: 16),
            _buildContactRow(Icons.location_on, 'Adres', 'ul. Przykładowa 123, 00-001 Warszawa'),
            const SizedBox(height: 16),
            _buildContactRow(Icons.access_time, 'Godziny', 'Pn-Pt 8:00-18:00'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppConfig.brandNavy, size: 24),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ],
    );
  }
}
