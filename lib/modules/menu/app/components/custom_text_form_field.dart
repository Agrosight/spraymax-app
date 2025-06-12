import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spraymax/modules/common/collor.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final Widget? suffixIcon;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.keyboardType,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.focusNode,
    this.suffixIcon, 
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
          labelStyle: const TextStyle(color: Colors.grey), 
          floatingLabelStyle: const TextStyle(color: CustomColor.primaryColor),
        suffixIcon: suffixIcon, 

        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColor.primaryColor), 
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), 
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColor.errorColor), 
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColor.errorColor), 
        ),
      ),
      
    );
  }
}
