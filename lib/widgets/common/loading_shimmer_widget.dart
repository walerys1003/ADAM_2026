import 'package:flutter/material.dart';

/// Skeleton loading shimmer widget for content placeholders.
///
/// Shows animated placeholder blocks while content loads.
/// Customizable shape, size, and layout patterns.
class LoadingShimmerWidget extends StatefulWidget {
  final ShimmerLayout layout;

  const LoadingShimmerWidget({
    super.key,
    this.layout = ShimmerLayout.list,
  });

  @override
  State<LoadingShimmerWidget> createState() => _LoadingShimmerWidgetState();
}

class _LoadingShimmerWidgetState extends State<LoadingShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: [
            0.0,
            0.5 + 0.5 * (_controller.value - 0.5).abs(),
            1.0,
          ],
        );

        return ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: _buildLayout(),
    );
  }

  Widget _buildLayout() {
    switch (widget.layout) {
      case ShimmerLayout.list:
        return _buildListShimmer();
      case ShimmerLayout.card:
        return _buildCardShimmer();
      case ShimmerLayout.detail:
        return _buildDetailShimmer();
      case ShimmerLayout.grid:
        return _buildGridShimmer();
    }
  }

  Widget _buildListShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              _shimmerBlock(width: 52, height: 52, radius: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBlock(width: double.infinity, height: 16, radius: 4),
                    const SizedBox(height: 8),
                    _shimmerBlock(width: 150, height: 12, radius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBlock(width: 200, height: 24, radius: 6),
          const SizedBox(height: 16),
          _shimmerBlock(width: double.infinity, height: 180, radius: 16),
          const SizedBox(height: 16),
          Row(
            children: [
              _shimmerBlock(width: 100, height: 36, radius: 8),
              const SizedBox(width: 12),
              _shimmerBlock(width: 100, height: 36, radius: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBlock(width: double.infinity, height: 220, radius: 16),
          const SizedBox(height: 20),
          _shimmerBlock(width: 250, height: 28, radius: 6),
          const SizedBox(height: 12),
          _shimmerBlock(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 8),
          _shimmerBlock(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 8),
          _shimmerBlock(width: 200, height: 14, radius: 4),
          const SizedBox(height: 24),
          _shimmerBlock(width: double.infinity, height: 100, radius: 12),
          const SizedBox(height: 16),
          _shimmerBlock(width: double.infinity, height: 100, radius: 12),
        ],
      ),
    );
  }

  Widget _buildGridShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return _shimmerBlock(
            width: double.infinity,
            height: double.infinity,
            radius: 16,
          );
        },
      ),
    );
  }

  Widget _shimmerBlock({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

enum ShimmerLayout { list, card, detail, grid }
