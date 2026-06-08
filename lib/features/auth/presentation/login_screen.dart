import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/responsive.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../../widgets/app_version_text.dart';
import 'bloc/auth_bloc.dart';

/// Pantalla 1 — Login.
/// Port pixel-perfect del JSX `ALogin` (handoff/screens-a.jsx).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _emailHasContent = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      final has = _emailController.text.trim().isNotEmpty;
      if (has != _emailHasContent) {
        setState(() => _emailHasContent = has);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitMagicLink() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresá un email válido.')));
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(AuthMagicLinkRequested(email));
  }

  void _submitGoogle() {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  void _submitApple() {
    context.read<AuthBloc>().add(const AuthAppleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthBlocState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.actionStatus == AuthActionStatus.failure &&
            state.errorMessage != null) {
          messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.actionStatus == AuthActionStatus.success &&
            state.lastMagicLinkEmail != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Te mandamos un link a ${state.lastMagicLinkEmail}',
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.actionStatus == AuthActionStatus.loading;
        return Scaffold(
          backgroundColor: FzColors.bg,
          body: Stack(
            children: [
              const _RadialHalo(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final factor = constraints.formFactor;
                    if (factor == FormFactor.compact) {
                      return _CompactLogin(
                        emailController: _emailController,
                        emailHasContent: _emailHasContent,
                        isLoading: isLoading,
                        onSubmitGoogle: _submitGoogle,
                        onSubmitApple: _submitApple,
                        onSubmitMagicLink: _submitMagicLink,
                      );
                    }
                    return _SplitLogin(
                      emailController: _emailController,
                      emailHasContent: _emailHasContent,
                      isLoading: isLoading,
                      onSubmitGoogle: _submitGoogle,
                      onSubmitApple: _submitApple,
                      onSubmitMagicLink: _submitMagicLink,
                      formWidth: factor == FormFactor.desktop ? 480 : 380,
                      brandPadding: factor == FormFactor.desktop
                          ? const EdgeInsets.fromLTRB(64, 56, 48, 56)
                          : const EdgeInsets.all(40),
                      logoSize: factor == FormFactor.desktop ? 96 : 80,
                      titleSize: factor == FormFactor.desktop ? 56 : 44,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Layout compact (mobile): logo + título + tagline + form de auth todo
/// stackeado y centrado. Es lo que ya estaba en producción.
class _CompactLogin extends StatelessWidget {
  const _CompactLogin({
    required this.emailController,
    required this.emailHasContent,
    required this.isLoading,
    required this.onSubmitGoogle,
    required this.onSubmitApple,
    required this.onSubmitMagicLink,
  });

  final TextEditingController emailController;
  final bool emailHasContent;
  final bool isLoading;
  final VoidCallback onSubmitGoogle;
  final VoidCallback onSubmitApple;
  final VoidCallback onSubmitMagicLink;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(child: FzLogo(size: 64, shadow: true)),
              const SizedBox(height: 28),
              Text(
                'Finanzapp',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.75,
                  color: FzColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tus pagos del mes, ordenados.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: FzColors.textDim,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 44),
              _AuthForm(
                emailController: emailController,
                emailHasContent: emailHasContent,
                isLoading: isLoading,
                onSubmitGoogle: onSubmitGoogle,
                onSubmitApple: onSubmitApple,
                onSubmitMagicLink: onSubmitMagicLink,
              ),
              const SizedBox(height: 28),
              AppVersionText(
                textAlign: TextAlign.center,
                builder: (v) => 'v$v · finanzapp.app',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11.5,
                  letterSpacing: 0.46,
                  color: FzColors.textMute,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Layout expanded/desktop: panel de marca a la izquierda + form a la
/// derecha. Reusa los mismos botones/inputs que [_CompactLogin].
class _SplitLogin extends StatelessWidget {
  const _SplitLogin({
    required this.emailController,
    required this.emailHasContent,
    required this.isLoading,
    required this.onSubmitGoogle,
    required this.onSubmitApple,
    required this.onSubmitMagicLink,
    required this.formWidth,
    required this.brandPadding,
    required this.logoSize,
    required this.titleSize,
  });

  final TextEditingController emailController;
  final bool emailHasContent;
  final bool isLoading;
  final VoidCallback onSubmitGoogle;
  final VoidCallback onSubmitApple;
  final VoidCallback onSubmitMagicLink;
  final double formWidth;
  final EdgeInsetsGeometry brandPadding;
  final double logoSize;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Panel de marca (izquierda)
        Expanded(
          child: SingleChildScrollView(
            padding: brandPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FzLogo(size: logoSize, shadow: true),
                const SizedBox(height: 36),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Text(
                    'Ordenados.\nA tiempo.\nSin olvidos.',
                    style: GoogleFonts.inter(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.5,
                      height: 1.05,
                      color: FzColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    'Tus gastos del mes en una sola pantalla. '
                    'Marcá pagado en un toque y nunca más se te '
                    'pase un vencimiento.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: FzColors.textDim,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                _BrandFeature(
                  icon: Icons.calendar_today_outlined,
                  text: 'Vista mensual con todos tus pagos agrupados',
                ),
                const SizedBox(height: 14),
                _BrandFeature(
                  icon: Icons.check_circle_outline_rounded,
                  text: 'Marcá pagado en un toque',
                ),
                const SizedBox(height: 14),
                _BrandFeature(
                  icon: Icons.fingerprint_rounded,
                  text: 'Bloqueo biométrico opcional',
                ),
                const SizedBox(height: 36),
                Text(
                  'FINANZAPP.APP · ©2026 · HECHO EN ARGENTINA',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    letterSpacing: 0.66,
                    color: FzColors.textMute,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Panel de form (derecha)
        SizedBox(
          width: formWidth,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: FzColors.border)),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'INICIAR SESIÓN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w500,
                        color: FzColors.textMute,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bienvenido de vuelta',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                        color: FzColors.text,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _AuthForm(
                      emailController: emailController,
                      emailHasContent: emailHasContent,
                      isLoading: isLoading,
                      onSubmitGoogle: onSubmitGoogle,
                      onSubmitApple: onSubmitApple,
                      onSubmitMagicLink: onSubmitMagicLink,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandFeature extends StatelessWidget {
  const _BrandFeature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: FzColors.primarySoft,
            borderRadius: BorderRadius.circular(FzRadius.md),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: FzColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: FzColors.textDim,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bloque de auth (Apple/Google + email + CTA). Reutilizado por compact
/// y split.
class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.emailController,
    required this.emailHasContent,
    required this.isLoading,
    required this.onSubmitGoogle,
    required this.onSubmitApple,
    required this.onSubmitMagicLink,
  });

  final TextEditingController emailController;
  final bool emailHasContent;
  final bool isLoading;
  final VoidCallback onSubmitGoogle;
  final VoidCallback onSubmitApple;
  final VoidCallback onSubmitMagicLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (Platform.isIOS) ...[
          _AppleButton(onPressed: isLoading ? null : onSubmitApple),
          const SizedBox(height: 12),
        ],
        _GoogleButton(
          onPressed: isLoading ? null : onSubmitGoogle,
          loading: isLoading,
        ),
        const SizedBox(height: 24),
        const _OrDivider(),
        const SizedBox(height: 24),
        _EmailInput(controller: emailController),
        const SizedBox(height: 10),
        _PrimaryCta(
          onPressed: (isLoading || !emailHasContent) ? null : onSubmitMagicLink,
          loading: isLoading,
        ),
      ],
    );
  }
}

/// Halo radial verde sutil arriba — replica el `radial-gradient` del JSX.
class _RadialHalo extends StatelessWidget {
  const _RadialHalo();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -96,
      left: 0,
      right: 0,
      height: 480,
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 480,
            height: 480,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  FzColors.primary.withValues(alpha: 0.13),
                  FzColors.primary.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.6],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón Google blanco con logo multicolor.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, required this.loading});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FzRadius.xl),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(FzRadius.xl),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF1F1F1F)),
                    ),
                  )
                else
                  SvgPicture.asset(
                    'assets/icons/google_logo.svg',
                    width: 18,
                    height: 18,
                  ),
                const SizedBox(width: 10),
                Text(
                  'Continuar con Google',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón "Continuar con Apple" — usa el widget oficial del package
/// para cumplir las Apple HIG (color, logo, espaciado son estrictos).
/// Forzamos height para matchear visualmente con _GoogleButton (46pt).
/// Style white: en theme dark un botón negro queda sin contraste contra el
/// background y App Review rechaza por no parecer botón (Guideline 4 - Design,
/// rechazo del 2026-05-18 en submission 1.0(1)).
class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      child: SignInWithAppleButton(
        onPressed: disabled ? () {} : onPressed!,
        text: 'Continuar con Apple',
        height: 46,
        style: SignInWithAppleButtonStyle.white,
        borderRadius: BorderRadius.circular(FzRadius.xl),
      ),
    );
  }
}

/// Divider con texto "o por email" entre dos líneas.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: FzColors.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'O POR EMAIL',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              letterSpacing: 1.1,
              color: FzColors.textMute,
            ),
          ),
        ),
        const Expanded(child: Divider(color: FzColors.border, height: 1)),
      ],
    );
  }
}

/// Input de email con label flotante "EMAIL" pegado al borde superior
/// (estilo del JSX: posición absoluta -6 px arriba con bg `bg` para
/// "cortar" el borde del input).
class _EmailInput extends StatelessWidget {
  const _EmailInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: FzColors.card,
            borderRadius: BorderRadius.circular(FzRadius.xl),
            border: Border.all(color: FzColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enableSuggestions: false,
            style: GoogleFonts.inter(fontSize: 14, color: FzColors.text),
            decoration: InputDecoration(
              hintText: 'tu@email.com',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: FzColors.textMute,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        // Label flotante "EMAIL"
        Positioned(
          left: 14,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: FzColors.bg,
            child: Text(
              'EMAIL',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                letterSpacing: 0.53,
                color: FzColors.textMute,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón primario verde "Enviarme el link →".
class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.onPressed, required this.loading});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FzRadius.xl),
          boxShadow: disabled ? null : FzShadow.ctaPrimary,
        ),
        child: Material(
          color: disabled
              ? FzColors.primary.withValues(alpha: 0.6)
              : FzColors.primary,
          borderRadius: BorderRadius.circular(FzRadius.xl),
          child: InkWell(
            onTap: disabled ? null : onPressed,
            borderRadius: BorderRadius.circular(FzRadius.xl),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enviarme el link',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: FzColors.primaryInk,
                      letterSpacing: -0.07,
                    ),
                  ),
                  const SizedBox(width: 8),
                  loading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              FzColors.primaryInk,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: FzColors.primaryInk,
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
