import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedSex;
  String? _selectedGovernorate;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> _governorates = [
    'Nablus', 'Qalqilya', 'Tubas', 'Salfit', 'Tulkarm',
    'Jenin', 'Jericho', 'Ramallah', 'Bethlehem',
    'Hebron', 'Jerusalem', 'Gaza Strip'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Email Field
                _buildInputField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password Field with Eye Icon
                _buildInputField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password Field with Eye Icon
                _buildInputField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  icon: Icons.lock,
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age Field
                _buildInputField(
                  controller: _ageController,
                  labelText: 'Age',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Sex Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  hint: const Text("Choose Gender", style: TextStyle(color: Colors.black54)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  items: const ['Male', 'Female'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() {
                    _selectedSex = newValue;
                  }),
                  validator: (value) => value == null ? 'Please select your gender' : null,
                ),
                const SizedBox(height: 16),

                // Governorate Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGovernorate,
                  hint: const Text("Choose Governorate", style: TextStyle(color: Colors.black54)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  items: _governorates.map((gov) {
                    return DropdownMenuItem<String>(
                      value: gov,
                      child: Text(gov),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() {
                    _selectedGovernorate = newValue;
                  }),
                  validator: (value) => value == null ? 'Please select your governorate' : null,
                ),
                const SizedBox(height: 24),

                // Sign-Up Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: 'Sign Up',
                        onPressed: _signUp,
                      ),
                const SizedBox(height: 16),

                // Already have an account?
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signin'),
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.green),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        _emailController.text.trim(),
      );

      if (signInMethods.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "This email is already registered. Please sign in.";
        });
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'sex': _selectedSex,
        'governorate': _selectedGovernorate,
      });

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/complete-profile');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message ?? "Authentication error.";
        });
      }
    }
  }
}
