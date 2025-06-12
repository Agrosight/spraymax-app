import 'dart:convert';

import 'package:spraymax/modules/common/components/custom_appbar.dart';
import 'package:spraymax/modules/menu/app/components/custom_phone_input.dart';
import 'package:spraymax/modules/common/components/custom_text_input.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/menu/app/pages/side_menu.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/vistorias_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:spraymax/modules/menu/app/controller/perfil_page_controller.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:material_symbols_icons/symbols.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  PerfilPageController perfilPageController = PerfilPageController();
  final perfilFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  String selectedCodeArea = "+55";
  bool accepted = false;
  
  final List<String> codeAreaList = [
    "+55",
    "+1",
    "+44",
    "+33",
    "+49",
    "+34",
    "+39",
    "+7",
    "+81",
    "+86",
  ];

  final MaskTextInputFormatter phoneMaskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        drawer: const SideMenu(),
        appBar: CustomAppBar(title: "Meu Perfil"),
        body: _formContainer(),
        bottomNavigationBar: _bottomButtons(),
      ),
    );
  }



  _formContainer() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 40, bottom: 10, left: 30, right: 30),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _userAvatar(),
                    const SizedBox(height: 10),
                    _userName(),
                  ],
                ),
                formInfoTitle(text: "Contatos", icon: Symbols.contact_mail_sharp, iconColor: Color.fromRGBO(1, 106, 92, 1)),
                _contatoSection(),
                formInfoTitle(text: "Alterar Senha", icon: Symbols.lock_sharp, iconColor: Color.fromRGBO(1, 106, 92, 1)),
                _passwordSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  refreshPage() {
    setState(() {});
  }

  _userAvatar() {
    return Observer(
      builder: (_) {
        final user = perfilPageController.user.value;
        final avatarUrl = user.userAvatar;
        final initials = _getInitials(user.fullName);

        return CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: (avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
          child: (avatarUrl.isEmpty)
              ? Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        );
      },
    );
  }

  String _getInitials(String name) {
    final names = name.trim().split(' ');
    if (names.length >= 2) {
      return (names[0][0] + names[1][0]).toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0].substring(0, 1).toUpperCase();
    } else {
      return "";
    }
  }


  _userName() {
    return Observer(
      builder: (_) {
        final fullName = utf8.decode(latin1.encode(perfilPageController.user.value.fullName));

        if (fullName.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            _showEditNameDialog();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8), 
              const Icon(
                Icons.edit,
                size: 24,
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  

  _contatoSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditableRoundedInput(
            controller: TextEditingController(
              text: perfilPageController.user.value.email
            ), 
            labelText: "E-mail"
          ),
          SizedBox(height: 15),
          CustomPhoneInput(
            labelText: "Telefone",
            selectedAreaCode: selectedCodeArea,
            onAreaCodeChanged: (value) {
              setState(() {
                selectedCodeArea = value!;
              });
            },
            phoneController: phoneController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          Row(
            children: [
              Checkbox(
                value: accepted,
                onChanged: (bool? value) {
                  setState(() {
                    accepted = value ?? false;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  "Aceito receber informações via WhatsApp",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _passwordSection() {
    return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textInput(
                controller: newPasswordController,
                hintText: "Nova Senha",
                obscureText: obscureNewPassword,
                readOnly: false,
                enable: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    size: 24,
                    obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureNewPassword = !obscureNewPassword;
                    });
                  },
                ),
                validator: _passwordValidator(),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              textInput(
                controller: confirmPasswordController,
                hintText: "Confirmar Senha",
                obscureText: obscureConfirmPassword,
                readOnly: false,
                enable: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    size: 24,
                    obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
                validator: _confirmPasswordValidator(),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
        );
      
    
  }

  _passwordValidator() {
    return (String? value) {
      // if (value == null || value.isEmpty) {
      //   return "Campo obrigatório";
      // }
      if (value != null && value.isNotEmpty) {
        if (value.length < 8) {
          return "A senha deve ter pelo menos 8 caracteres";
        }
        if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return "A senha deve conter pelo menos uma letra maiúscula";
        }
        if (!RegExp(r'[a-z]').hasMatch(value)) {
          return "A senha deve conter pelo menos uma letra minúscula";
        }
        if (!RegExp(r'[0-9]').hasMatch(value)) {
          return "A senha deve conter pelo menos um número";
        }
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
          return "A senha deve conter pelo menos um caractere especial";
        }
      }
      return null;
    };
  }

  _confirmPasswordValidator() {
    return (String? value) {
      if (newPasswordController.text.isEmpty) {
        return null;
      }
      else if (newPasswordController.text.isNotEmpty) {
        if (value == null || value.isEmpty) {
          return "Confirme a nova senha";
        }
        if (value != newPasswordController.text) {
          return "As senhas não são iguais";
        }
        // Aplica as mesmas validações de senha
        if (value.length < 8) {
          return "A senha deve ter pelo menos 8 caracteres";
        }
        if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return "A senha deve conter pelo menos uma letra maiúscula";
        }
        if (!RegExp(r'[a-z]').hasMatch(value)) {
          return "A senha deve conter pelo menos uma letra minúscula";
        }
        if (!RegExp(r'[0-9]').hasMatch(value)) {
          return "A senha deve conter pelo menos um número";
        }
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
          return "A senha deve conter pelo menos um caractere especial";
        }
      }
      return null;
    };
  }

//TODO Verificar se a função está funcionando corretamente
  bool hasPendingChanges() {
    return perfilPageController.hasPendingChanges(
      email: emailController.text,
      phone: phoneController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
      codeAreaList: selectedCodeArea,
    );
  }
_bottomButtons() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () async {
            bool hasPendingChanges = perfilPageController.hasPendingChanges(
              email: emailController.text,
              phone: phoneController.text,
              newPassword: newPasswordController.text,
              confirmPassword: confirmPasswordController.text,
              codeAreaList: selectedCodeArea,
            );

            if (!hasPendingChanges) {
              if (!mounted) return;
              Navigator.pop(context);
              return;
            }

            final result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.black,
                  elevation: 10,
                  title: const Text(
                    "Cancelar Edição",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    "Você tem alterações pendentes. Deseja cancelar?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  actionsPadding: EdgeInsets.zero,
                  actions: [
                    Row(
                      children: [
                        _dialogActionCancelUpdates(),
                        _dialogActionSaveUpdates(),
                      ]
                    ),
                  ],
                );
              },
            );

            if (!mounted) return;

            if (result == "salvar") {
              perfilPageController.updateUserName(confirmPasswordController.text);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const VistoriasPage(),
                ),
              );
              refreshPage();
            } else if (result == "cancelar") {
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            "Cancelar",
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
        TextButton(
          onPressed: () {
            // lógica para salvar
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          child: const Text(
            "Salvar",
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}

  _showEditNameDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Editar Nome",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: TextEditingController(
              text: perfilPageController.user.value.fullName
            ),
            decoration: const InputDecoration(
              hintText: "Digite seu nome",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
              border: OutlineInputBorder(),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirm(),
              ]
            ),
          ],
        );
      },
    );
  }

  _dialogActionCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancelar",
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      )
    );
  }

  _dialogActionConfirm() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            perfilPageController.updateUserName(confirmPasswordController.text);
            Navigator.pop(context);
          },
          child: const Text(
            "Confirmar",
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      )
    );
  }

  _dialogActionSaveUpdates() {
    // Salvar as alterações
    return Expanded(
      child: Container(
        width: double.infinity,
        //decoration: rightButtonDecoration(),
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () {
            if (perfilFormKey.currentState!.validate()) {
              perfilPageController.saveProfile(
                email: emailController.text,
                phone: phoneController.text,
                newPassword: newPasswordController.text,
                confirmPassword: confirmPasswordController.text,
                codeAreaList: selectedCodeArea,
              );
              Navigator.pop(context, "salvar");
            }
          },
          child: const Text(
            "Salvar",
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      ),
    );
  }

  _dialogActionCancelUpdates() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () => Navigator.pop(context, "cancelar"), //TODO: Apenas fechar o dialog
          child: const Text(
            "Cancelar",
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      )
    );
  }
}