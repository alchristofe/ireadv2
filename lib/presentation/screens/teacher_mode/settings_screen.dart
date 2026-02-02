import 'package:flutter/material.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/utils/background_music_manager.dart';
import 'package:iread/core/utils/audio_player_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedTrack;
  final List<String> _tracks = [
    'childplay.m4a',
    'childrenadventure.m4a',
    'ticklefur.m4a',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentTrack();
  }

  Future<void> _loadCurrentTrack() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTrack = prefs.getString('selected_background_music');
    });
  }

  Future<void> _selectTrack(String track) async {
    setState(() {
      _selectedTrack = track;
    });
    await BackgroundMusicManager.instance.play(track);
  }

  Future<void> _stopMusic() async {
    setState(() {
      _selectedTrack = null;
    });
    await BackgroundMusicManager.instance.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.heading3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Background Music', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Select music to play throughout the app. It will automatically mute when the child is speaking.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    // Sound Effects Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Button Sound Effects',
                          style: AppTextStyles.bodyLarge,
                        ),
                        subtitle: Text(
                          'Play sounds when tapping buttons',
                          style: AppTextStyles.bodySmall,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: AppColors.secondary,
                          ),
                        ),
                        value: AudioPlayerUtil.isSfxEnabled,
                        onChanged: (value) async {
                          await AudioPlayerUtil.toggleSfx(value);
                          setState(() {});
                        },
                        activeTrackColor: AppColors.secondary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTrackOption(
                      title: 'No Music',
                      isSelected: _selectedTrack == null,
                      onTap: _stopMusic,
                      icon: Icons.music_off,
                    ),
                    const SizedBox(height: 24),

                    // Global Music Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Enable Background Music',
                          style: AppTextStyles.bodyLarge,
                        ),
                        subtitle: Text(
                          'Turn background music on or off globally',
                          style: AppTextStyles.bodySmall,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: AppColors.primary,
                          ),
                        ),
                        value: BackgroundMusicManager.instance.isMusicEnabled,
                        onChanged: (value) async {
                          await BackgroundMusicManager.instance.toggleMusic(
                            value,
                          );
                          setState(() {});
                        },
                        activeTrackColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Background Music Tracks',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 12),
                    ..._tracks.map(
                      (track) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTrackOption(
                          title: _formatTrackName(track),
                          isSelected: _selectedTrack == track,
                          onTap: () => _selectTrack(track),
                          icon: Icons.music_note,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTrackName(String filename) {
    return filename
        .replaceAll('.m4a', '')
        .replaceAll('.mp3', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  Widget _buildTrackOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.disabledGray.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textMedium,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
