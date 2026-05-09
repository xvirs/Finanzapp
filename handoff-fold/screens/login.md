# Login · adaptativo

## Compact (<600 dp)

Sin cambios. Lo que ya está en producción.

## Expanded (600–1023 dp · Fold inner)

Split horizontal 50/50:

**Brand panel** (izq):
- Logo 44 + "Finanzapp v2.0"
- H1 44px "Ordenados. A tiempo. Sin olvidos." (segunda línea atenuada)
- Lead 14.5px, max-width 380
- 3 features con icon: vista del mes / marcá pagado en un toque / bloqueo biométrico
- Footer mono FINANZAPP.APP · ©2026 · HECHO EN ARGENTINA

**Form panel** (der, ~380dp):
- Eyebrow `INICIAR SESIÓN` mono uppercase
- H1 28px "Bienvenido de vuelta"
- Botón Google blanco (Material outlined-look)
- Divider "o por email"
- TextField email con label flotante notched
- Botón primary "Enviarme el link" + arrow icon
- Términos centrados text-mute

Halos radiales decorativos top-left y bottom-right.

## Desktop (≥1024 dp)

Mismo split pero más generoso:
- Brand panel padding 56×64, H1 56px, features con icon 40, lead 460 max-width
- Form panel width fijo 480, padding 56
- Subtext en form: "Ingresá con tu cuenta de Google o pedimos un magic link"
- Footer absoluto bottom: `LOGIN SEGURO · TLS 1.3` + status dot verde "EN LÍNEA"

## Estados

Iguales en los 3 formatos:
- `loading` → CTA con spinner + "Enviando..."
- `link enviado` → reemplazar form por card success: check verde + "Revisá tu email" + email + "Reenviar (60s)"
- `email inválido` → border rojo + helper text 12px
- `error Google` → snackbar rojo

## Componentes Flutter sugeridos

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AdaptiveScaffold(
    compact: (_) => _CompactLogin(),
    expanded: (_) => _SplitLogin(brandPadding: const EdgeInsets.all(44), formWidth: 380),
    desktop:  (_) => _SplitLogin(brandPadding: const EdgeInsets.fromLTRB(64,56,64,56), formWidth: 480),
  );
}
```

`_SplitLogin` reutiliza `_GoogleButton`, `_EmailField`, `_PrimaryCTA` que ya existen en el compact.
