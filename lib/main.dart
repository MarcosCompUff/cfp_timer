import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador até 14/11/2025',
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
    _leftAnim = Tween<double>(begin: -15, end: 35).animate(
      CurvedAnimation(parent: _imgController, curve: Curves.easeInOut),
    );
    _rightAnim = Tween<double>(begin: -15, end: 35).animate(
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
    super.dispose();
  }

  String _formatDays(Duration d) {
    return d.inDays.toString();
  }

  @override
  Widget build(BuildContext context) {
    final days = _formatDays(_remaining);

    // Detecta se é mobile (largura <= 600)
    final isMobile = MediaQuery.of(context).size.width <= 1400;

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
                SizedBox(height: MediaQuery.of(context).size.height * 0.30), // Move a faixa 25% para baixo do centro
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

          // // Corner GIF
          // Positioned(
          //   right: 100,
          //   bottom: 15,
          //   child: IgnorePointer(
          //     ignoring: true,
          //     child: Image.asset(
          //       'assets/bebe.gif',
          //       height: MediaQuery.of(context).size.height * 0.40,
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
