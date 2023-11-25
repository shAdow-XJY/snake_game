import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于键盘输入

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SnakeHomePage(),
    );
  }
}

class SnakeHomePage extends StatefulWidget {
  const SnakeHomePage({super.key});

  @override
  State<SnakeHomePage> createState() => _SnakeHomePageState();
}

class _SnakeHomePageState extends State<SnakeHomePage> {
  final int rows = 20;
  final int columns = 20;
  final double cellSize = 20.0; // 调整单元格大小以适应屏幕

  List<Offset> snakePosition = [];
  late Offset foodPosition;
  String direction = 'up';
  late Timer timer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    snakePosition = [Offset(rows / 2, columns / 2)];
    _generateNewFood();
    // timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 300), (Timer t) {
      _updateGame();
    });
  }

  void _updateGame() {
    setState(() {
      var newHeadPos = snakePosition.first;
      switch (direction) {
        case 'up':
          newHeadPos = newHeadPos.translate(0, -1);
          break;
        case 'down':
          newHeadPos = newHeadPos.translate(0, 1);
          break;
        case 'left':
          newHeadPos = newHeadPos.translate(-1, 0);
          break;
        case 'right':
          newHeadPos = newHeadPos.translate(1, 0);
          break;
      }

      // 检查边界
      if (newHeadPos.dx < 0 ||
          newHeadPos.dy < 0 ||
          newHeadPos.dx >= columns ||
          newHeadPos.dy >= rows) {
        isGameOver = true;
        timer.cancel();
        return;
      }

      snakePosition.insert(0, newHeadPos);
      if (newHeadPos == foodPosition) {
        _generateNewFood();
      } else {
        snakePosition.removeLast();
      }
    });
  }

  void _generateNewFood() {
    foodPosition = Offset(
      Random().nextInt(rows).toDouble(),
      Random().nextInt(columns).toDouble(),
    );
  }

  // 添加键盘方向控制的函数
  void _handleKeyEvent(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
          direction != 'down') {
        direction = 'up';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
          direction != 'up') {
        direction = 'down';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          direction != 'right') {
        direction = 'left';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          direction != 'left') {
        direction = 'right';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      // 显示游戏结束屏幕
      return Scaffold(
        appBar: AppBar(
          title: const Text('Game Over'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Game Over',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isGameOver = false;
                    _startGame();
                  });
                },
                child: const Text('Restart'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1, // 保持网格为正方形
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: _handleKeyEvent,
            autofocus: true,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(), // 禁用滚动
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                ),
                itemCount: rows * columns,
                itemBuilder: (BuildContext context, int index) {
                  Color? color;
                  var x = index % rows;
                  var y = (index / columns).floor();
                  bool isSnakeBody = snakePosition
                      .contains(Offset(x.toDouble(), y.toDouble()));
                  bool isFood =
                      foodPosition == Offset(x.toDouble(), y.toDouble());

                  if (isSnakeBody) {
                    color = Colors.green;
                  } else if (isFood) {
                    color = Colors.red;
                  } else {
                    color = Colors.grey[300];
                  }

                  return Container(
                    margin: const EdgeInsets.all(1),
                    color: color,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
