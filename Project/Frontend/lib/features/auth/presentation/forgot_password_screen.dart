import 'package:defakeit/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization import

import '../../../core/constant/APIs_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _storage = const FlutterSecureStorage();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _infoMessage;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _sendVerificationCode() async {
    final local = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      setState(() => _infoMessage = local.enterValidEmail);
      return;
    }

    setState(() {
      _isLoading = true;
      _infoMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
            '${APIsConstants.baseURL}${APIsConstants.forgotPasswordEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      await _storage.write(key: 'reset_email', value: email);

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/verification');
      } else {
        setState(() {
          _infoMessage = local.emailWillReceiveCode;
        });
      }
    } catch (e) {
      setState(() => _infoMessage = local.networkError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Image.asset(
              isDarkMode
                  ? "assets/images/background_home_transparent.png"
                  : "assets/images/background.png",
              fit: BoxFit.cover,
              color: isDarkMode ? Colors.white.withOpacity(0.2) : null,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 38),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${local.forgot}\n',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF8F9193),
                            fontWeight: FontWeight.w500,
                            fontSize: 32,
                            height: 1.2,
                          ),
                        ),
                        TextSpan(
                          text: local.password,
                          style: textTheme.displayMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    local.enterEmailToReceiveCode,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF8F9193),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFFB0B0B0),
                          size: 20,
                        ),
                        hintText: local.emailAddress,
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFFB0B0B0),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),

                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.black45 : Colors.white,  // تقدر كمان تتحكم في حجم الخط وغيره
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  if (_infoMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _infoMessage!,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        local.send,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          local.goBackTo,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF8F9193),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            local.signIn,
                            style: textTheme.bodyMedium,
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
}
