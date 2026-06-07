import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/tokens.dart';

/// Caplabel mono uppercase + asterisco rojo si required — para labels
/// arriba de inputs (patrón ACField del handoff).
class FormCaplabel extends StatelessWidget {
  const FormCaplabel({required this.text, this.required = false, super.key});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: text.toUpperCase()),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: FzColors.lateColor),
              ),
          ],
        ),
        style: const TextStyle(
          fontFamily: FzType.mono,
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.63,
          color: FzColors.textMute,
        ),
      ),
    );
  }
}

/// Layout vertical: caplabel arriba + child input debajo + hint italic
/// opcional debajo del input (patrón ACField del handoff).
class FormFieldWrap extends StatelessWidget {
  const FormFieldWrap({
    required this.label,
    required this.child,
    this.required = false,
    this.hint,
    super.key,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormCaplabel(text: label, required: required),
        child,
        if (hint != null) ...[
          const SizedBox(height: 5),
          Text(
            hint!,
            style: const TextStyle(
              fontFamily: FzType.sans,
              fontSize: 11,
              color: FzColors.textMute,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Container con el styling de input "card" del handoff. Usar como
/// base para inputs custom (date pickers, dropdowns) que NO sean
/// TextFormField.
class FormFieldShell extends StatelessWidget {
  const FormFieldShell({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        border: Border.all(color: FzColors.border),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        child: box,
      ),
    );
  }
}

/// TextFormField con el styling del handoff (card bg, border, mono font
/// si [mono]=true, prefix/suffix opcionales). Wrap en [FormFieldWrap]
/// para sumar el caplabel.
class FormTextField extends StatelessWidget {
  const FormTextField({
    required this.controller,
    this.hint,
    this.prefix,
    this.suffix,
    this.mono = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final bool mono;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<dynamic>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: mono ? FzType.mono : FzType.sans,
      fontSize: 14,
      fontWeight: mono ? FontWeight.w500 : FontWeight.w400,
      color: FzColors.text,
      fontFeatures: mono ? FzType.tabularNums : null,
    );

    final hintStyle = TextStyle(
      fontFamily: mono ? FzType.mono : FzType.sans,
      fontSize: 14,
      color: FzColors.textMute,
    );

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters?.cast<TextInputFormatter>(),
      validator: validator,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: textStyle,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: hintStyle,
        prefixText: prefix,
        prefixStyle: TextStyle(
          fontFamily: FzType.mono,
          fontSize: 14,
          color: FzColors.textMute,
          fontFeatures: const [],
        ),
        suffixText: suffix,
        suffixStyle: const TextStyle(
          fontFamily: FzType.mono,
          fontSize: 12,
          color: FzColors.textMute,
        ),
      ),
    );
  }
}

/// Toggle "Activa" estilo handoff: card wrapper con título + sub +
/// switch a la derecha. El switch es el de Material (theme custom).
class FormActiveToggle extends StatelessWidget {
  const FormActiveToggle({
    required this.value,
    required this.onChanged,
    this.title = 'Activa',
    this.subtitleOn = 'Aparece en Mes y Tarjetas',
    this.subtitleOff = 'Está oculta',
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitleOn;
  final String subtitleOff;

  @override
  Widget build(BuildContext context) {
    return FormFieldShell(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FzColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ? subtitleOn : subtitleOff,
                  style: const TextStyle(
                    fontFamily: FzType.sans,
                    fontSize: 11.5,
                    color: FzColors.textMute,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Botón primary "Guardar" con icono floppy + sombra primary.
class FormSaveButton extends StatelessWidget {
  const FormSaveButton({
    required this.label,
    required this.loading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FzRadius.lg),
          boxShadow: disabled ? null : FzShadow.ctaPrimary,
        ),
        child: ElevatedButton.icon(
          onPressed: disabled ? null : onPressed,
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(FzColors.primaryInk),
                  ),
                )
              : const Icon(Icons.save_outlined, size: 16),
          label: Text(label),
        ),
      ),
    );
  }
}

/// Cabecera "Más opciones" con chevron que rota y contenido que se
/// despliega con animación de alto + fade. Para esconder campos avanzados
/// de un formulario y no abrumar (progressive disclosure).
class FormMoreOptions extends StatelessWidget {
  const FormMoreOptions({
    required this.expanded,
    required this.onToggle,
    required this.children,
    this.label = 'Más opciones',
    super.key,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(FzRadius.lg),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(FzRadius.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: FzType.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: FzColors.primaryHi,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: FzMotion.normal,
                    curve: FzMotion.easing,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: FzColors.primaryHi,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: FzMotion.normal,
            curve: FzMotion.easing,
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              opacity: expanded ? 1 : 0,
              duration: FzMotion.fast,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ),
      ],
    );
  }
}

/// Control segmentado full-width para elegir entre opciones mutuamente
/// excluyentes sin abrir un sheet (ej: frecuencia "Todos los meses / Una
/// sola vez"). El segmento activo se resalta con una transición de color.
class FormSegmented extends StatelessWidget {
  const FormSegmented({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FzColors.card,
        borderRadius: BorderRadius.circular(FzRadius.lg),
        border: Border.all(color: FzColors.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: _Segment(
                label: options[i],
                selected: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.md),
        child: AnimatedContainer(
          duration: FzMotion.fast,
          curve: FzMotion.easing,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? FzColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(FzRadius.md),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FzType.sans,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? FzColors.primaryInk : FzColors.textDim,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip de selección (icono + label) en forma de pill, con transición de
/// color al seleccionarse. Pensado para usarse en un [Wrap] como selector
/// de categoría inline (1 tap, sin bottom sheet).
class FormChoiceChip extends StatelessWidget {
  const FormChoiceChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FzRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FzRadius.pill),
        child: AnimatedContainer(
          duration: FzMotion.fast,
          curve: FzMotion.easing,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? FzColors.primary : FzColors.card,
            borderRadius: BorderRadius.circular(FzRadius.pill),
            border: Border.all(
              color: selected ? FzColors.primary : FzColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? FzColors.primaryInk : FzColors.textDim,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FzType.sans,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? FzColors.primaryInk : FzColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón danger outline "Eliminar" con icono trash.
class FormDeleteButton extends StatelessWidget {
  const FormDeleteButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: FzColors.lateColor,
          side: const BorderSide(color: FzColors.borderLate),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FzRadius.lg),
          ),
        ),
        icon: const Icon(
          Icons.delete_outline_rounded,
          size: 15,
          color: FzColors.lateColor,
        ),
        label: Text(label),
      ),
    );
  }
}
