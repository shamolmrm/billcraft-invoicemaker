import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/route_names.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen>
    with SingleTickerProviderStateMixin {
  String _selected = 'en';
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _langs = [
    {'code': 'en', 'flag': '🇬🇧', 'native': 'English', 'name': 'English'},
    {'code': 'bn', 'flag': '🇧🇩', 'native': 'বাংলা', 'name': 'Bangla'},
    {'code': 'hi', 'flag': '🇮🇳', 'native': 'हिन्दी', 'name': 'Hindi'},
    {'code': 'ar', 'flag': '🇸🇦', 'native': 'العربية', 'name': 'Arabic'},
    {'code': 'es', 'flag': '🇪🇸', 'native': 'Español', 'name': 'Spanish'},
    {'code': 'fr', 'flag': '🇫🇷', 'native': 'Français', 'name': 'French'},
    {'code': 'pt', 'flag': '🇧🇷', 'native': 'Português', 'name': 'Portuguese'},
    {'code': 'id', 'flag': '🇮🇩', 'native': 'Indonesia', 'name': 'Indonesian'},
    {'code': 'tr', 'flag': '🇹🇷', 'native': 'Türkçe', 'name': 'Turkish'},
    {'code': 'de', 'flag': '🇩🇪', 'native': 'Deutsch', 'name': 'German'},
    {'code': 'zh', 'flag': '🇨🇳', 'native': '中文', 'name': 'Chinese'},
    {'code': 'ja', 'flag': '🇯🇵', 'native': '日本語', 'name': 'Japanese'},
    {'code': 'ko', 'flag': '🇰🇷', 'native': '한국어', 'name': 'Korean'},
    {'code': 'ru', 'flag': '🇷🇺', 'native': 'Русский', 'name': 'Russian'},
    {'code': 'it', 'flag': '🇮🇹', 'native': 'Italiano', 'name': 'Italian'},
    {'code': 'ms', 'flag': '🇲🇾', 'native': 'Melayu', 'name': 'Malay'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    // Pre-select device language if supported
    final deviceCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (_langs.any((l) => l['code'] == deviceCode)) {
      _selected = deviceCode;
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    await context.setLocale(Locale(_selected));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_picker_shown', true);
    if (mounted) context.go(RouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Logo + App name
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('BillCraft',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your language  ·  ভাষা বেছে নিন  ·  भाषा चुनें',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Language list
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _langs.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100, indent: 60),
                          itemBuilder: (context, i) {
                            final lang = _langs[i];
                            final isSelected = lang['code'] == _selected;
                            return InkWell(
                              onTap: () => setState(() => _selected = lang['code']!),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isSelected
                                            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                                            : Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Center(child: Text(lang['flag']!, style: const TextStyle(fontSize: 22))),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(lang['native']!,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected ? AppColors.primary : const Color(0xFF1A1A2E))),
                                          Text(lang['name']!,
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                        ],
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: isSelected
                                          ? Container(
                                              key: const ValueKey('check'),
                                              width: 26,
                                              height: 26,
                                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                              child: const Icon(Icons.check, color: Colors.white, size: 16),
                                            )
                                          : const SizedBox(width: 26, height: 26, key: ValueKey('empty')),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Continue button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _langs.firstWhere((l) => l['code'] == _selected)['native'] == 'English'
                                  ? 'Continue'
                                  : 'Continue  ·  ${_langs.firstWhere((l) => l['code'] == _selected)['native']}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
