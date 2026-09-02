import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../main/main_shell.dart';
import 'login_page.dart';

class SessionGate extends StatefulWidget {
  final bool initiallyUnlocked;

  const SessionGate({super.key, this.initiallyUnlocked = false});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> with WidgetsBindingObserver {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _loading = true;
  bool _hasSession = false;
  bool _unlocked = false;
  bool _authenticating = false;

  DateTime? _backgroundedAt;

  static const Duration _backgroundLockDelay = Duration(seconds: 60);

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _unlocked = widget.initiallyUnlocked;

    _checkSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UYGULAMA ARKA PLANA GİDERSE TEKRAR KİLİTLE
  // ---------------------------------------------------------------------------

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasSession) return;

    switch (state) {
      case AppLifecycleState.inactive:
        // Bildirim paneli, kontrol merkezi gibi geçici durumlar.
        // Uygulamayı KİLİTLEME.
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // Gerçekten arka plana gittiyse zamanı kaydet.
        _backgroundedAt ??= DateTime.now();
        break;

      case AppLifecycleState.resumed:
        final backgroundedAt = _backgroundedAt;

        _backgroundedAt = null;

        if (backgroundedAt == null || !_unlocked) {
          return;
        }

        final backgroundDuration = DateTime.now().difference(backgroundedAt);

        // 1 dakikadan kısa arka plan geçişlerinde
        // kullanıcıyı tekrar doğrulamaya zorlama.
        if (backgroundDuration < _backgroundLockDelay) {
          return;
        }

        if (!mounted) return;

        setState(() {
          _unlocked = false;
        });

        break;

      case AppLifecycleState.detached:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // TELEFONDA KAYITLI OTURUM VAR MI?
  // ---------------------------------------------------------------------------

  Future<void> _checkSession() async {
    try {
      final bool loggedIn = await ApiService.isLoggedIn();

      if (!mounted) return;

      setState(() {
        _hasSession = loggedIn;
        _loading = false;
      });

      // Uygulama açılır açılmaz native doğrulama ekranını
      // zorla açmıyoruz.
      //
      // Kullanıcı önce IBT Bank kilit ekranını görür,
      // ardından "Kimliğimi Doğrula" butonuna basar.
      //
      // Bu özellikle Android emulator'da oluşabilen
      // siyah native auth ekranını önler.
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasSession = false;
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // PARMAK İZİ / FACE / CİHAZ PIN
  // ---------------------------------------------------------------------------

  Future<void> _authenticate() async {
    if (_authenticating) return;

    setState(() {
      _authenticating = true;
      _errorMessage = null;
    });

    try {
      final bool supported = await _localAuth.isDeviceSupported();

      if (!supported) {
        if (!mounted) return;

        setState(() {
          _errorMessage = 'Bu cihazda ekran kilidi veya biyometrik doğrulama kullanılamıyor.';
        });

        return;
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'IBT Bank hesabına erişmek için kimliğini doğrula',
        biometricOnly: false,
        persistAcrossBackgrounding: false,
      );

      if (!mounted) return;

      if (authenticated) {
        setState(() {
          _unlocked = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Kimlik doğrulama tamamlanamadı.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _authenticating = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // OTURUMU TAMAMEN KAPAT
  // ---------------------------------------------------------------------------

  Future<void> _logout() async {
    await ApiService.logout();

    if (!mounted) return;

    setState(() {
      _hasSession = false;
      _unlocked = false;
      _errorMessage = null;
    });
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _SplashPage();
    }

    // Token yoksa normal email + şifre.
    if (!_hasSession) {
      return const LoginPage();
    }

    // Token var ama uygulama kilitliyse.
    if (!_unlocked) {
      return _LockPage(
        authenticating: _authenticating,
        errorMessage: _errorMessage,
        onUnlock: _authenticate,
        onLogout: _logout,
      );
    }

    // Kimlik doğrulandı.
    return const MainShell();
  }
}

// =============================================================================
// LOCK PAGE
// =============================================================================

class _LockPage extends StatelessWidget {
  final bool authenticating;
  final String? errorMessage;

  final VoidCallback onUnlock;
  final VoidCallback onLogout;

  const _LockPage({
    required this.authenticating,
    required this.errorMessage,
    required this.onUnlock,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // -------------------------------------------------------------------
          // BACKGROUND DECORATION
          // -------------------------------------------------------------------

          Positioned(
            right: -100,
            top: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 48,
                ),
              ),
            ),
          ),

          Positioned(
            left: -130,
            bottom: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.025),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // CONTENT
          // -------------------------------------------------------------------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                children: [
                  // BANK BRAND
                  const Row(
                    children: [
                      _LockLogo(),

                      SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IBT BANK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'DIGITAL BANKING',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // LOCK ICON
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),

                  const SizedBox(height: 27),

                  const Text(
                    'Tekrar hoş geldin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 9),

                  const Text(
                    'Hesap bilgilerini görüntülemek için\nkimliğini doğrula.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // AUTH BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 57,
                    child: ElevatedButton(
                      onPressed: authenticating ? null : onUnlock,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.navy,
                        disabledBackgroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: authenticating
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.navy,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fingerprint_rounded, size: 25),
                                SizedBox(width: 10),
                                Text(
                                  'Kimliğimi Doğrula',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: authenticating ? null : onLogout,
                    child: const Text(
                      'Farklı hesapla giriş yap',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'IBT güvenli oturum',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

// =============================================================================
// SPLASH
// =============================================================================

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'IBT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
            ),

            SizedBox(height: 19),

            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LOGO
// =============================================================================

class _LockLogo extends StatelessWidget {
  const _LockLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Text(
        'IBT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
