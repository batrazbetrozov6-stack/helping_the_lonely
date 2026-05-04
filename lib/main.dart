import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Анимация фона',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  // --- Анимация цвета фона (прежняя) ---
  late AnimationController _bgController;
  Animation<Color?>? _bgColorAnimation;
  final Color _initialColor = Colors.grey;
  final Color _targetColor = Colors.grey[300]!;

  // --- Анимация появления картинки ---
  late AnimationController _imageController;
  late Animation<double> _imageOpacityAnimation;

  bool _showText = false;
  int _currentIndex = 0;
  final List<String> _messages = [
    'Ты молодец, правда:)',
    'У тебя всё получится:3',
    'ты правда хороший:>',
    'ты не останешься один',
    'Ты на верном пути:)',
  ];

  final Random _random = Random();

  // Флаг: нужно ли менять текст при следующем нажатии
  bool _shouldChangeText = false;

  @override
  void initState() {
    super.initState();

    // Контроллер цвета фона
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bgColorAnimation = ColorTween(begin: _initialColor, end: _targetColor)
        .animate(_bgController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _bgController.reverse();
        }
      });

    // Контроллер появления/исчезания картинки
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // общее время "вспышки"
    );
    _imageOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_imageController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _imageController.reverse(); // после появления — исчезнуть
        }
      });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // Выбор нового случайного сообщения (без повтора подряд)
  void _changeMessageRandomly() {
    int newIndex;
    do {
      newIndex = _random.nextInt(_messages.length);
    } while (newIndex == _currentIndex);

    setState(() {
      _currentIndex = newIndex;
      _showText = true;
    });
  }

  void _onButtonPressed() {
    // Если флаг разрешает — меняем текст, затем сбрасываем флаг
    if (_shouldChangeText) {
      _changeMessageRandomly();
      _shouldChangeText = false;
    } else {
      // Иначе только запоминаем, что в следующий раз текст надо сменить
      _shouldChangeText = true;
    }

    // Запускаем обе анимации
    _bgController.forward();
    _imageController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Если анимация цвета ещё не готова, показываем статичный фон
    if (_bgColorAnimation == null) {
      return Scaffold(
        body: Container(color: _initialColor, child: _buildContent()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Цветной фон с анимацией
          AnimatedBuilder(
            animation: _bgColorAnimation!,
            builder: (context, child) {
              return Container(color: _bgColorAnimation!.value);
            },
          ),
          // Картинка, которая появляется и исчезает
          AnimatedBuilder(
            animation: _imageOpacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _imageOpacityAnimation.value,
                // Вместо иконки можно подставить свою картинку:
                // Image.asset('assets/my_image.png')
                child: const Center(
                  child: Icon(
                    Icons.favorite,
                    size: 120,
                    color: Color.fromARGB(255, 255, 100, 100),
                  ),
                ),
              );
            },
          ),
          // Основной контент (текст и кнопка)
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_showText)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _messages[_currentIndex],
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '      <3        ',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}