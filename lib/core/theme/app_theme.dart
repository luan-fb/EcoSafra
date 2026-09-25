import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Temas claro e escuro do EcoSafra (Material 3).
///
/// Vindo do Android nativo: pense nisto como o `themes.xml` + `styles.xml`,
/// só que tipado e sem XML. `ThemeData` desce pela árvore de widgets via
/// `InheritedWidget`, então qualquer widget chama `Theme.of(context)` e pega
/// as cores e tipografia certas do momento.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // A partir de uma cor semente o Material 3 deriva uma paleta acessível
    // inteira (contraste garantido). Depois sobrescrevemos o que importa.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? AppColors.primaryLight : AppColors.primary,
      secondary: isDark ? AppColors.secondaryLight : AppColors.secondary,
      error: AppColors.danger,
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    );

    final textTheme = _textTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      splashFactory: InkSparkle.splashFactory,

      // Transição padrão de página em todas as plataformas.
      // O go_router usa isto quando não definimos uma transição customizada.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),

      // Altura mínima de 52, largura mínima de 64. `Size.fromHeight` daria
      // largura mínima infinita e quebraria qualquer botão dentro de uma
      // `Row` ou das ações de um diálogo; quem quer largura cheia pede com
      // `SizedBox(width: double.infinity)` ou coluna em `stretch`.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppSpacing.radiusMd),
            ),
          ),
          textStyle: textTheme.labelLarge,
          animationDuration: AppMotion.fast,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppSpacing.radiusMd),
            ),
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        // Campo preenchido pede `UnderlineInputBorder`: com
        // `OutlineInputBorder`, o rótulo flutuante é desenhado sobre a linha
        // da borda de cima, metade para fora da caixa preenchida.
        border: const UnderlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
          borderSide: BorderSide.none,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    // Manrope nos títulos (geométrica, moderna) + Inter no corpo (legível em
    // tela pequena e sob sol forte, que é o contexto do produtor no campo).
    final base = GoogleFonts.interTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return base.copyWith(
      displayLarge: GoogleFonts.manrope(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      headlineMedium: GoogleFonts.manrope(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.manrope(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w700,
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
