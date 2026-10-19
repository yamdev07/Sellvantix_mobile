import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final _player = AudioPlayer();

  static Future<bool> _isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_enabled') ?? true;
  }

  static Future<void> setEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', v);
  }

  static Future<bool> isEnabled() => _isEnabled();

  /// Joue le son de caisse (bip + ding générés en mémoire, pas de fichier asset).
  static Future<void> playCheckout() async {
    if (!await _isEnabled()) return;
    final wav = _buildWav(frequency: 880, durationSeconds: 0.08, amplitude: 0.6);
    await _player.play(BytesSource(wav));
    await Future.delayed(const Duration(milliseconds: 100));
    final wav2 = _buildWav(frequency: 1320, durationSeconds: 0.18, amplitude: 0.5);
    await _player.play(BytesSource(wav2));
  }

  static Uint8List _buildWav({
    required int frequency,
    required double durationSeconds,
    required double amplitude,
    int sampleRate = 22050,
  }) {
    final numSamples = (sampleRate * durationSeconds).round();
    final dataSize = numSamples * 2;
    final buf = ByteData(44 + dataSize);
    var off = 0;

    void str(String s) {
      for (final c in s.codeUnits) {
        buf.setUint8(off++, c);
      }
    }

    void u16(int v) { buf.setUint16(off, v, Endian.little); off += 2; }
    void u32(int v) { buf.setUint32(off, v, Endian.little); off += 4; }

    str('RIFF'); u32(36 + dataSize); str('WAVE');
    str('fmt '); u32(16); u16(1); u16(1);
    u32(sampleRate); u32(sampleRate * 2); u16(2); u16(16);
    str('data'); u32(dataSize);

    final amp = (32767 * amplitude).round();
    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = math.pow(1.0 - i / numSamples, 1.5).toDouble();
      final s = (math.sin(2 * math.pi * frequency * t) * amp * env)
          .round()
          .clamp(-32768, 32767);
      buf.setInt16(off, s, Endian.little);
      off += 2;
    }
    return buf.buffer.asUint8List();
  }
}
