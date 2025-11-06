import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';

import '../summary_screen/summary_screen.dart';

class OnboardingQuestionScreen extends StatefulWidget {
  final List<int> selectedExperienceIds;
  final String description;

  const OnboardingQuestionScreen({
    super.key,
    required this.selectedExperienceIds,
    required this.description,
  });

  @override
  State<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  String textAnswer = '';
  String? audioPath;
  String? videoPath;
  bool isRecordingAudio = false;
  bool isRecordingVideo = false;
  bool isPlayingAudio = false;
  int audioDuration = 0;
  Timer? _audioTimer;
  VideoPlayerController? _videoController;

  // Animation controllers
  late AnimationController _waveformController;
  late AnimationController _buttonController;
  late AnimationController _cardController;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();

    // Waveform animation
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Button animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Card entrance animation
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cardController.forward();

    // Log received data
    print('📋 Received from previous screen:');
    print('Selected Experience IDs: ${widget.selectedExperienceIds}');
    print('Description: ${widget.description}');
  }
  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }
  @override
  void dispose() {
    _textController.dispose();
    _waveformController.dispose();
    _buttonController.dispose();
    _cardController.dispose();
    _audioTimer?.cancel();
    _recorder.closeRecorder();
    _audioPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  bool get canProceed =>
      textAnswer.isNotEmpty || audioPath != null || videoPath != null;

  void _startAudioRecording() async {
    try {
      final hasPermission = await Permission.microphone.request();
      if (hasPermission.isGranted) {
        final path = '/storage/emulated/0/Download/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);

        setState(() {
          isRecordingAudio = true;
          audioDuration = 0;
          audioPath = path;
        });

        _audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => audioDuration++);
          if (audioDuration >= 120) {
            _stopAudioRecording();
          }
        });

        print('🎤 Recording started: $path');
      }
    } catch (e) {
      print('Error starting recorder: $e');
    }
  }

  void _stopAudioRecording() async {
    try {
      await _recorder.stopRecorder();
      _audioTimer?.cancel();
      setState(() => isRecordingAudio = false);
      print('🎤 Recording stopped at $audioPath');
    } catch (e) {
      print('Error stopping recorder: $e');
    }
  }


  void _playAudio() async {
    if (audioPath != null) {
      try {
        setState(() {
          isPlayingAudio = true;
        });

        await _audioPlayer.play(DeviceFileSource(audioPath!));

        _audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            isPlayingAudio = false;
          });
        });
      } catch (e) {
        print('Error playing audio: $e');
        setState(() {
          isPlayingAudio = false;
        });
      }
    }
  }

  void _stopAudioPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      isPlayingAudio = false;
    });
  }

  void _deleteAudio() {
    setState(() {
      audioPath = null;
      audioDuration = 0;
    });
    print('🗑️ Audio deleted');
  }

  void _startVideoRecording({bool fromGallery = false}) async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        setState(() {
          videoPath = video.path;
        });

        _videoController = VideoPlayerController.file(File(video.path))
          ..initialize().then((_) {
            setState(() {});
          });

        print(fromGallery
            ? '📂 Video selected from gallery: $videoPath'
            : '🎥 Video recorded: $videoPath');
      }
    } catch (e) {
      print('Error selecting or recording video: $e');
    }
  }

  void _playVideo() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  void _deleteVideo() {
    _videoController?.dispose();
    setState(() {
      videoPath = null;
      _videoController = null;
    });
    print('🗑️ Video deleted');
  }

  void _submitAnswers() {
    print('\n✅ ========== SUBMISSION ==========');
    print('📋 From Previous Screen:');
    print('   Experience IDs: ${widget.selectedExperienceIds}');
    print('   Description: ${widget.description}');
    print('\n💬 Current Screen Answers:');
    print('   Text Answer: $textAnswer');
    print('   Audio Path: ${audioPath ?? "None"}');
    print('   Video Path: ${videoPath ?? "None"}');
    print('================================\n');

    // Show success message
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
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Application submitted successfully!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A0B2E),
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
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to success screen
    // Navigate to summary screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationSummaryScreen(
          selectedExperienceIds: widget.selectedExperienceIds,
          description: widget.description,
          textAnswer: textAnswer,
          audioPath: audioPath,
          videoPath: videoPath,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildQuestionCard(),
                        const SizedBox(height: 24),
                        _buildTextInputSection(),
                        const SizedBox(height: 20),
                        _buildAudioSection(),
                        const SizedBox(height: 20),
                        _buildVideoSection(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                        const SizedBox(height: 32),
                      ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
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
                        'Step 2 of 2',
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
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 1.0,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7C3AED),
                                Color(0xFFA855F7),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return FadeTransition(
      opacity: _cardController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _cardController,
          curve: Curves.easeOutCubic,
        )),
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
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
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
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Tell us more',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Why do you want to become a Hotspot Host?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Share your story through text, audio, or video. Let us know what drives your passion for hosting!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputSection() {
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
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Write your answer',
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
                    color: textAnswer.length > 600
                        ? Colors.red.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${textAnswer.length}/600',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textAnswer.length > 600
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
              controller: _textController,
              maxLines: 6,
              maxLength: 600,
              onChanged: (value) {
                setState(() {
                  textAnswer = value;
                });
              },
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText:
                'Share your motivation, experience, and what makes you unique as a host...',
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

  Widget _buildAudioSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B4E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Audio Response',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (audioPath == null && !isRecordingAudio)
                Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (isRecordingAudio) ...[
            _buildRecordingWaveform(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _stopAudioRecording,
                    icon: const Icon(Icons.stop_rounded, size: 20),
                    label: Text('Stop (${_formatDuration(audioDuration)})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _audioTimer?.cancel();
                    setState(() {
                      isRecordingAudio = false;
                      audioDuration = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red[300],
                    padding: const EdgeInsets.all(14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ] else if (audioPath != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF7C3AED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Audio recorded',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duration: ${_formatDuration(audioDuration)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _deleteAudio,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red[300],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: isPlayingAudio ? _stopAudioPlayback : _playAudio,
                    icon: Icon(
                      isPlayingAudio ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 20,
                    ),
                    label: Text(isPlayingAudio ? 'Stop Playback' : 'Play Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _startAudioRecording,
              icon: const Icon(Icons.mic_rounded, size: 22),
              label: const Text('Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingWaveform() {
    return AnimatedBuilder(
      animation: _waveformController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (index) {
            final height = 20.0 +
                (30 * (0.5 + 0.5 * (index % 2 == 0 ? _waveformController.value : 1 - _waveformController.value)));
            return Container(
              width: 4,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFA855F7),
                    Color(0xFF7C3AED),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildVideoSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B4E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Video Response',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (videoPath == null && !isRecordingVideo)
                Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (isRecordingVideo) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_rounded, color: Colors.red, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (videoPath != null) ...[
            Column(
              children: [
                GestureDetector(
                  onTap: _playVideo,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _videoController != null &&
                          _videoController!.value.isInitialized
                          ? Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio:
                            _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                          if (!_videoController!.value.isPlaying)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                        ],
                      )
                          : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _playVideo,
                        icon: Icon(
                          _videoController?.value.isPlaying == true
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 20,
                        ),
                        label: Text(
                          _videoController?.value.isPlaying == true
                              ? 'Pause Video'
                              : 'Play Video',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _deleteVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red[300],
                        padding: const EdgeInsets.all(12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                      const Icon(Icons.delete_outline_rounded, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _startVideoRecording(fromGallery: false),
                  icon: const Icon(Icons.videocam_rounded, size: 22),
                  label: const Text('Record Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _startVideoRecording(fromGallery: true),
                  icon: const Icon(Icons.video_library_rounded, size: 22),
                  label: const Text('Choose from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: canProceed ? _submitAnswers : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A0B2E),
          disabledBackgroundColor: Colors.white.withOpacity(0.2),
          disabledForegroundColor: Colors.white.withOpacity(0.4),
          elevation: canProceed ? 12 : 0,
          shadowColor: Colors.white.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Submit Application',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.send_rounded,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}