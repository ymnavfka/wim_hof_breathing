import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

enum PracticePhase {
  start,
  breathing,
  holdFree,
  preHoldInhale,
  holdFixed,
  postHoldExhale,
}

enum BreathState { inhale, exhale }

class PracticeScreen extends StatefulWidget {
  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  PracticePhase _currentPhase = PracticePhase.start;
  int _breathCounter = 0;
  int _secondsCounted = 0;
  Timer? _timer;
  int _freeHoldTime = 0;
  BreathState _breathState = BreathState.inhale;
  double _breathProgress = 0.0;
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _fxPlayer = AudioPlayer();

  Widget _progressBar(double begin, double end) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: begin, end: end),
          duration: Duration(milliseconds: 2000),
          builder: (context, value, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startPractice() {
    setState(() {
      _currentPhase = PracticePhase.breathing;
      _breathCounter = 0;
      _secondsCounted = 0;
      _breathState = BreathState.inhale;
      _breathProgress = 1.0;
    });

    _bgPlayer.setReleaseMode(ReleaseMode.loop);
    _bgPlayer.setVolume(0.2);
    _bgPlayer.play(AssetSource('sounds/bg_music.mp3'));

    _fxPlayer.setVolume(1.0);
    _fxPlayer.play(AssetSource('sounds/inhale.mp3'));

    _startBreathing();
  }

  void _startBreathing() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        if (_breathState == BreathState.inhale) {
          _breathState = BreathState.exhale;
          _breathProgress = 0.0;
          _fxPlayer.setVolume(1.0);
          _fxPlayer.play(AssetSource('sounds/exhale.mp3'));
        } else {
          _breathState = BreathState.inhale;
          _breathCounter++;
          _breathProgress = 1.0;
          _fxPlayer.setVolume(1.0);
          _fxPlayer.play(AssetSource('sounds/inhale.mp3'));
        }

        if (_breathCounter > 30) {
          _fxPlayer.stop();
          timer.cancel();
          _currentPhase = PracticePhase.holdFree;
          _secondsCounted = 0;
          _breathProgress = 0.0;
          _startFreeHold();
        }
      });
    });
  }

  void _startFreeHold() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsCounted++;
      });
    });
  }

  void _finishFreeHold() {
    _freeHoldTime = _secondsCounted;
    _startPreHold();
  }

  void _startPreHold() {
    _timer?.cancel();
    setState(() {
      _currentPhase = PracticePhase.preHoldInhale;
      _secondsCounted = 0;
      _breathState = BreathState.inhale;
      _breathProgress = 1.0;
      _fxPlayer.setVolume(1.0);
      _fxPlayer.play(AssetSource('sounds/inhale.mp3'));
    });
    _timer = Timer(Duration(seconds: 2), () {
      setState(() {
        _currentPhase = PracticePhase.holdFixed;
        _secondsCounted = 0;
        _breathProgress = 0.0;
      });
      _startFixedHold();
    });
  }

  void _startFixedHold() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsCounted++;
        if (_secondsCounted >= 15) {
          timer.cancel();
          _startPostHoldExhale();
        }
      });
    });
  }

  void _startPostHoldExhale() {
    _timer?.cancel();
    setState(() {
      _currentPhase = PracticePhase.postHoldExhale;
      _breathState = BreathState.exhale;
      _breathProgress = 0.0;
      _fxPlayer.setVolume(1.0);
      _fxPlayer.play(AssetSource('sounds/exhale.mp3'));
    });
    _timer = Timer(Duration(seconds: 2), () {
      setState(() {
        _currentPhase = PracticePhase.start;
        _secondsCounted = 0;
        _breathCounter = 0;
        _breathProgress = 0.0;
        _bgPlayer.stop();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgPlayer.dispose();
    _fxPlayer.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    switch (_currentPhase) {
      case PracticePhase.start:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _startPractice,
          child: SizedBox.expand(
            child: Center(
              child: Text("Tap anywhere to start",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
        );

      case PracticePhase.breathing:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Breathing phase",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              _breathState == BreathState.inhale ? "Inhale" : "Exhale",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Breath count: $_breathCounter",
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(height: 30),
            _progressBar(0.0, _breathProgress),
          ],
        );

      case PracticePhase.preHoldInhale:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Preparing to hold",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Inhale",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            _progressBar(0.0, 1.0),
          ],
        );

      case PracticePhase.holdFree:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finishFreeHold,
          child: SizedBox.expand(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Free hold (tap anywhere to stop)",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text("Time: $_secondsCounted s", style: TextStyle(fontSize: 40)),
                ],
              ),
            ),
          ),
        );

      case PracticePhase.holdFixed:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Fixed hold (15s)",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Time: $_secondsCounted / 15", style: TextStyle(fontSize: 40)),
            SizedBox(height: 20),
            Text(
              "Your free hold: $_freeHoldTime s",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        );

      case PracticePhase.postHoldExhale:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Exhale",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            _progressBar(1.0, 0.0),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Practice")),
      body: Center(child: _buildContent()),
    );
  }
}
