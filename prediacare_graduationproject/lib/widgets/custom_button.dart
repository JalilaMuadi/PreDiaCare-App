import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary; // New property to differentiate buttons

const CustomButton({
  super.key, // Use 'super' directly
  required this.text,
  required this.onPressed,
  this.isPrimary = true,
});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55, // More height for better touch response
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.green.shade600 : Colors.transparent, // Filled vs Outline
          foregroundColor: isPrimary ? Colors.white : Colors.green.shade600, // Text color
          elevation: isPrimary ? 3 : 0, // Light shadow for primary
          side: isPrimary ? null : BorderSide(color: Colors.green.shade600, width: 2), // Border for secondary button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 16), // Better padding
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
