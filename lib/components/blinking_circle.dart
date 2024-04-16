import 'package:flutter/material.dart';

class BlinkingCircle extends StatefulWidget {
  const BlinkingCircle({super.key});

  @override
  BlinkingCircleState createState() => BlinkingCircleState();
}

class BlinkingCircleState extends State<BlinkingCircle>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller!.reset();
        _controller!.forward();
      }
    });

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller!,
          builder: (_, __) {
            return Container(
              width: 8.0 + (_controller!.value * 8),
              height: 8.0 + (_controller!.value * 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(1 - _controller!.value),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
        Container(
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        // Container for size reference
        Container(
          width: 16.0,
          height: 16.0,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
