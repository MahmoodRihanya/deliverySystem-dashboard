import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6B35); 
  static final Color stare = Colors.amber.shade600;
  static const Color pink = Color(0xFFFFE5D9); 
  static const Color secondary = Color.fromARGB(255, 189, 101, 38);
  static const Color white = Color(0xFFFFFDF7); 
  static const Color black = Color(0xFF3E2723); 
  
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
