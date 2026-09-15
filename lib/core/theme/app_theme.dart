import 'package:flutter/material.dart';

/// Azul de marca (el mismo del logo/ícono de la app), usado como semilla del
/// esquema de colores en vez del lila genérico que trae Material por
/// defecto. Al ser la "seed", también define el tinte de superficies
/// (cards, appbar, etc.), así que este solo cambio ya le da consistencia de
/// marca a toda la app.
const _brandSeed = Color(0xFF2F6FEB);

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return _base(
      ColorScheme.fromSeed(seedColor: _brandSeed).copyWith(primary: _brandSeed, onPrimary: Colors.white),
    );
  }

  static ThemeData dark() {
    // En modo oscuro, Material aclara automáticamente el color "primary"
    // (por accesibilidad), pero eso lo hacía ver pálido y no como el azul
    // vivo de la marca. Lo forzamos al azul real en los dos modos.
    return _base(
      ColorScheme.fromSeed(seedColor: _brandSeed, brightness: Brightness.dark)
          .copyWith(primary: _brandSeed, onPrimary: Colors.white),
    );
  }

  static ThemeData _base(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );
  }
}
