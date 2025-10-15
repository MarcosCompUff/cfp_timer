import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOPEEE',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const CountdownPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> with SingleTickerProviderStateMixin {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  final DateTime _target = DateTime(2025, 11, 14);

  // Controle de animação para mover as imagens
  late AnimationController _imgController;
  late Animation<double> _leftAnim;
  late Animation<double> _rightAnim;

  bool _showBebe = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());

    // Animação de vai-e-vem para as imagens
    _imgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Esquerda: 0 -> +30 (direita), Direita: 0 -> -30 (esquerda)
    _leftAnim = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(parent: _imgController, curve: Curves.easeInOut),
    );
    _rightAnim = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(parent: _imgController, curve: Curves.easeInOut),
    );
  }

  void _updateRemaining() {
    final now = DateTime.now();
    setState(() {
      _remaining = _target.difference(now);
      if (_remaining.isNegative) {
        _remaining = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _imgController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDays(Duration d) {
    return (d.inDays + (d > Duration.zero ? 1 : 0)).toString();
  }

  @override
  Widget build(BuildContext context) {
    final days = _formatDays(_remaining);

    // Detecta se é mobile (largura <= 600)
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return Scaffold(
      body: Stack(
        children: [
          // Background sky image
          Positioned.fill(
            child: Image.asset(
              'assets/ceu.png',
              fit: BoxFit.cover,
            ),
          ),

          // Imagem esquerda (mobile: ocupa 80% largura, desktop: 45%) - agora animada
          AnimatedBuilder(
            animation: _imgController,
            builder: (context, child) {
              if (isMobile) {
                return Positioned(
                  left: _leftAnim.value,
                  top: 0,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Image.asset(
                      'assets/esquerda.png',
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              } else {
                return Stack(
                  children: [
                    // Esquerda vai para a direita (_leftAnim.value: 0 -> +30)
                    Positioned(
                      left: _leftAnim.value,
                      top: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: Image.asset(
                          'assets/esquerda.png',
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Direita vai para a esquerda (_rightAnim.value: 0 -> +30, mas usamos -_rightAnim.value)
                    Positioned(
                      right: _rightAnim.value,
                      top: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: Image.asset(
                          'assets/direita.png',
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          // Center content with a stripe behind
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                // Decorative stripe
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // stripe
                    Container(
                      width: MediaQuery.of(context).size.width, // ocupa toda a largura da página
                      // constraints removido para não limitar a largura
                      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5ECD6).withOpacity(0.5), // cor de pergaminho
                        // borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.16),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 8,
                          children: [
                            Text(
                              'Faltam\u00A0',
                              style: TextStyle(
                                color: const Color(0xFF072033),
                                fontWeight: FontWeight.w700,
                                fontSize: MediaQuery.of(context).size.width < 420 ? 36 : 64,
                                fontFamily: 'MedievalSharp',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              days,
                              key: const Key('days'),
                              style: TextStyle(
                                color: const Color(0xFF072033),
                                fontWeight: FontWeight.w900,
                                fontSize: MediaQuery.of(context).size.width < 420 ? 36 : 64,
                                height: 1,
                                fontFamily: 'MedievalSharp',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'dias para o fim do CFP',
                              style: TextStyle(
                                color: const Color(0xFF072033),
                                fontWeight: FontWeight.w700,
                                fontSize: MediaQuery.of(context).size.width < 420 ? 36 : 64,
                                fontFamily: 'MedievalSharp',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  _remaining == Duration.zero ? 'O CFP já terminou' : '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Bebê GIF no canto inferior direito, aparece/some conforme _showBebe
          if (_showBebe)
            Positioned(
              right: 30,
              bottom: 15, // espaço para não sobrepor o botão
              child: IgnorePointer(
                ignoring: true,
                child: Image.asset(
                  'assets/bebe.gif',
                  height: MediaQuery.of(context).size.height * 0.40,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // Botão com ícone de buzina no canto inferior direito
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  _showBebe = !_showBebe;
                });
                if (!_showBebe) {
                  await _audioPlayer.stop();
                } else {
                  await _audioPlayer.setReleaseMode(ReleaseMode.loop);
                  await _audioPlayer.setVolume(0.1);
                  await _audioPlayer.play(AssetSource('corneta.mp3'));
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              splashColor: Colors.transparent,
              highlightElevation: 0,
              child: const Icon(Icons.campaign, color: Colors.grey, size: 32), // Ícone de buzina
            ),
          ),
        ],
      ),
    );
  }
}
