import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

/// Serviço para capturar informações do dispositivo e do app
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  /// Obtém todas as informações do dispositivo e do app
  static Future<Map<String, dynamic>> obterInformacoesCompletas() async {
    try {
      final deviceData = await _obterInfoDispositivo();
      final appData = await _obterInfoApp();
      
      return {
        'dispositivo': deviceData,
        'app': appData,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao obter informações: $e');
      }
      return {};
    }
  }
  
  /// Obtém informações do dispositivo (celular)
  static Future<Map<String, dynamic>> _obterInfoDispositivo() async {
    final dados = <String, dynamic>{};
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        
        dados['plataforma'] = 'Android';
        dados['marca'] = androidInfo.brand; // Samsung, Xiaomi, Motorola, etc
        dados['modelo'] = androidInfo.model; // Galaxy S23, Redmi Note 12, etc
        dados['fabricante'] = androidInfo.manufacturer; // samsung, xiaomi, motorola
        dados['versaoAndroid'] = androidInfo.version.release; // 13, 14, etc
        dados['versaoSDK'] = androidInfo.version.sdkInt; // 33, 34, etc
        dados['dispositivo'] = androidInfo.device; // Nome técnico do dispositivo
        dados['produto'] = androidInfo.product; // Nome do produto
        dados['hardware'] = androidInfo.hardware; // Chipset
        dados['nome'] = androidInfo.display; // Nome de exibição
        dados['fingerprint'] = androidInfo.fingerprint; // Build fingerprint
        dados['id'] = androidInfo.id; // Build ID
        dados['isPhysicalDevice'] = androidInfo.isPhysicalDevice; // true/false
        dados['androidId'] = androidInfo.id; // Android ID único
        
        // Informações de suporte
        dados['supportedAbis'] = androidInfo.supportedAbis; // Arquiteturas suportadas
        dados['supported32BitAbis'] = androidInfo.supported32BitAbis;
        dados['supported64BitAbis'] = androidInfo.supported64BitAbis;
        
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        
        dados['plataforma'] = 'iOS';
        dados['modelo'] = iosInfo.model; // iPhone, iPad
        dados['nome'] = iosInfo.name; // "iPhone de João"
        dados['sistemaNome'] = iosInfo.systemName; // iOS
        dados['versaoSistema'] = iosInfo.systemVersion; // 17.1, 16.5, etc
        dados['localizedModel'] = iosInfo.localizedModel; // iPhone localizado
        dados['utsname'] = iosInfo.utsname.machine; // iPhone15,2
        dados['identifierForVendor'] = iosInfo.identifierForVendor; // UUID único
        dados['isPhysicalDevice'] = iosInfo.isPhysicalDevice; // true/false
        
      } else {
        dados['plataforma'] = 'Desconhecida';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao obter info do dispositivo: $e');
      }
    }
    
    return dados;
  }
  
  /// Obtém informações do aplicativo
  static Future<Map<String, dynamic>> _obterInfoApp() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      return {
        'nomeApp': packageInfo.appName, // Warranty Wizard
        'packageName': packageInfo.packageName, // com.warrantywizard.warranty
        'versao': packageInfo.version, // 1.0.0
        'buildNumber': packageInfo.buildNumber, // 1
        'buildSignature': packageInfo.buildSignature, // Assinatura do build
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao obter info do app: $e');
      }
      return {};
    }
  }
  
  /// Retorna string formatada com as informações principais
  static Future<String> obterResumoFormatado() async {
    final info = await obterInformacoesCompletas();
    
    if (info.isEmpty) return 'Informações não disponíveis';
    
    final dispositivo = info['dispositivo'] as Map<String, dynamic>?;
    final app = info['app'] as Map<String, dynamic>?;
    
    final buffer = StringBuffer();
    
    // Informações do App
    if (app != null) {
      buffer.writeln('📱 APP');
      buffer.writeln('Nome: ${app['nomeApp']}');
      buffer.writeln('Versão: ${app['versao']} (${app['buildNumber']})');
      buffer.writeln('Package: ${app['packageName']}');
      buffer.writeln();
    }
    
    // Informações do Dispositivo
    if (dispositivo != null) {
      buffer.writeln('📲 DISPOSITIVO');
      buffer.writeln('Plataforma: ${dispositivo['plataforma']}');
      
      if (dispositivo['plataforma'] == 'Android') {
        buffer.writeln('Marca: ${dispositivo['marca']}');
        buffer.writeln('Modelo: ${dispositivo['modelo']}');
        buffer.writeln('Fabricante: ${dispositivo['fabricante']}');
        buffer.writeln('Android: ${dispositivo['versaoAndroid']} (SDK ${dispositivo['versaoSDK']})');
        buffer.writeln('Hardware: ${dispositivo['hardware']}');
        buffer.writeln('Físico: ${dispositivo['isPhysicalDevice'] ? "Sim" : "Emulador"}');
      } else if (dispositivo['plataforma'] == 'iOS') {
        buffer.writeln('Modelo: ${dispositivo['modelo']}');
        buffer.writeln('Nome: ${dispositivo['nome']}');
        buffer.writeln('Sistema: ${dispositivo['sistemaNome']} ${dispositivo['versaoSistema']}');
        buffer.writeln('Físico: ${dispositivo['isPhysicalDevice'] ? "Sim" : "Simulador"}');
      }
    }
    
    return buffer.toString();
  }
  
  /// Retorna informações resumidas em uma linha
  static Future<String> obterResumoUmaLinha() async {
    final info = await obterInformacoesCompletas();
    final dispositivo = info['dispositivo'] as Map<String, dynamic>?;
    
    if (dispositivo == null) return 'Dispositivo desconhecido';
    
    if (dispositivo['plataforma'] == 'Android') {
      return '${dispositivo['marca']} ${dispositivo['modelo']} - Android ${dispositivo['versaoAndroid']}';
    } else if (dispositivo['plataforma'] == 'iOS') {
      return '${dispositivo['modelo']} - ${dispositivo['sistemaNome']} ${dispositivo['versaoSistema']}';
    }
    
    return 'Dispositivo desconhecido';
  }
  
  /// Salva informações do dispositivo no Firestore (para analytics)
  static Future<void> salvarInfoFirestore({
    required String userId,
    required dynamic firestoreInstance,
  }) async {
    try {
      final info = await obterInformacoesCompletas();
      
      // Adicionar informações extras
      info['userId'] = userId;
      info['timestamp'] = DateTime.now();
      
      // Salvar no Firestore
      await firestoreInstance
          .collection('device_info')
          .doc(userId)
          .set(info, SetOptions(merge: true));
      
      if (kDebugMode) {
        debugPrint('✅ Informações do dispositivo salvas no Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao salvar info no Firestore: $e');
      }
    }
  }
  
  /// Verifica se o dispositivo atende aos requisitos mínimos
  static Future<bool> verificarRequisitosMinimos() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Requisito: Android 6.0 (SDK 23) ou superior
        return androidInfo.version.sdkInt >= 23;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // Requisito: iOS 12.0 ou superior
        final versaoMaior = int.tryParse(iosInfo.systemVersion.split('.').first) ?? 0;
        return versaoMaior >= 12;
      }
      return true;
    } catch (e) {
      return true; // Assume que atende em caso de erro
    }
  }
}
