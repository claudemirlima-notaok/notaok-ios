import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class IOSVersionCheckScreen extends StatefulWidget {
  final Widget child;
  
  const IOSVersionCheckScreen({
    super.key,
    required this.child,
  });

  @override
  State<IOSVersionCheckScreen> createState() => _IOSVersionCheckScreenState();
}

class _IOSVersionCheckScreenState extends State<IOSVersionCheckScreen> {
  bool _isCompatible = true;
  String _iosVersion = '';

  @override
  void initState() {
    super.initState();
    _checkIOSVersion();
  }

  Future<void> _checkIOSVersion() async {
    if (!Platform.isIOS) {
      setState(() {
        _isCompatible = true;
      });
      return;
    }

    try {
      final version = Platform.operatingSystemVersion;
      final versionMatch = RegExp(r'Version (\d+)\.(\d+)').firstMatch(version);
      
      if (versionMatch != null) {
        final major = int.parse(versionMatch.group(1)!);
        final minor = int.parse(versionMatch.group(2)!);
        _iosVersion = '$major.$minor';
        
        setState(() {
          _isCompatible = major >= 16;
        });
      }
    } catch (e) {
      setState(() {
        _isCompatible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompatible) {
      return widget.child;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0),
          primary: const Color(0xFF9C27B0),
          secondary: const Color(0xFFFF6F00),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9C27B0),
                const Color(0xFFFF6F00),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.system_update_alt,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Atualização Necessária',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'iOS $_iosVersion detectado',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: Colors.orangeAccent,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'O NotaOK requer iOS 16.0 ou superior para funcionar corretamente.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Por favor, atualize seu dispositivo para continuar usando o app.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Fechar App'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF9C27B0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Como atualizar:\nAjustes → Geral → Atualização de Software',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
