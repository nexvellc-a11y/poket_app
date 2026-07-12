import 'package:flutter/material.dart';

class AnimatedNoDataMessage extends StatefulWidget {
  final String titleText; // First text
  final String? subtitleText; // Second text (optional)

  const AnimatedNoDataMessage({
    super.key,
    required this.titleText,
    this.subtitleText,
  });

  @override
  State<AnimatedNoDataMessage> createState() => _AnimatedNoDataMessageState();
}

class _AnimatedNoDataMessageState extends State<AnimatedNoDataMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.blue.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.blue.shade100.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.store_mall_directory_outlined,
                color: Colors.blue.shade700,
                size: 60,
              ),
              const SizedBox(height: 15),
              Text(
                widget.titleText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.subtitleText != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitleText!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
