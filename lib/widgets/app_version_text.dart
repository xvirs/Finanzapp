import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Muestra la versión real de la app — leída del paquete (que la toma de
/// `pubspec.yaml`) — formateada por [builder]. Evita hardcodear el número
/// en cada pantalla, así no se desincroniza al bumpear la versión.
///
/// Mientras carga muestra un texto vacío (con el mismo estilo) para no
/// pegar un salto de layout ni mostrar una versión incompleta.
class AppVersionText extends StatelessWidget {
  const AppVersionText({
    required this.builder,
    this.style,
    this.textAlign,
    super.key,
  });

  /// Recibe la versión (ej. "1.1.0") y devuelve el string a mostrar.
  final String Function(String version) builder;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        return Text(
          version == null ? '' : builder(version),
          textAlign: textAlign,
          style: style,
        );
      },
    );
  }
}
