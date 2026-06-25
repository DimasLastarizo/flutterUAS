import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kursuskilat/providers/app_data_provider.dart';
import 'package:kursuskilat/services/auth_service.dart';
import 'game_page.dart';

// ─── USER MODEL & PROVIDER ───────────────────────────────────────────────────

class UserModel {
  final String nama;
  final String username;
  final String email;

  const UserModel({
    required this.nama,
    required this.username,
    required this.email,
  });
}

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  void login(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}

Future<void> syncUserSession(BuildContext context) async {
  final userProvider = context.read<UserProvider>();
  final appData = context.read<AppDataProvider>();
  final profile = await AuthService.fetchProfile();
  if (profile == null || !context.mounted) return;
  userProvider.login(UserModel(
    nama:     profile['nama'] as String,
    username: profile['username'] as String,
    email:    profile['email'] as String,
  ));
  await appData.load();
}

// ─── COLOR TOKENS ────────────────────────────────────────────────────────────

const _bg       = Color(0xFF080810);
const _surface  = Color(0xFF13131F);
const _green    = Color(0xFF2ECC71);
const _greenDk  = Color(0xFF1AA355);
const _greenGl  = Color(0xFF5DEBA0);
const _divider  = Color(0xFF1E1E30);
const _textPri  = Color(0xFFF0F0FA);
const _textSec  = Color(0xFF9999BB);
const _textMid  = Color(0xFF666888);
const _red      = Color(0xFFFF6B6B);

// ─── AUTH PAGE ───────────────────────────────────────────────────────────────

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _bg,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSessionIfNeeded());
  }

  Future<void> _restoreSessionIfNeeded() async {
    if (!mounted) return;
    if (!await AuthService.hasPersistedSession()) return;
    if (!mounted) return;
    await syncUserSession(context);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RootShell()),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          const SizedBox(height: 32),
          _LogoBadge(),
          const SizedBox(height: 12),
          const Text(
            'kursuskilat',
            style: TextStyle(
              color: _textPri,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Belajar lebih cepat, lebih pintar',
            style: TextStyle(color: _textMid, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _divider),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(9),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: _textSec,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Masuk'),
                Tab(text: 'Daftar'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _LoginForm(onSwitchToRegister: () => _tab.animateTo(1)),
                _RegisterForm(onSwitchToLogin: () => _tab.animateTo(0)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1F0E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: _green.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Stack(alignment: Alignment.center, children: [
        const Icon(Icons.menu_book_rounded, color: _green, size: 30),
        Positioned(
          bottom: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.bolt, size: 10, color: Colors.black),
          ),
        ),
      ]),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final VoidCallback onSwitchToRegister;
  const _LoginForm({required this.onSwitchToRegister});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _usernameCtrl = TextEditingController();
  final _sandiCtrl    = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _sandiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    final sandi    = _sandiCtrl.text;

    if (username.isEmpty || sandi.isEmpty) {
      setState(() => _error = 'Semua field harus diisi');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final errMsg = await AuthService.login(username: username, sandi: sandi);

    if (!mounted) return;
    setState(() => _loading = false);

    if (errMsg != null) {
      setState(() => _error = errMsg);
      return;
    }

    await syncUserSession(context);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder:        (_, _, _) => const RootShell(),
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _FieldLabel('Username'),
        const SizedBox(height: 6),
        _AuthField(
          controller: _usernameCtrl,
          hint:       'Masukkan username',
          icon:       Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _FieldLabel('Sandi'),
        const SizedBox(height: 6),
        _AuthField(
          controller:  _sandiCtrl,
          hint:        'Masukkan sandi',
          icon:        Icons.lock_outline_rounded,
          obscure:     _obscure,
          suffixIcon:  IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _textMid,
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 20),
        if (_error != null) ...[
          _ErrorBox(_error!),
          const SizedBox(height: 16),
        ],
        _GreenButton(
          label:   'Masuk',
          loading: _loading,
          onTap:   _submit,
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Belum punya akun? ', style: TextStyle(color: _textSec, fontSize: 13)),
          GestureDetector(
            onTap: widget.onSwitchToRegister,
            child: const Text(
              'Daftar sekarang',
              style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const _RegisterForm({required this.onSwitchToLogin});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _namaCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _sandiCtrl    = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _sandiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nama     = _namaCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final sandi    = _sandiCtrl.text;

    if (nama.isEmpty || username.isEmpty || email.isEmpty || sandi.isEmpty) {
      setState(() { _error = 'Semua field harus diisi'; _success = null; });
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() { _error = 'Format email tidak valid'; _success = null; });
      return;
    }
    if (sandi.length < 6) {
      setState(() { _error = 'Sandi minimal 6 karakter'; _success = null; });
      return;
    }

    setState(() { _loading = true; _error = null; _success = null; });

    final errMsg = await AuthService.register(
      nama: nama, username: username, email: email, sandi: sandi,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (errMsg != null) {
      setState(() => _error = errMsg);
      return;
    }

    setState(() => _success = 'Akun berhasil dibuat! Silakan masuk.');
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) widget.onSwitchToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _FieldLabel('Nama Lengkap'),
        const SizedBox(height: 6),
        _AuthField(
          controller: _namaCtrl,
          hint:       'Masukkan nama lengkap',
          icon:       Icons.badge_outlined,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Username'),
        const SizedBox(height: 6),
        _AuthField(
          controller: _usernameCtrl,
          hint:       'Buat username unik',
          icon:       Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Email'),
        const SizedBox(height: 6),
        _AuthField(
          controller:    _emailCtrl,
          hint:          'Masukkan email aktif',
          icon:          Icons.email_outlined,
          keyboardType:  TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Sandi'),
        const SizedBox(height: 6),
        _AuthField(
          controller:  _sandiCtrl,
          hint:        'Min. 6 karakter',
          icon:        Icons.lock_outline_rounded,
          obscure:     _obscure,
          suffixIcon:  IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _textMid,
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 20),
        if (_error != null) ...[_ErrorBox(_error!), const SizedBox(height: 16)],
        if (_success != null) ...[_SuccessBox(_success!), const SizedBox(height: 16)],
        _GreenButton(
          label:   'Daftar',
          loading: _loading,
          onTap:   _submit,
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Sudah punya akun? ', style: TextStyle(color: _textSec, fontSize: 13)),
          GestureDetector(
            onTap: widget.onSwitchToLogin,
            child: const Text(
              'Masuk',
              style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: _textSec, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.4,
    ),
  );
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        _surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: _divider),
      ),
      child: TextField(
        controller:    controller,
        obscureText:   obscure,
        keyboardType:  keyboardType,
        style:         const TextStyle(color: _textPri, fontSize: 14),
        decoration: InputDecoration(
          hintText:      hint,
          hintStyle:     const TextStyle(color: _textMid, fontSize: 14),
          prefixIcon:    Icon(icon, color: _textMid, size: 20),
          suffixIcon:    suffixIcon,
          border:        InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _GreenButton({required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_greenDk, _green, _greenGl],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        const Color(0xFF1F0D0D),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: _red.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: _red, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(color: _red, fontSize: 13))),
      ]),
    );
  }
}

class _SuccessBox extends StatelessWidget {
  final String message;
  const _SuccessBox(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        const Color(0xFF0A1F0A),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: _green.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_outline_rounded, color: _green, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(color: _green, fontSize: 13))),
      ]),
    );
  }
}
