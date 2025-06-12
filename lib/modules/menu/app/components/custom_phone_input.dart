import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPhoneInput extends StatefulWidget {
  final String labelText;
  final String selectedAreaCode;
  final Function(String?) onAreaCodeChanged;
  final TextEditingController phoneController;
  final bool enabled;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomPhoneInput({
    super.key,
    required this.labelText,
    required this.selectedAreaCode,
    required this.onAreaCodeChanged,
    required this.phoneController,
    this.enabled = true,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<CustomPhoneInput> createState() => _CustomPhoneInputState();
}

List<Map<String, String>> codeAreaData = [
  {"codigo": "+55", "pais": "Brasil", "bandeira": "🇧🇷"},
  {"codigo": "+1", "pais": "Estados Unidos", "bandeira": "🇺🇸"},
  {"codigo": "+44", "pais": "Reino Unido", "bandeira": "🇬🇧"},
  {"codigo": "+33", "pais": "França", "bandeira": "🇫🇷"},
  {"codigo": "+49", "pais": "Alemanha", "bandeira": "🇩🇪"},
  {"codigo": "+34", "pais": "Espanha", "bandeira": "🇪🇸"},
  {"codigo": "+39", "pais": "Itália", "bandeira": "🇮🇹"},
  {"codigo": "+7",  "pais": "Rússia", "bandeira": "🇷🇺"},
  {"codigo": "+81", "pais": "Japão", "bandeira": "🇯🇵"},
  {"codigo": "+86", "pais": "China", "bandeira": "🇨🇳"},
];

class _CustomPhoneInputState extends State<CustomPhoneInput> {
  bool isEditable = false;
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.selectedAreaCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showCodePicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Selecionar código'),
        children: codeAreaData
            .map((area) {
              final display = "${area['codigo']} ${area['bandeira']} ${area['pais']}";
              return SimpleDialogOption(
                onPressed: () => Navigator.pop(context, area['codigo']),
                child: Text(display),
              );
            })
            .toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        _codeController.text = selected;
      });
      widget.onAreaCodeChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Código de área
        SizedBox(
          width: 100,
          height: 64,
          child: TextFormField(
            controller: _codeController,
            readOnly: true,
            onTap: isEditable ? _showCodePicker : null,
            decoration: const InputDecoration(
              labelText: "Código",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
          ),
        ),

        // Campo de número
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextFormField(
                controller: widget.phoneController,
                inputFormatters: widget.inputFormatters,
                enabled: isEditable,
                keyboardType: TextInputType.phone,
                validator: widget.validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: "Telefone",
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              IconButton(
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
            ],
          ),
        ),
      ],
    );
  }
}
