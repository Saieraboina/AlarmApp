

import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  bool isTimerMode = true;
  String currentTime = '00:00:00';
  bool isTimerRunning = false;
  bool isStopwatchRunning = false;
  int timerDuration = 0;
  int remainingDuration = 0;
  int stopwatchSeconds = 0;
  Timer? timer;
  Timer? stopwatchTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentTime,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 20),
            if (isTimerMode) ...[
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Set Timer'),
                        content: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              timerDuration = int.tryParse(value) ?? 0;
                              remainingDuration = timerDuration;
                              currentTime = formatTime(remainingDuration);
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter timer duration in seconds',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              startTimer();
                            },
                            child: const Text('Start'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Start Timer'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  stopTimer();
                },
                child: const Text('Stop Timer'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  startStopwatch();
                },
                child: const Text('Start Stopwatch'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  stopStopwatch();
                },
                child: const Text('Stop Stopwatch'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                reset();
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isTimerMode ? 0 : 1,
        onTap: (index) {
          setState(() {
            isTimerMode = index == 0;
            reset();
          });
        },
        items: const[
           BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.watch),
            label: 'Stopwatch',
          ),
        ],
      ),
    );
  }

  void startTimer() {
    setState(() {
      isTimerRunning = true;
    });
    countdownTimer();
  }

  void countdownTimer() {
    if (remainingDuration > 0) {
      timer = Timer(const Duration(seconds: 1), () {
        if (mounted && isTimerRunning) {
          setState(() {
            remainingDuration--;
            currentTime = formatTime(remainingDuration);
            countdownTimer();
          });
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Time Up'),
            content: const Text('Timer has ended.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  reset();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void stopTimer() {
    if (isTimerRunning) {
      setState(() {
        isTimerRunning = false;
      });
      timer?.cancel();
    }
  }

  void startStopwatch() {
    setState(() {
      currentTime = '00:00:00';
    });
    startCounting();
  }

  void startCounting() {
    stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        stopwatchSeconds++;
        currentTime = formatTime(stopwatchSeconds);
      });
    });
  }

  void stopStopwatch() {
    if (isStopwatchRunning) {
      setState(() {
        isStopwatchRunning = false;
      });
      stopwatchTimer?.cancel();
    }
  }

  void reset() {
    setState(() {
      isTimerRunning = false;
      isStopwatchRunning = false;
      timerDuration = 0;
      remainingDuration = 0;
      stopwatchSeconds = 0;
      currentTime = '00:00:00';
    });
    timer?.cancel();
    stopwatchTimer?.cancel();
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = secs.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }
}
