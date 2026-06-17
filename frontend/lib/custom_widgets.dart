import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.blue[800]),
          suffixIcon: widget.isPassword
              ? IconButton(
                  tooltip: _obscureText
                      ? 'Afficher le mot de passe'
                      : 'Masquer le mot de passe',
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue[800],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}


