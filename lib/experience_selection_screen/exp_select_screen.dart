import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modals/exp_modal.dart';
import '../onboarding_screen/onboarding_screen.dart';
import '../providers/exp_provider.dart';


class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState extends State<ExperienceSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Button animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    );

    // Fetch experiences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExperienceProvider>().fetchExperiences();
    });
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Get sorted experiences with selected ones first
  List<Experience> _getSortedExperiences(ExperienceProvider provider) {
    final experiences = List<Experience>.from(provider.experiences);
    experiences.sort((a, b) {
      final aSelected = provider.isSelected(a.id);
      final bSelected = provider.isSelected(b.id);

      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return 0;
    });
    return experiences;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A0B2E), // Deep purple black
              const Color(0xFF2D1B4E), // Purple
              const Color(0xFF1F0F3D), // Dark purple
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<ExperienceProvider>(
            builder: (context, provider, child) {
              // Animate button when selection changes
              if (provider.canProceed && !_buttonController.isCompleted) {
                _buttonController.forward();
              } else if (!provider.canProceed && _buttonController.isCompleted) {
                _buttonController.reverse();
              }

              return Column(
                children: [
                  _buildHeader(provider),
                  Expanded(
                    child: provider.isLoading
                        ? _buildLoadingState()
                        : provider.errorMessage != null
                        ? _buildErrorState(provider.errorMessage!)
                        : _buildContent(provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ExperienceProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Step 1 of 2',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.selectedExperienceIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: const Color(0xFF7C3AED),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${provider.selectedExperienceIds.length} selected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7C3AED),
                          const Color(0xFFA855F7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'What kind of experiences\ndo you want to host?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select one or more categories that match your interests',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading experiences...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load experiences',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ExperienceProvider>().fetchExperiences();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A0B2E),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ExperienceProvider provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildExperienceGrid(provider),
            const SizedBox(height: 32),
            _buildDescriptionField(provider),
            const SizedBox(height: 24),
            _buildNextButton(provider),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceGrid(ExperienceProvider provider) {
    final sortedExperiences = _getSortedExperiences(provider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: GridView.builder(
        key: ValueKey(provider.selectedExperienceIds.join(',')),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemCount: sortedExperiences.length,
        itemBuilder: (context, index) {
          final experience = sortedExperiences[index];
          final isSelected = provider.isSelected(experience.id);
          return _buildExperienceCard(experience, isSelected, provider);
        },
      ),
    );
  }

  Widget _buildExperienceCard(
      Experience experience,
      bool isSelected,
      ExperienceProvider provider,
      ) {
    return GestureDetector(
      onTap: () {
        provider.toggleExperience(experience.id);
        // Add haptic feedback
        // HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.white.withOpacity(0.25)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 6),
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with grayscale effect for unselected
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.transparent,
                  isSelected ? BlendMode.dst : BlendMode.saturation,
                ),
                child: Image.network(
                  experience.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2D1B4E),
                            const Color(0xFF1A0B2E),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: Colors.white54,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2D1B4E),
                            const Color(0xFF1A0B2E),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(isSelected ? 0.7 : 0.85),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // Purple overlay for unselected cards
              if (!isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0B2E).withOpacity(0.4),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (experience.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        experience.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Selection Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: isSelected ? 12 : -50,
                right: 12,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: const Color(0xFF7C3AED),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(ExperienceProvider provider) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tell us more',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.descriptionText.length > 250
                        ? Colors.red.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.descriptionText.length}/250',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: provider.descriptionText.length > 250
                          ? Colors.red[300]
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 250,
              onChanged: (value) {
                provider.updateDescription(value);
              },
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Describe the unique experiences you want to create for your guests...',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.4),
                  height: 1.5,
                ),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(ExperienceProvider provider) {
    return FadeTransition(
      opacity: _buttonAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_buttonAnimation),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: provider.canProceed
                ? () {
              // Log the state
              provider.printSelection();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OnboardingQuestionScreen(
                    selectedExperienceIds: provider.selectedExperienceIds.toList(),
                    description: provider.descriptionText,
                  ),
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Selected ${provider.selectedExperienceIds.length} experience(s)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A0B2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.all(16),
                  elevation: 8,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A0B2E),
              disabledBackgroundColor: Colors.white.withOpacity(0.2),
              disabledForegroundColor: Colors.white.withOpacity(0.4),
              elevation: provider.canProceed ? 12 : 0,
              shadowColor: Colors.white.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}