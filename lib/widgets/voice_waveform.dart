import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Динамическая визуализация «голоса»: полоски двигаются, пока [isSpeaking] true.
class VoiceWaveform extends StatefulWidget {
  final bool isSpeaking;

  const VoiceWaveform({Key? key, required this.isSpeaking}) : super(key: key);

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const barCount = 12;
    const barWidth = 4.0;
    const spacing = 6.0;
    const maxHeight = 32.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (!widget.isSpeaking) {
          return SizedBox(
            height: maxHeight + 16,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  barCount,
                  (_) => Container(
                    width: barWidth,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: spacing / 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return SizedBox(
          height: maxHeight + 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(barCount, (i) {
              final phase = (i / barCount) * 2 * math.pi;
              final t = _controller.value * 2 * math.pi;
              final scale = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(t + phase));
              final h = 8 + maxHeight * scale;
              return Container(
                width: barWidth,
                height: h.clamp(8.0, maxHeight),
                margin: const EdgeInsets.symmetric(horizontal: spacing / 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
