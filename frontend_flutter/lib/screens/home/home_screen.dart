import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/layout/app_scaffold.dart';

// ─────────────────────────────────────────────
// Palette (mirrors the HTML exactly)
// ─────────────────────────────────────────────
class _C {
  // Left panel gradient stops
  static const gradStart  = Color(0xFF0A4A44);
  static const gradMid    = Color(0xFF0D6B5E);
  static const gradEnd    = Color(0xFF0E7490);

  // Teal accent (badge, focus ring, role selected)
  static const teal       = Color(0xFF5EEAD4);
  static const tealDark   = Color(0xFF0D9488);
  static const tealDeep   = Color(0xFF0D6B5E);

  // Right panel
  static const surface    = Color(0xFFFAFAFA);
  static const border     = Color(0xFFE5E7EB);
  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textHint      = Color(0xFF94A3B8);
  static const inputBorder   = Color(0xFFE2E8F0);
  static const inputFocus    = Color(0xFF0D9488);

  // Tab bar
  static const tabBg      = Color(0xFFF1F5F9);

  // Error
  static const errBg      = Color(0xFFFEF2F2);
  static const errBorder  = Color(0xFFFECACA);
  static const errText    = Color(0xFFDC2626);

  // Success
  static const okBg       = Color(0xFFF0FDFA);
  static const okBorder   = Color(0xFF99F6E4);
  static const okText     = Color(0xFF0D6B5E);

  // Role tile selected
  static const roleSel    = Color(0xFFF0FDFA);
}

enum _UserRole { tenant, landlord }

// ─────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return AppScaffold(
      child: LayoutBuilder(builder: (ctx, box) {
        final wide = box.maxWidth >= 900;
        if (wide) {
          return SizedBox(
            height: screenH * 0.88,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(child: _IntroPanel()),
                SizedBox(width: 20),
                SizedBox(width: 420, child: _AuthPanel()),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: const [_IntroPanel(), SizedBox(height: 20), _AuthPanel(), SizedBox(height: 24)],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Left: Intro panel
// ─────────────────────────────────────────────
class _IntroPanel extends StatelessWidget {
  const _IntroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.gradStart, _C.gradMid, _C.gradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x330A4A44), blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          _LiveBadge(),
          const SizedBox(height: 18),
          // Eyebrow
          const Text(
            'AI RENT ADVISOR',
            style: TextStyle(color: Color(0x99FFFFFF), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          // Headline — "better." in teal
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1.1),
              children: [
                TextSpan(text: 'Rent smarter.\nNegotiate '),
                TextSpan(text: 'better.', style: TextStyle(color: _C.teal)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Body copy
          const Text(
            'Before you sign, know the real cost. We surface hidden fees, flag risky landlords, and hand you three negotiation talking points — all in seconds.',
            style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 15, height: 1.65),
          ),
          const SizedBox(height: 32),
          // Tile grid
          const _TileGrid(),
        ],
      ),
    );
  }
}

// Pulsing dot badge
class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _opacity =
      Tween<double>(begin: 1, end: 0.3).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x265EEAD4),
        border: Border.all(color: const Color(0x595EEAD4)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _opacity,
            child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: _C.teal, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 6),
          const Text('AI-powered renting intelligence', style: TextStyle(color: _C.teal, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// 2×2 tile grid
class _TileGrid extends StatelessWidget {
  const _TileGrid();

  static const _data = [
    ('Rental Verdict',      'Great Deal / Acceptable / Avoid'),
    ('True Cost',           'First-year monthly average'),
    ('Risk Radar',          'Complaint pattern signals'),
    ('Negotiation Coach',   '3 talking points ready to use'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_data.length, (i) {
        return StaggeredReveal(
          index: i,
          child: _FeatureTile(title: _data[i].$1, sub: _data[i].$2),
        );
      }),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.title, required this.sub});
  final String title, sub;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x1FFFFFFF),
          border: Border.all(color: const Color(0x4DFFFFFF)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Right: Auth panel
// ─────────────────────────────────────────────
class _AuthPanel extends StatefulWidget {
  const _AuthPanel();
  @override State<_AuthPanel> createState() => _AuthPanelState();
}

class _AuthPanelState extends State<_AuthPanel> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.border),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Get started', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _C.textPrimary)),
                SizedBox(height: 6),
                Text(
                  'Sign up to save reports, or log in to continue where you left off.',
                  style: TextStyle(fontSize: 14, color: _C.textSecondary, height: 1.55),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: _C.border), borderRadius: BorderRadius.circular(10)),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(color: _C.tabBg, borderRadius: BorderRadius.circular(8)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: _C.textPrimary,
                unselectedLabelColor: _C.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [Tab(text: 'Log in'), Tab(text: 'Sign up')],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [_LoginForm(), _SignupForm()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Login form
// ─────────────────────────────────────────────
class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obscure = true, _loading = false;
  String? _error;

  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _error = null; _loading = true; });
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(), password: _pass.text,
      );
      final doc = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
      final role = (doc.data()?['role'] as String?)?.toLowerCase() ?? 'tenant';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful.')));
      context.go(role == 'owner' || role == 'landlord' ? '/landlord-home' : '/tenant-home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = switch (e.code) {
          'invalid-email'                       => 'Invalid email format.',
          'user-not-found'                      => 'No account found for this email.',
          'wrong-password' || 'invalid-credential' => 'Incorrect email or password.',
          _                                     => 'Login failed. Please try again.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Unexpected error. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[_Banner(text: _error!, isError: true), const SizedBox(height: 14)],
          _Label('Email'),
          _Input(ctrl: _email, hint: 'you@email.com', type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _Label('Password'),
          _PassInput(ctrl: _pass, obscure: _obscure, onToggle: () => setState(() => _obscure = !_obscure)),
          const SizedBox(height: 24),
          _PrimaryBtn(label: 'Log in', loading: _loading, onPressed: _submit),
          const SizedBox(height: 14),
          const _Divider(),
          const SizedBox(height: 14),
          _GuestBtn(onPressed: () => context.go('/input')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Signup form
// ─────────────────────────────────────────────
class _SignupForm extends StatefulWidget {
  const _SignupForm();
  @override State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obscure = true, _loading = false;
  String? _error;
  _UserRole _role = _UserRole.tenant;

  @override void dispose() { _name.dispose(); _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_pass.text.length < 6) { setState(() => _error = 'Password must be at least 6 characters.'); return; }
    setState(() { _error = null; _loading = true; });
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(), password: _pass.text,
      );
      String? warn;
      try {
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'role': _role.name,
          'assignedLandlordId': _role == _UserRole.tenant ? null : '',
          'memberSince': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        warn = 'Account created, but profile save failed (${e.code}).';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        warn ?? 'Account created as ${_role == _UserRole.tenant ? 'Tenant' : 'Landlord'}.',
      )));
      context.go(_role == _UserRole.tenant ? '/tenant-home' : '/landlord-home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = switch (e.code) {
          'invalid-email'          => 'Invalid email format.',
          'email-already-in-use'   => 'This email is already registered.',
          'weak-password'          => 'Password is too weak (min 6 characters).',
          'operation-not-allowed'  => 'Email/password sign-in is disabled.',
          'network-request-failed' => 'Network error. Check your connection.',
          'too-many-requests'      => 'Too many attempts. Please wait.',
          _                        => 'Sign up failed. Please try again.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Unexpected error during sign up.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[_Banner(text: _error!, isError: true), const SizedBox(height: 14)],
          _Label('Full name'),
          _Input(ctrl: _name, hint: 'Your name', type: TextInputType.name),
          const SizedBox(height: 14),
          _Label('Email'),
          _Input(ctrl: _email, hint: 'you@email.com', type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _Label('Password'),
          _PassInput(ctrl: _pass, obscure: _obscure, onToggle: () => setState(() => _obscure = !_obscure)),
          const SizedBox(height: 18),
          const Text('I am a...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _C.textSecondary)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _RoleTile(icon: '🏠', label: 'Tenant',   sub: 'Looking for a place',   selected: _role == _UserRole.tenant,   onTap: () => setState(() => _role = _UserRole.tenant))),
            const SizedBox(width: 10),
            Expanded(child: _RoleTile(icon: '🔑', label: 'Landlord', sub: 'Managing a property', selected: _role == _UserRole.landlord, onTap: () => setState(() => _role = _UserRole.landlord))),
          ]),
          const SizedBox(height: 14),
          const Text(
            'By creating an account you agree to our Terms of Service and Privacy Policy.',
            style: TextStyle(fontSize: 12, color: _C.textHint, height: 1.5),
          ),
          const SizedBox(height: 18),
          _PrimaryBtn(label: 'Create account', loading: _loading, onPressed: _submit),
          const SizedBox(height: 14),
          const _Divider(),
          const SizedBox(height: 14),
          _GuestBtn(onPressed: () => context.go('/input')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared micro-widgets
// ─────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _C.textSecondary)),
  );
}

InputDecoration _inputDeco(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: _C.textHint, fontSize: 14),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
  filled: true,
  fillColor: Colors.white,
  border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _C.inputBorder)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _C.inputBorder)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _C.inputFocus, width: 1.5)),
);

class _Input extends StatelessWidget {
  const _Input({required this.ctrl, required this.hint, required this.type});
  final TextEditingController ctrl;
  final String hint;
  final TextInputType type;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, keyboardType: type,
    style: const TextStyle(fontSize: 14, color: _C.textPrimary),
    decoration: _inputDeco(hint),
  );
}

class _PassInput extends StatelessWidget {
  const _PassInput({required this.ctrl, required this.obscure, required this.onToggle});
  final TextEditingController ctrl;
  final bool obscure;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, obscureText: obscure,
    style: const TextStyle(fontSize: 14, color: _C.textPrimary),
    decoration: _inputDeco('••••••••').copyWith(
      suffixIcon: TextButton(
        onPressed: onToggle,
        child: Text(obscure ? 'Show' : 'Hide', style: const TextStyle(fontSize: 12, color: _C.textSecondary)),
      ),
    ),
  );
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.loading, required this.onPressed});
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 46,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_C.tealDeep, Color(0xFF0891B2)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    ),
  );
}

class _GuestBtn extends StatelessWidget {
  const _GuestBtn({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 44,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _C.inputBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Continue as guest', style: TextStyle(fontSize: 14, color: _C.textSecondary)),
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Row(children: const [
    Expanded(child: Divider(color: _C.border, thickness: 0.5)),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text('or', style: TextStyle(fontSize: 13, color: _C.textHint)),
    ),
    Expanded(child: Divider(color: _C.border, thickness: 0.5)),
  ]);
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.isError});
  final String text;
  final bool isError;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color:   isError ? _C.errBg   : _C.okBg,
      border: Border.all(color: isError ? _C.errBorder : _C.okBorder),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: TextStyle(fontSize: 13, color: isError ? _C.errText : _C.okText, height: 1.45)),
  );
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.icon, required this.label, required this.sub, required this.selected, required this.onTap});
  final String icon, label, sub;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? _C.roleSel : Colors.white,
        border: Border.all(color: selected ? _C.tealDark : _C.inputBorder, width: selected ? 1.5 : 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: selected ? _C.tealDeep : _C.textPrimary)),
        const SizedBox(height: 3),
        Text(sub, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: _C.textHint, height: 1.35)),
      ]),
    ),
  );
}