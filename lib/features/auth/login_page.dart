import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Email ve şifreyi doldur.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String fullName = await ApiService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      debugPrint('Giriş başarılı: $fullName');
      debugPrint('Access Token: ${ApiService.accessToken}');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final String message = e
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Stack(
          children: [
            // PREMIUM RED BACKGROUND
            Container(
              height: 365,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF3B35),
                    Color(0xFFED1C24),
                    Color(0xFFC81019),
                  ],
                ),
              ),
            ),

            // DECORATIVE LIGHT
            Positioned(
              top: -75,
              right: -65,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.09,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 135,
              left: -100,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.035,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  28,
                ),
                child: Column(
                  children: [
                    // BRAND
                    const Row(
                      children: [
                        _IbtLogo(),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IBT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.4,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'DIGITAL BANKING',
                              style: TextStyle(
                                color: Color(0xFFFFD5D5),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 38),

                    // HERO
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bankacılığın\nyeni standardı.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Güvenli, hızlı ve premium dijital deneyim.',
                        style: TextStyle(
                          color: Color(0xFFFFD9D9),
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // LOGIN CARD
                    _LoginCard(
                      emailController:
                      _emailController,
                      passwordController:
                      _passwordController,
                      obscurePassword:
                      _obscurePassword,
                      isLoading:
                      _isLoading,
                      onLogin:
                      _login,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // NEW CUSTOMER
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const RegisterPage(),
                            ),
                          );
                        },
                        borderRadius:
                        BorderRadius.circular(20),
                        child: Ink(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(20),
                            border: Border.all(
                              color:
                              const Color(0xFFE9E9E9),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFFFFECEE),
                                  borderRadius:
                                  BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons
                                      .person_add_alt_1_rounded,
                                  color:
                                  AppColors.primary,
                                  size: 21,
                                ),
                              ),

                              const SizedBox(width: 13),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Henüz müşterimiz değil misin?',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight:
                                        FontWeight.w700,
                                        color: AppColors
                                            .textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Dakikalar içinde hesap oluştur.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color:
                                        Color(0xFF8A8A8A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons
                                    .arrow_forward_ios_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // SECURITY
                    const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF8B8B8B),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Güvenli ve şifrelenmiş bağlantı',
                          style: TextStyle(
                            color: Color(0xFF8B8B8B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LOGIN CARD
// -----------------------------------------------------------------------------

class _LoginCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final bool isLoading;

  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        22,
        22,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.075,
            ),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoş geldin',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Hesabına güvenli şekilde giriş yap.',
            style: TextStyle(
              color: Color(0xFF858585),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 25),

          // EMAIL
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: emailController,
            enabled: !isLoading,
            keyboardType:
            TextInputType.emailAddress,
            textInputAction:
            TextInputAction.next,
            autofillHints: const [
              AutofillHints.email,
            ],
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            decoration: _inputDecoration(
              hint: 'Email adresini gir',
              prefixIcon:
              Icons.mail_outline_rounded,
            ),
          ),

          const SizedBox(height: 17),

          // PASSWORD
          const Text(
            'Şifre',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
            passwordController,
            enabled: !isLoading,
            obscureText:
            obscurePassword,
            textInputAction:
            TextInputAction.done,
            autofillHints: const [
              AutofillHints.password,
            ],
            onSubmitted: (_) {
              if (!isLoading) {
                onLogin();
              }
            },
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            decoration: _inputDecoration(
              hint: 'Şifreni gir',
              prefixIcon:
              Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: isLoading
                    ? null
                    : onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons
                      .visibility_off_outlined
                      : Icons
                      .visibility_outlined,
                  color:
                  const Color(0xFF676767),
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          // FORGOT PASSWORD
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed:
              isLoading ? null : () {},
              style: TextButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Şifremi unuttum',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // LOGIN BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed:
              isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                AppColors.primary,
                disabledBackgroundColor:
                AppColors.primary
                    .withValues(alpha: 0.60),
                foregroundColor:
                Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 23,
                height: 23,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 9),
                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF7B7B7B),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF606060),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor:
      const Color(0xFFF8F8F8),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE8E8E8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.4,
        ),
      ),
      disabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE8E8E8),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// IBT LOGO
// -----------------------------------------------------------------------------

class _IbtLogo extends StatelessWidget {
  const _IbtLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.17,
        ),
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient:
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFF1F1),
            ],
          ),
          borderRadius:
          BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.10,
              ),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'I',
                      style: TextStyle(
                        color:
                        Color(0xFFED1C24),
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'B',
                      style: TextStyle(
                        color:
                        Color(0xFFD5161E),
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'T',
                      style: TextStyle(
                        color:
                        Color(0xFFA70F16),
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 8,
              left: 10,
              right: 10,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient:
                  const LinearGradient(
                    colors: [
                      Color(0xFFFF4545),
                      Color(0xFFED1C24),
                      Color(0xFFB30E16),
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}