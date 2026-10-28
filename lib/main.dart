import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Roller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D1B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF91F2D1),
          brightness: Brightness.dark,
        ),
      ),
      home: const DiceRollerPage(),
    );
  }
}

class DiceRollerPage extends StatefulWidget {
  const DiceRollerPage({super.key});

  @override
  State<DiceRollerPage> createState() => _DiceRollerPageState();
}

class _DiceRollerPageState extends State<DiceRollerPage>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF91F2D1);
  static const _mutedText = Color(0xFFA8B0C7);

  late final AnimationController _controller;
  final math.Random _random = math.Random();

  int? _result;
  int _rollingResult = 1;
  bool _isRolling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
      _result = _random.nextInt(6) + 1;
    });

    await _controller.forward(from: 0);

    if (!mounted) return;
    setState(() {
      _isRolling = false;
      _rollingResult = _result!;
    });
  }

  int get _visibleDiceValue {
    if (!_isRolling || _controller.value >= 0.9) {
      return _result ?? _rollingResult;
    }

    final tick = (_controller.value * 30).floor();
    return (tick % 6) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17233A), Color(0xFF0D1427), Color(0xFF090D1B)],
            stops: [0, 0.48, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 28),
                      _buildHeader(),
                      _buildDice(),
                      _buildResult(),
                      _buildRollButton(),
                      const SizedBox(height: 20),
                      const Text(
                        'A little luck, one roll away',
                        style: TextStyle(
                          color: _mutedText,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 15, color: _accent),
              SizedBox(width: 7),
              Text(
                'YOUR MOMENT OF CHANCE',
                style: TextStyle(
                  color: _accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Dice Roller',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap below and see where the dice land.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _mutedText, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildDice() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 252.0);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final fade = (1 - progress).clamp(0.0, 1.0);
            final rotationX = _isRolling
                ? math.sin(progress * math.pi * 8) * 0.42
                : 0.0;
            final rotationY = _isRolling
                ? math.cos(progress * math.pi * 8) * 0.42
                : 0.0;
            final rotationZ = _isRolling ? progress * math.pi * 6 : 0.0;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(rotationX)
                ..rotateY(rotationY)
                ..rotateZ(rotationZ),
              child: Transform.scale(
                scale: _isRolling
                    ? 1 + (0.08 * math.sin(progress * math.pi))
                    : 1,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(
                          alpha: _isRolling ? 0.24 * fade : 0.13,
                        ),
                        blurRadius: _isRolling ? 42 : 34,
                        spreadRadius: 2,
                        offset: const Offset(0, 18),
                      ),
                      const BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 24,
                        offset: Offset(0, 22),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(42),
                    child: CustomPaint(
                      painter: _DicePainter(_visibleDiceValue),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        Text(
          _isRolling
              ? 'ROLLING'
              : _result == null
              ? 'READY WHEN YOU ARE'
              : 'YOU ROLLED',
          style: const TextStyle(
            color: _mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            _result?.toString() ?? '—',
            key: ValueKey(_result),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRollButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton(
        onPressed: _isRolling ? null : _rollDice,
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: const Color(0xFF10251F),
          disabledBackgroundColor: _accent.withValues(alpha: 0.55),
          disabledForegroundColor: const Color(0xFF10251F)
              .withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRolling) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF10251F),
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              const Icon(Icons.casino_outlined, size: 20),
              const SizedBox(width: 9),
            ],
            Text(_isRolling ? 'Rolling...' : 'Roll the dice'),
          ],
        ),
      ),
    );
  }
}

class _DicePainter extends CustomPainter {
  const _DicePainter(this.value);

  final int value;

  static const _pipPositions = <int, List<int>>{
    1: [4],
    2: [0, 8],
    3: [0, 4, 8],
    4: [0, 2, 6, 8],
    5: [0, 2, 4, 6, 8],
    6: [0, 2, 3, 5, 6, 8],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final cornerRadius = size.width * 0.17;
    final diceRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius),
    );

    canvas.drawRRect(
      diceRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFE7ECF5)],
        ).createShader(rect),
    );

    final inset = size.width * 0.1;
    final innerSize = size.width - inset * 2;
    final pipRadius = size.width * 0.055;
    final pipPaint = Paint()..color = const Color(0xFF17233A);

    for (final position in _pipPositions[value] ?? const <int>[]) {
      final row = position ~/ 3;
      final column = position % 3;
      final center = Offset(
        inset + innerSize * (column + 0.5) / 3,
        inset + innerSize * (row + 0.5) / 3,
      );
      canvas.drawCircle(center, pipRadius, pipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DicePainter oldDelegate) =>
      oldDelegate.value != value;
}
