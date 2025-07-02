import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _mailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _agree = false;

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(color: AppColors.gray500),
        floatingLabelStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12),
        filled: true,
        fillColor: AppColors.gray200,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      );

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _birthCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Gambar hero atas
          SizedBox(
            height: h * 0.35,
            width: double.infinity,
            child: Image.asset(
              'assets/images/bg_hero_register.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Form card yang scrollable
          SingleChildScrollView(
            padding: EdgeInsets.only(top: h * 0.3),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - h * 0.3,
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.secondaryDark,
                        blurRadius: 12,
                        offset: Offset(0, -4))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text('Buat Akun Baru Untuk Kamu',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        'Mari mulai perjalananmu bersama Teman Sejenak',
                        style: TextStyle(color: AppColors.gray500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _dec('Nama Lengkap'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _placeCtrl,
                        decoration: _dec('Tempat Lahir'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _birthCtrl,
                        readOnly: true,
                        onTap: _pickBirth,
                        decoration: _dec('Tanggal Lahir').copyWith(
                          suffixIcon:
                              const Icon(Icons.calendar_today_rounded),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _mailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _dec('Email'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: _dec('Password'),
                        validator: (v) =>
                            v!.length < 6 ? 'Min 6 chars' : null,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Checkbox(
                              value: _agree,
                              activeColor: AppColors.primaryDark,
                              onChanged: (v) => setState(() => _agree = v!)),
                          Expanded(
                            child: Text.rich(const TextSpan(
                                text:
                                    'Saya menyatakan telah membaca dan setuju dengan ',
                                children: [
                                  TextSpan(
                                      text: 'Syarat & Ketentuan',
                                      style: TextStyle(
                                          color: AppColors.primary)),
                                  TextSpan(text: ' dan '),
                                  TextSpan(
                                      text: 'Kebijakan Privasi',
                                      style: TextStyle(
                                          color: AppColors.primary))
                                ])),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: !_agree
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen()));
                                  }
                                },
                          child: const Text(
                            'Daftar',
                            style: TextStyle(color: AppColors.background),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text.rich(TextSpan(
                            text: 'Sudah punya akun? ',
                            children: [
                              TextSpan(
                                  text: 'Masuk di sini!',
                                  style: TextStyle(color: AppColors.primary))
                            ])),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
