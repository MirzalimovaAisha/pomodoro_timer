import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sprintf/sprintf.dart';
import 'dart:async';

enum TimerStatus{
  running,
  paused,
  stopped,
  resting,
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {

  static const WORK_SECONDS = 25; // * 60
  static const REST_SECONDS = 5;  // * 60

  late TimerStatus _timerStatus;
  late int _timer;
  late int _pomodoroCount;



  @override
  void initState(){
    super.initState();
    _timerStatus = TimerStatus.stopped;
    print(_timerStatus.toString());
    _timer = WORK_SECONDS;
    _pomodoroCount = 0;
  }

  String secondsToString(int seconds){
    return sprintf("%02d:%02d", [seconds ~/ 60, seconds % 60]);
  }

  // run 이벤트
  void run(){
    setState(() {
      _timerStatus = TimerStatus.running;
      print("[=>]" + _timerStatus.toString());
      runTimer();
    });
  }

  // rest 이벤트
  void rest(){
    setState(() {
      _timer = REST_SECONDS;
      _timerStatus = TimerStatus.resting;
      print("[=>]" + _timerStatus.toString());
    });
  }

  // pause 이벤트
  void pause(){
    setState(() {
      _timerStatus = TimerStatus.paused;
      print("[=>]" + _timerStatus.toString());
    });
  }

  // resume 이벤트
  void resume(){
    run();
  }

  // 정지 이벤트
  void stop(){
    setState(() {
      _timer = WORK_SECONDS;
      _timerStatus = TimerStatus.stopped;
      print("[=>]" + _timerStatus.toString());
    });
  }

  void runTimer() async{
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      switch (_timerStatus){
        case TimerStatus.paused:
          t.cancel();
          break;
        case TimerStatus.stopped:
          t.cancel();
          break;
        case TimerStatus.running:
          if(_timer <= 0){
            showToast('작업 완료!');
            rest();
          } else {
            setState(() {
              _timer -= 1;
            });
          }
          break;
        case TimerStatus.resting:
          if (_timer <= 0) {
            setState(() {
              _pomodoroCount += 1;
            });
            showToast('오늘 $_pomodoroCount개의 뽀모도로를 달성했습니다.');
            t.cancel();
            stop();
          } else {
            setState(() {
              _timer -= 1;
            });
          }
          break;
        default:
          break;
      }
    });
  }

  // === Toast ===
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength:  Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> runningButtons = [
      ElevatedButton(
        onPressed: _timerStatus == TimerStatus.paused ? resume : pause,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: Text(
          _timerStatus == TimerStatus.paused ? '계속하기' : '일시정지',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),

      const Padding(
        padding: EdgeInsets.all(20),
      ),

      ElevatedButton(
        onPressed: stop,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: const Text('포기하기', style: TextStyle(fontSize: 18, color: Colors.white),),
      ),
    ];

    final List<Widget> stoppedButtons = [
      ElevatedButton(
        onPressed: run,
        style: ElevatedButton.styleFrom(
          backgroundColor: _timerStatus == TimerStatus.resting ? Colors.green : Colors.blue,
        ),
        child: const Text('시작하기', style: TextStyle(fontSize: 18, color: Colors.white),),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('뽀모도로 타이머', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: _timerStatus == TimerStatus.resting ? Colors.green : Colors.blue,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _timerStatus == TimerStatus.resting ? Colors.green : Colors.blue,
            ),
            child: Center(
              child: Text(
                secondsToString(_timer),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _timerStatus == TimerStatus.resting
            ? const []
                : _timerStatus == TimerStatus.stopped
                ? stoppedButtons
                : runningButtons,
          )
        ],
      ),
    );
  }
}
