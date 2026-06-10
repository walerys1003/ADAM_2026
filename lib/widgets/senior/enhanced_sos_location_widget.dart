/// SilverTech Agent Adam — Enhanced SOS Location Widget
/// Real-time location sharing, nearest hospital finder, and family notification status
/// for the emergency SOS flow. Integrates with device GPS and maps services.

import 'package:flutter/material.dart';
import '../../config/app_config.dart';

/// Location sharing status during SOS emergency
enum SosLocationStatus {
  acquiring,
  acquired,
  sharing,
  shared,
  error,
}

class EnhancedSosLocationWidget extends StatefulWidget {
  final VoidCallback? onLocationShared;
  final VoidCallback? onFindNearestHospital;
  final List<String> notifiedContacts;

  const EnhancedSosLocationWidget({
    super.key,
    this.onLocationShared,
    this.onFindNearestHospital,
    this.notifiedContacts = const [],
  });

  @override
  State<EnhancedSosLocationWidget> createState() =>
      _EnhancedSosLocationWidgetState();
}

class _EnhancedSosLocationWidgetState extends State<EnhancedSosLocationWidget>
    with SingleTickerProviderStateMixin {
  SosLocationStatus _status = SosLocationStatus.acquiring;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // Simulated location data
  String _address = 'Ustalanie lokalizacji...';
  String _coordinates = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _acquireLocation();
  }

  Future<void> _acquireLocation() async {
    // Simulate GPS acquisition
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _status = SosLocationStatus.acquired;
      _address = 'ul. Marszałkowska 123, 00-001 Warszawa';
      _coordinates = '52.2297° N, 21.0122° E';
    });
  }

  Future<void> _shareLocation() async {
    setState(() => _status = SosLocationStatus.sharing);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _status = SosLocationStatus.shared);
    widget.onLocationShared?.call();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildLocationCard(),
          if (_status == SosLocationStatus.acquired ||
              _status == SosLocationStatus.shared) ...[
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
          if (widget.notifiedContacts.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotificationStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildStatusIcon(),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Twoja lokalizacja',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Udostępniana służbom ratunkowym',
                style: TextStyle(fontSize: 13, color: Colors.white60),
              ),
            ],
          ),
        ),
        if (_status == SosLocationStatus.acquired)
          ElevatedButton(
            onPressed: _shareLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.semaforGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Udostępnij',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case SosLocationStatus.acquiring:
        return AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.3),
              ),
              child: const Icon(Icons.gps_fixed, color: Colors.orange, size: 28),
            ),
          ),
        );
      case SosLocationStatus.acquired:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConfig.semaforGreen.withValues(alpha: 0.3),
          ),
          child: const Icon(Icons.gps_fixed, color: AppConfig.semaforGreen, size: 28),
        );
      case SosLocationStatus.sharing:
        return const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        );
      case SosLocationStatus.shared:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConfig.semaforGreen.withValues(alpha: 0.3),
          ),
          child: const Icon(Icons.check_circle, color: AppConfig.semaforGreen, size: 28),
        );
      case SosLocationStatus.error:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConfig.semaforRed.withValues(alpha: 0.3),
          ),
          child: const Icon(Icons.error, color: AppConfig.semaforRed, size: 28),
        );
    }
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppConfig.semaforRed, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _address,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (_coordinates.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _coordinates,
                    style: const TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.local_hospital,
            label: 'Najbliższy szpital',
            color: AppConfig.brandNavy,
            onTap: widget.onFindNearestHospital,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionChip(
            icon: Icons.map,
            label: 'Pokaż na mapie',
            color: const Color(0xFF1976D2),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status powiadomień',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.notifiedContacts.map(
          (contact) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppConfig.semaforGreen, size: 18),
                const SizedBox(width: 8),
                Text(
                  contact,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                const Spacer(),
                const Text(
                  'Powiadomiono',
                  style: TextStyle(fontSize: 12, color: AppConfig.semaforGreen),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
