import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
<<<<<<< HEAD
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'patient'; // 'patient', 'doctor', 'admin'
=======
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = "patient";
>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await authProvider.login(email, password);
    if (!mounted) return;

    if (success) {
      final actualRole = authProvider.user?.role ?? 'patient';

      // Role validation
      if (_selectedRole == 'admin' && !authProvider.isAdmin) {
        _showError('This account does not have Admin access.');
        return;
      }
      if (_selectedRole == 'doctor' && actualRole != 'doctor') {
        _showError('This account is not a Doctor account.');
        return;
      }
      if (_selectedRole == 'patient' && actualRole != 'patient') {
        _showError('This account is not a Patient account.');
        return;
      }

      if (authProvider.isAdmin) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminDashboard, (route) => false);
      } else if (actualRole == 'doctor') {
        if (authProvider.isDoctor) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.doctorDashboard, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.awaitApproval, (route) => false);
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } else {
      _showError(authProvider.errorMessage ?? 'Login failed. Please check credentials.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
=======
  //---------------------------------------------------------
  // Role Card
  //---------------------------------------------------------
  Widget _roleCard({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final bool selected = _selectedRole == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedRole = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //---------------------------------------------------------
  // Custom TextField
  //---------------------------------------------------------
  Widget _customField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? _obscurePassword : false,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Required";
        }
        if (!isPassword && !value.contains("@")) {
          return "Enter valid email";
        }
        if (isPassword && value.length < 6) {
          return "Minimum 6 characters";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  //---------------------------------------------------------
  // Login Logic
  //---------------------------------------------------------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? "Login Failed",
          ),
        ),
      );
      return;
    }

    if (_selectedRole == "admin") {
      if (!authProvider.isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This account is not an Admin account."),
          ),
        );
        await authProvider.logout();
        return;
      }
    }

    if (_selectedRole == "doctor") {
      if (!authProvider.isDoctor) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This account is not a Doctor account."),
          ),
        );
        await authProvider.logout();
        return;
      }
    }

    if (_selectedRole == "patient") {
      if (authProvider.isAdmin || authProvider.isDoctor) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select the correct account type."),
          ),
        );
        await authProvider.logout();
        return;
      }
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
    );
  }

  //---------------------------------------------------------
  // Forgot Password
  //---------------------------------------------------------
  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter your email first."),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.sendPasswordReset(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password reset email sent."),
      ),
    );
  }

  //---------------------------------------------------------
  // Login Button
  //---------------------------------------------------------
  Widget _loginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: auth.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "SIGN IN",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        );
      },
>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
    );
  }
    @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Top Logo
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add_box_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'Welcome to\nSmart Hospital',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A5A5C),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to manage appointments,\nqueue and medical records.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 40),
                // Select Account Section
                const Text(
                  'SELECT ACCOUNT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildRoleCard('Patient', Icons.person_rounded, 'patient')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRoleCard('Doctor', Icons.medical_services_rounded, 'doctor')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRoleCard('Admin', Icons.security_rounded, 'admin')),
                  ],
                ),
                const SizedBox(height: 32),
                // Email
                const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(Icons.email_outlined, 'Enter your email'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 20),
                // Password
                const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    Icons.lock_outline_rounded,
                    'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In Button
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SIGN IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 24),
                const Row(children: [
                  Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                ]),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                      child: const Text('Create Account', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
=======
    return Scaffold(
      backgroundColor: const Color(0xffF4F7F8),
      body: SafeArea(
        bottom: true,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Form(
              key: _formKey,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 430,
                ),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //------------------------------------------------
                    // Logo
                    //------------------------------------------------
                    Center(
                      child: Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    //------------------------------------------------
                    // Heading
                    //------------------------------------------------
                    const Text(
                      "Welcome to\nSmart Hospital",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Sign in to manage appointments,\nqueue and medical records.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 35),
                    //------------------------------------------------
                    // Account Type
                    //------------------------------------------------
                    Text(
                      "SELECT ACCOUNT",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _roleCard(
                          title: "Patient",
                          icon: Icons.person,
                          value: "patient",
                        ),
                        _roleCard(
                          title: "Doctor",
                          icon: Icons.medical_services,
                          value: "doctor",
                        ),
                        _roleCard(
                          title: "Admin",
                          icon: Icons.admin_panel_settings,
                          value: "admin",
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    //------------------------------------------------
                    // Email
                    //------------------------------------------------
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _customField(
                      controller: _emailController,
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 22),
                    //------------------------------------------------
                    // Password
                    //------------------------------------------------
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _customField(
                      controller: _passwordController,
                      hint: "Enter your password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: const Text(
                          "Forgot Password?",
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _loginButton(),
                    const SizedBox(height: 28),
                    //--------------------------------------------
                    // Divider
                    //--------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    //--------------------------------------------
                    // Register
                    //--------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.signup,
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    //--------------------------------------------
                    // Footer
                    //--------------------------------------------
                    Text(
                      "© 2026 Smart Hospital\nHealthcare Made Simple",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        height: 1.5,
                      ),
>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text('© ${DateTime.now().year} Smart Hospital\nHealthcare Made Simple', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildRoleCard(String label, IconData icon, String role) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF5F7F7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      suffixIcon: suffixIcon,
      fillColor: const Color(0xFFF5F7F7),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
=======
>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
}