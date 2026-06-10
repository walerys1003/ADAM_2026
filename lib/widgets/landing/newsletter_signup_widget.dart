import 'package:flutter/material.dart';

/// Newsletter Signup Widget for Landing Page
/// Email capture form with validation and success animation
class NewsletterSignupWidget extends StatefulWidget {
  const NewsletterSignupWidget({super.key});

  @override
  State<NewsletterSignupWidget> createState() => _NewsletterSignupWidgetState();
}

class _NewsletterSignupWidgetState extends State<NewsletterSignupWidget> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _isSuccess ? _buildSuccessState() : _buildFormState(isWide),
    );
  }

  Widget _buildFormState(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.email_outlined, color: Colors.white, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Zapisz się do newslettera',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Otrzymuj porady dotyczące opieki nad seniorem, nowości technologiczne i informacje o aktualizacjach Agenta Adama.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: _buildEmailField()),
                    const SizedBox(width: 12),
                    _buildSubscribeButton(),
                  ],
                )
              : Column(
                  children: [
                    _buildEmailField(),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: _buildSubscribeButton()),
                  ],
                ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 12),
        Text(
          'Zero spamu. Możesz wypisać się w każdej chwili.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Dziękujemy za zapis! 🎉',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Wysłaliśmy email potwierdzający. Sprawdź swoją skrzynkę!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Twój adres email',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Wpisz adres email';
        if (!value.contains('@') || !value.contains('.')) return 'Nieprawidłowy email';
        return null;
      },
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _subscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1B5E20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1B5E20),
                ),
              )
            : const Text(
                'Zapisz się',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
