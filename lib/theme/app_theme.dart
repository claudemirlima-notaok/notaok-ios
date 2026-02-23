import 'package:flutter/material.dart';

/// Tema padronizado do NotaOK
/// Todas as telas devem usar estas configurações para manter consistência visual
class AppTheme {
  // Cores principais (roxo e laranja)
  static const Color primaryColor = Color(0xFF9C27B0); // Roxo
  static const Color secondaryColor = Color(0xFFFF6F00); // Laranja
  
  // Gradiente padrão (roxo → laranja)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente suave para backgrounds
  static LinearGradient softGradient(BuildContext context) {
    return LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // AppBar padrão com gradiente
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    bool centerTitle = false,
    bool showLogo = true,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: centerTitle,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: softGradient(context),
        ),
      ),
      actions: [
        if (showLogo)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logos/logo_notaok_final.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (actions != null) ...actions,
      ],
    );
  }

  // SliverAppBar padrão com gradiente e expansão
  static SliverAppBar buildSliverAppBar({
    required BuildContext context,
    required String title,
    double expandedHeight = 120,
    List<Widget>? actions,
    bool floating = false,
    bool pinned = true,
    bool showLogo = true,
  }) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      actions: showLogo
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/logos/logo_notaok_final.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (actions != null) ...actions,
            ]
          : actions,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: softGradient(context),
          ),
        ),
      ),
    );
  }

  // Card padrão com design consistente
  static Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: child,
            )
          : child,
    );
  }

  // Container com ícone padronizado
  static Widget buildIconContainer({
    required BuildContext context,
    required IconData icon,
    double size = 60,
    double iconSize = 32,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: iconSize,
      ),
    );
  }

  // Estado vazio padronizado
  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action,
          ],
        ],
      ),
    );
  }

  // FloatingActionButton padronizado
  static Widget buildFAB({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  // Título de seção padronizado
  static Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ListTile com ícone padronizado (para perfil e configurações)
  static Widget buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // BottomNavigationBar padronizado com gradiente
  static Widget buildBottomNavigationBar({
    required BuildContext context,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: softGradient(context),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Garantias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Notas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_rounded),
            label: 'Comprovantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Escanear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // Estilos de texto padronizados
  static const TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  );

  static TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey[500],
  );

  // Tema Material do app
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.purple,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
