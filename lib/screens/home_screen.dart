import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/custom_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white, // White background for a cleaner look
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo with fade-in animation
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100, // Soft accent background
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.heartbeat,
                          size: 80,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome to PreDiaCare',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Darker text for readability
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your health companion for a better life.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Sign In and Sign Up buttons with text below
                FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Sign In',
                        onPressed: () {
                          Navigator.pushNamed(context, '/signin');
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signin');
                        },
                        child: Text(
                          "Already have an account? Sign in",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 60, 142, 64), 
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                            text: 'Sign Up',
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                          ),

                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          "New here? Create an account",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 60, 142, 64), 
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
      ),
    );
  }
}
