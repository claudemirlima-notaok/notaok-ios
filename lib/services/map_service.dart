import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../models/comprovante.dart';

/// Serviço para operações de mapa e geolocalização
class MapService {
  /// Abre o mapa no Google Maps ou Apple Maps com a localização do comprovante
  static Future<void> abrirLocalizacaoNoMapa({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? nomeLocal,
  }) async {
    try {
      final url = _construirUrlMapa(
        latitude: latitude,
        longitude: longitude,
        nomeLocal: nomeLocal,
      );

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _mostrarErroMapa(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarErroMapa(context);
      }
    }
  }

  /// Constrói URL do mapa baseado na plataforma
  static String _construirUrlMapa({
    required double latitude,
    required double longitude,
    String? nomeLocal,
  }) {
    // Detectar plataforma (iOS usa Apple Maps, outros usam Google Maps)
    try {
      if (Platform.isIOS) {
        // Apple Maps (iOS)
        // Formato: https://maps.apple.com/?q=Nome&ll=lat,long
        if (nomeLocal != null && nomeLocal.isNotEmpty) {
          final nomeEncoded = Uri.encodeComponent(nomeLocal);
          return 'https://maps.apple.com/?q=$nomeEncoded&ll=$latitude,$longitude';
        } else {
          return 'https://maps.apple.com/?ll=$latitude,$longitude';
        }
      } else {
        // Google Maps (Android e outros)
        // Formato: https://www.google.com/maps/search/?api=1&query=lat,long
        if (nomeLocal != null && nomeLocal.isNotEmpty) {
          final nomeEncoded = Uri.encodeComponent(nomeLocal);
          return 'https://www.google.com/maps/search/?api=1&query=$nomeEncoded&query=$latitude,$longitude';
        } else {
          return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
        }
      }
    } catch (e) {
      // Fallback para Google Maps se houver erro ao detectar plataforma
      return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }
  }

  /// Mostra dialog com preview do mapa antes de abrir
  static Future<void> mostrarDialogMapa({
    required BuildContext context,
    required Comprovante comprovante,
  }) async {
    if (!comprovante.temLocalizacao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Este comprovante não possui localização GPS'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Localização'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estabelecimento
              if (comprovante.estabelecimento != null) ...[
                _buildInfoRow(
                  icon: Icons.store,
                  label: 'Estabelecimento',
                  value: comprovante.estabelecimento!,
                ),
                const SizedBox(height: 12),
              ],

              // Cidade e Estado
              if (comprovante.cidade != null || comprovante.estado != null) ...[
                _buildInfoRow(
                  icon: Icons.location_city,
                  label: 'Localização',
                  value: comprovante.localizacaoFormatada,
                ),
                const SizedBox(height: 12),
              ],

              // Endereço completo (se disponível)
              if (comprovante.enderecoCaptura != null) ...[
                _buildInfoRow(
                  icon: Icons.place,
                  label: 'Endereço',
                  value: comprovante.enderecoCaptura!,
                ),
                const SizedBox(height: 12),
              ],

              // Coordenadas GPS
              _buildInfoRow(
                icon: Icons.gps_fixed,
                label: 'Coordenadas',
                value: '${comprovante.latitude!.toStringAsFixed(6)}, ${comprovante.longitude!.toStringAsFixed(6)}',
              ),

              const SizedBox(height: 16),

              // Preview do mapa (ícone ilustrativo)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.location_on,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Aviso
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Abrirá o mapa do seu dispositivo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              abrirLocalizacaoNoMapa(
                context: context,
                latitude: comprovante.latitude!,
                longitude: comprovante.longitude!,
                nomeLocal: comprovante.estabelecimento,
              );
            },
            icon: const Icon(Icons.map),
            label: const Text('Abrir Mapa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper para exibir informações
  static Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mostra mensagem de erro
  static void _mostrarErroMapa(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Não foi possível abrir o mapa'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Widget de botão de mapa estilizado
  static Widget buildMapButton({
    required BuildContext context,
    required Comprovante comprovante,
    bool compact = false,
  }) {
    if (!comprovante.temLocalizacao) {
      return const SizedBox.shrink();
    }

    if (compact) {
      // Versão compacta (apenas ícone)
      return IconButton(
        onPressed: () => mostrarDialogMapa(
          context: context,
          comprovante: comprovante,
        ),
        icon: Icon(
          Icons.location_on,
          color: Theme.of(context).colorScheme.primary,
        ),
        tooltip: 'Ver no mapa',
      );
    } else {
      // Versão expandida (ícone + texto)
      return OutlinedButton.icon(
        onPressed: () => mostrarDialogMapa(
          context: context,
          comprovante: comprovante,
        ),
        icon: const Icon(Icons.map_outlined),
        label: Text(comprovante.localizacaoFormatada),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  /// Widget de badge de localização para cards
  static Widget buildLocationBadge({
    required BuildContext context,
    required Comprovante comprovante,
    VoidCallback? onTap,
  }) {
    if (!comprovante.temLocalizacao) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap ?? () => mostrarDialogMapa(
        context: context,
        comprovante: comprovante,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              comprovante.localizacaoFormatada,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.open_in_new,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// Calcula distância entre duas coordenadas (em km)
  /// Usando fórmula de Haversine
  static double calcularDistancia({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const R = 6371; // Raio da Terra em km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  // Funções matemáticas helpers
  static double _toRadians(double degrees) => degrees * (3.141592653589793 / 180);
  static double _sin(double x) => _dartSin(x);
  static double _cos(double x) => _dartCos(x);
  static double _sqrt(double x) => _dartSqrt(x);
  static double _atan2(double y, double x) => _dartAtan2(y, x);

  // Importar funções matemáticas do Dart
  static double _dartSin(double x) {
    // Implementação simplificada da série de Taylor para sin(x)
    double result = x;
    double term = x;
    for (int n = 1; n < 10; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  static double _dartCos(double x) {
    // Implementação simplificada da série de Taylor para cos(x)
    double result = 1;
    double term = 1;
    for (int n = 1; n < 10; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      result += term;
    }
    return result;
  }

  static double _dartSqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    
    // Método de Newton-Raphson
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _dartAtan2(double y, double x) {
    // Implementação simplificada de atan2
    if (x > 0) {
      return _dartAtan(y / x);
    } else if (x < 0 && y >= 0) {
      return _dartAtan(y / x) + 3.141592653589793;
    } else if (x < 0 && y < 0) {
      return _dartAtan(y / x) - 3.141592653589793;
    } else if (x == 0 && y > 0) {
      return 3.141592653589793 / 2;
    } else if (x == 0 && y < 0) {
      return -3.141592653589793 / 2;
    } else {
      return 0; // x == 0 && y == 0
    }
  }

  static double _dartAtan(double x) {
    // Implementação simplificada da série de Taylor para atan(x)
    if (x.abs() > 1) {
      return (x > 0 ? 3.141592653589793 / 2 : -3.141592653589793 / 2) - _dartAtan(1 / x);
    }
    double result = x;
    double term = x;
    for (int n = 1; n < 10; n++) {
      term *= -x * x * (2 * n - 1) / (2 * n + 1);
      result += term;
    }
    return result;
  }
}
