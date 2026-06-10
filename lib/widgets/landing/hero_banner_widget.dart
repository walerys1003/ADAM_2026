import 'package:flutter/material.dart';

/// Animated hero banner for the landing page.
/// Features a gradient background, animated illustration placeholder,
/// headline, subheadline, and dual CTA buttons.
class HeroBannerWidget extends StatefulWidget {
  final String headline;
  final String subheadline;
  final String primaryCtaText;
  final String secondaryCtaText;
  final VoidCallback? onPrimaryCta;
  final VoidCallback? onSecondaryCta;
  final String? backgroundImageUrl;

  const HeroBannerWidget({
    super.key,
    this.headline = 'Agent Adam — Twój głosowy asystent',
    this.subheadline = 'Bezpieczeństwo, zdrowie i kontakt z bliskimi — '
        'wszystko przez prostą rozmowę głosową. Dostępne 24/7.',
    this.primaryCtaText = 'Rozpocznij bezpłatny okres',
    this.secondaryCtaText = 'Zobacz demo',
    this.onPrimaryCta,
    this.onSecondaryCta,
    this.backgroundImageUrl,
  });

  @override
  State<HeroBannerWidget> createState() => _HeroBannerWidgetState();
}

class _HeroBannerWidgetState extends State<HeroBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 48,
            vertical: isMobile ? 48 : 80,
          ),
          child: isMobile ? _buildMobileLayout(theme) : _buildDesktopLayout(theme),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIllustration(200),
            const SizedBox(height: 32),
            _buildHeadline(theme),
            const SizedBox(height: 16),
            _buildSubheadline(theme),
            const SizedBox(height: 32),
            _buildCtaButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeadline(theme),
                  const SizedBox(height: 20),
                  _buildSubheadline(theme),
                  const SizedBox(height: 36),
                  _buildCtaButtons(),
                ],
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              flex: 4,
              child: _buildIllustration(350),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadline(ThemeData theme) {
    return Text(
      widget.headline,
      style: theme.textTheme.displaySmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubheadline(ThemeData theme) {
    return Text(
      widget.subheadline,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCtaButtons() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: widget.onPrimaryCta,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Text(
            widget.primaryCtaText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: widget.onSecondaryCta,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.secondaryCtaText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.mic,
          size: size * 0.4,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
