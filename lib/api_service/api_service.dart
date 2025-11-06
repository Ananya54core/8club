import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modals/exp_modal.dart';


class ExperienceService {
  static const String baseUrl =
      'https://staging.chamberofsecrets.8club.co/v1';

  Future<ExperienceResponse> fetchExperiences() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/experiences?active=true'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ExperienceResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load experiences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching experiences: $e');
    }
  }
}