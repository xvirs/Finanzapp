import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
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
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          // Logo
                          const Center(child: FzLogo(size: 64, shadow: true)),
                          const SizedBox(height: 28),
                          // Título
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
                          // Subtítulo
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
                          // Botón Google (blanco)
                          _GoogleButton(
                            onPressed: isLoading ? null : _submitGoogle,
                            loading: isLoading,
                          ),
                          const SizedBox(height: 24),
                          // Divider "o por email"
                          const _OrDivider(),
                          const SizedBox(height: 24),
                          // Email field con label flotante "EMAIL"
                          _EmailInput(controller: _emailController),
                          const SizedBox(height: 10),
                          // CTA "Enviarme el link →"
                          _PrimaryCta(
                            onPressed: (isLoading || !_emailHasContent)
                                ? null
                                : _submitMagicLink,
                            loading: isLoading,
                          ),
                          const SizedBox(height: 28),
                          // Footer mono
                          Text(
                            'v2.0 · finanzapp.app',
                            textAlign: TextAlign.center,
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
                ),
              ),
            ],
          ),
        );
      },
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
