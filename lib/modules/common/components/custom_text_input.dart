import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditableRoundedInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool obscureText;

  // Novo: ícone customizável
  final Icon? suffixIcon;

  // Novo: função ao clicar no ícone
  final VoidCallback? onSuffixIconPressed;

  // Novo: permitir forçar edição externa
  final bool? readOnlyOverride;

  const EditableRoundedInput({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.readOnlyOverride,
  });

  @override
  State<EditableRoundedInput> createState() => _EditableRoundedInputState();
}

class _EditableRoundedInputState extends State<EditableRoundedInput> {
  bool isEditable = false;

  @override
  Widget build(BuildContext context) {
    final bool effectiveReadOnly = widget.readOnlyOverride ?? !isEditable;

    return TextFormField(
      controller: widget.controller,
      readOnly: effectiveReadOnly,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: widget.suffixIcon != null
            ? IconButton(
                icon: widget.suffixIcon!,
                onPressed: widget.onSuffixIconPressed,
              )
            : IconButton(
                icon: Icon(
                  isEditable ? Icons.check : Icons.edit,
                  color: isEditable ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isEditable = !isEditable;
                  });
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class EditableRoundedInput extends StatefulWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final TextInputType keyboardType;
//   final List<TextInputFormatter>? inputFormatters;
//   final FormFieldValidator<String>? validator;
//   final bool obscureText;

//   const EditableRoundedInput({
//     super.key,
//     required this.controller,
//     required this.labelText,
//     this.keyboardType = TextInputType.text,
//     this.inputFormatters,
//     this.validator,
//     this.obscureText = false,
//   });

//   @override
//   State<EditableRoundedInput> createState() => _EditableRoundedInputState();
// }

// class _EditableRoundedInputState extends State<EditableRoundedInput> {
//   bool isEditable = false;

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: widget.controller,
//       readOnly: !isEditable,
//       keyboardType: widget.keyboardType,
//       inputFormatters: widget.inputFormatters,
//       obscureText: widget.obscureText,
//       validator: widget.validator,
//       decoration: InputDecoration(
//         labelText: widget.labelText,
//         floatingLabelBehavior: FloatingLabelBehavior.auto,
//         suffixIcon: IconButton(
//           icon: Icon(
//             isEditable ? Icons.check : Icons.edit,
//             color: isEditable ? Colors.green : Colors.grey,
//           ),
//           onPressed: () {
//             setState(() {
//               isEditable = !isEditable;
//             });
//           },
//         ),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: const BorderSide(color: Colors.grey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: const BorderSide(color: Colors.blue),
//         ),
//       ),
//     );
//   }
// }
