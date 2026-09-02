import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import 'register_success_page.dart';

class RegisterSecurityPage extends StatefulWidget {
  final String fullName;
  final String nationalId;
  final String phone;
  final String email;
  final String password;

  const RegisterSecurityPage({
    super.key,
    required this.fullName,
    required this.nationalId,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterSecurityPage> createState() => _RegisterSecurityPageState();
}

class _RegisterSecurityPageState extends State<RegisterSecurityPage> {
  bool _loading = false;

  Future<void> _register() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      final result = await ApiService.register(
        fullName: widget.fullName,
        nationalId: widget.nationalId,
        phone: widget.phone,
        email: widget.email,
        password: widget.password,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => RegisterSuccessPage(
            fullName: result.fullName,
            customerNumber: result.customerNumber,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String get _maskedTc {
    if (widget.nationalId.length != 11) {
      return widget.nationalId;
    }

    return '${widget.nationalId.substring(0, 3)}******${widget.nationalId.substring(9)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 310,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.navy,
                  AppColors.navyLight,
                  Color(0xFF164A5A),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      _pill(),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Son bir\nkontrol.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.primary,
                          size: 38,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Bilgilerini Onayla',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hesabını oluşturmadan önce bilgilerini kontrol et.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 25),
                        _row('Ad Soyad', widget.fullName),
                        _row('T.C. Kimlik No', _maskedTc),
                        _row('Telefon', '+90 ${widget.phone}'),
                        _row('E-posta', widget.email),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColors.softPrimary,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.fingerprint_rounded,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Hesabın oluşturulduktan sonra cihaz kilidi / biyometrik doğrulama ile korunacak.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.4,
                                    ),
                                  )
                                : const Text(
                                    'Hesabımı Oluştur',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _pill() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(50),
    ),
    child: const Text(
      '2 / 2',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
  );
}
