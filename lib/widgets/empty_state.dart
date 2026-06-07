import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Estado vacío reutilizable: badge con icono sobre tinte primary, título,
/// descripción y un CTA primary. Se centra verticalmente en el alto
/// disponible y es scrollable, así sigue funcionando el pull-to-refresh
/// cuando se monta dentro de un [RefreshIndicator].
class FzEmptyState extends StatelessWidget {
  const FzEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onCta,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: FzColors.primarySoft,
                      borderRadius: BorderRadius.circular(FzRadius.xxl),
                      border: Border.all(color: FzColors.borderPaid),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 32, color: FzColors.primaryHi),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: FzType.sans,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: FzColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: FzType.sans,
                      fontSize: 13,
                      color: FzColors.textDim,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(FzRadius.lg),
                      boxShadow: FzShadow.ctaPrimary,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onCta,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(ctaLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
