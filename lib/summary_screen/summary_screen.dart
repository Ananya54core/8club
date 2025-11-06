import 'package:flutter/material.dart';
import 'dart:async';

class ApplicationSummaryScreen extends StatefulWidget {
  final List<int> selectedExperienceIds;
  final String description;
  final String textAnswer;
  final String? audioPath;
  final String? videoPath;

  const ApplicationSummaryScreen({
    super.key,
    required this.selectedExperienceIds,
    required this.description,
    required this.textAnswer,
    this.audioPath,
    this.videoPath,
  });

  @override
  State<ApplicationSummaryScreen> createState() =>
      _ApplicationSummaryScreenState();
}

class _ApplicationSummaryScreenState extends State<ApplicationSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _contentController;
  late AnimationController _floatingController;
  late Animation<double> _checkmarkScale;
  late Animation<double> _checkmarkRotation;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();

    // Checkmark animation
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkmarkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: Curves.elasticOut,
      ),
    );
    _checkmarkRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Content animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Floating animation for decorative elements
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _checkmarkController.forward();
        setState(() => _showConfetti = true);
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0B2E),
              Color(0xFF2D1B4E),
              Color(0xFF1F0F3D),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildFloatingElements(),
              _buildContent(),
              if (_showConfetti) _buildConfetti(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 100 + (_floatingController.value * 20),
              left: 30,
              child: _buildFloatingCircle(60, 0.1),
            ),
            Positioned(
              top: 200 + (_floatingController.value * -15),
              right: 40,
              child: _buildFloatingCircle(40, 0.08),
            ),
            Positioned(
              bottom: 150 + (_floatingController.value * 25),
              left: 50,
              child: _buildFloatingCircle(80, 0.12),
            ),
            Positioned(
              bottom: 250 + (_floatingController.value * -20),
              right: 30,
              child: _buildFloatingCircle(50, 0.09),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF7C3AED).withOpacity(opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ConfettiPainter(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildSuccessIcon(),
            const SizedBox(height: 32),
            _buildSuccessMessage(),
            const SizedBox(height: 40),
            _buildSummaryCards(),
            const SizedBox(height: 32),
            _buildNextSteps(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return ScaleTransition(
      scale: _checkmarkScale,
      child: RotationTransition(
        turns: _checkmarkRotation,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C3AED),
                Color(0xFFA855F7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Column(
          children: [
            const Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for taking the time to apply.\nWe\'re excited to review your submission!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.summarize_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Application Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            _buildInfoCard(
              icon: Icons.category_rounded,
              title: 'Selected Experiences',
              content: '${widget.selectedExperienceIds.length} experience categories',
              gradient: const [Color(0xFF7C3AED), Color(0xFFA855F7)],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.description_outlined,
              title: 'Description',
              content: widget.description.isNotEmpty
                  ? widget.description
                  : 'No description provided',
              gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Text Response',
              content: widget.textAnswer.isNotEmpty
                  ? '${widget.textAnswer.length} characters'
                  : 'No text response',
              gradient: const [Color(0xFF8B5CF6), Color(0xFFA855F7)],
            ),
            if (widget.audioPath != null || widget.videoPath != null) ...[
              const SizedBox(height: 12),
              _buildMediaCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B4E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard() {
    final hasAudio = widget.audioPath != null;
    final hasVideo = widget.videoPath != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B4E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.perm_media_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Media Attachments',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasAudio)
            _buildMediaChip(
              icon: Icons.mic_rounded,
              label: 'Audio Recording',
              color: const Color(0xFF7C3AED),
            ),
          if (hasAudio && hasVideo) const SizedBox(height: 8),
          if (hasVideo)
            _buildMediaChip(
              icon: Icons.videocam_rounded,
              label: 'Video Recording',
              color: const Color(0xFFEC4899),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return FadeTransition(
      opacity: _contentFade,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7C3AED).withOpacity(0.15),
              const Color(0xFF2D1B4E).withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'What happens next?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTimelineStep(
              number: '1',
              title: 'Application Review',
              description: 'Our team will carefully review your application within 3-5 business days.',
              isFirst: true,
            ),
            _buildTimelineStep(
              number: '2',
              title: 'Verification Process',
              description: 'We may reach out for additional information or clarification.',
            ),
            _buildTimelineStep(
              number: '3',
              title: 'Final Decision',
              description: 'You\'ll receive an email with our decision and next steps.',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String number,
    required String title,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF7C3AED).withOpacity(0.5),
                      const Color(0xFF7C3AED).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _contentFade,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to home or dashboard
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A0B2E),
                elevation: 12,
                shadowColor: Colors.white.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.home_rounded, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // View application details or help
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Check your email for application reference number',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF7C3AED),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
            child: Text(
              'Need help? Contact support',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = [
      {'x': 0.2, 'y': 0.15, 'size': 8.0, 'color': const Color(0xFF7C3AED)},
      {'x': 0.8, 'y': 0.1, 'size': 6.0, 'color': const Color(0xFFA855F7)},
      {'x': 0.15, 'y': 0.3, 'size': 10.0, 'color': const Color(0xFFEC4899)},
      {'x': 0.85, 'y': 0.25, 'size': 7.0, 'color': const Color(0xFF8B5CF6)},
      {'x': 0.5, 'y': 0.05, 'size': 9.0, 'color': const Color(0xFFF472B6)},
      {'x': 0.3, 'y': 0.2, 'size': 5.0, 'color': const Color(0xFF7C3AED)},
      {'x': 0.7, 'y': 0.18, 'size': 8.0, 'color': const Color(0xFFA855F7)},
    ];

    for (var particle in random) {
      paint.color = (particle['color'] as Color).withOpacity(0.6);
      canvas.drawCircle(
        Offset(
          size.width * (particle['x'] as double),
          size.height * (particle['y'] as double),
        ),
        particle['size'] as double,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}