import 'package:flutter/material.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';

class LoadingSpinner extends StatefulWidget {
  const LoadingSpinner({super.key});

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner> with SingleTickerProviderStateMixin {
  late ImageSequenceAnimatorState? imageSequenceAnimator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ImageSequenceAnimator(
        "assets/images/loading",
        "loading_",
        0,
        2,
        "png",
        12,
        fps: 3,
        isAutoPlay: true,
        isLooping: true,
        onReadyToPlay: (anim) {
          imageSequenceAnimator = anim;
        },
        onPlaying: (_) {
          setState(() {
            
          });
        },
      ),
    );
  }
}