import 'package:flutter/material.dart';

import '../api_service/api_service.dart';
import '../modals/exp_modal.dart';


class ExperienceProvider extends ChangeNotifier {
  final ExperienceService _service = ExperienceService();

  List<Experience> _experiences = [];
  Set<int> _selectedExperienceIds = {};
  String _descriptionText = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Experience> get experiences => _experiences;
  Set<int> get selectedExperienceIds => _selectedExperienceIds;
  String get descriptionText => _descriptionText;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canProceed => _selectedExperienceIds.isNotEmpty;

  // Fetch experiences from API
  Future<void> fetchExperiences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.fetchExperiences();
      _experiences = response.experiences;
      _experiences.sort((a, b) => a.order.compareTo(b.order));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle experience selection
  void toggleExperience(int id) {
    if (_selectedExperienceIds.contains(id)) {
      _selectedExperienceIds.remove(id);
    } else {
      _selectedExperienceIds.add(id);
    }
    notifyListeners();
  }

  // Check if experience is selected
  bool isSelected(int id) {
    return _selectedExperienceIds.contains(id);
  }

  // Update description text
  void updateDescription(String text) {
    _descriptionText = text;
    notifyListeners();
  }

  // Get selected experiences for navigation
  List<Experience> getSelectedExperiences() {
    return _experiences
        .where((exp) => _selectedExperienceIds.contains(exp.id))
        .toList();
  }

  // Reset state
  void reset() {
    _selectedExperienceIds.clear();
    _descriptionText = '';
    notifyListeners();
  }

  // Print selection (for debugging/logging)
  void printSelection() {
    debugPrint('Selected Experience IDs: $_selectedExperienceIds');
    debugPrint('Description: $_descriptionText');
    debugPrint('Selected Experiences: ${getSelectedExperiences().map((e) => e.name).join(", ")}');
  }
}