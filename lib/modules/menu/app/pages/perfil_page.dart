import 'dart:convert';

import 'package:arbomonitor/modules/auth/usecases.dart';
import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/menu/app/pages/side_menu.dart';
import 'package:arbomonitor/modules/menu/usecases.dart';
import 'package:arbomonitor/modules/vistoriaResidencial/app/pages/vistorias_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:arbomonitor/modules/common/consts.dart';
import 'package:arbomonitor/modules/menu/app/controller/perfil_page_controller.dart';
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

  String selectedCodeArea = "+55";

  List<DropdownMenuItem<String>> codeAreaList = [
    DropdownMenuItem(value: "+55", child: Text("+55")),
    DropdownMenuItem(value: "+1", child: Text("+1")),
    DropdownMenuItem(value: "+44", child: Text("+44")),
    DropdownMenuItem(value: "+33", child: Text("+33")),
    DropdownMenuItem(value: "+49", child: Text("+49")),
    DropdownMenuItem(value: "+34", child: Text("+34")),
    DropdownMenuItem(value: "+39", child: Text("+39")),
    DropdownMenuItem(value: "+7", child: Text("+7")),
    DropdownMenuItem(value: "+81", child: Text("+81")),
    DropdownMenuItem(value: "+86", child: Text("+86")),
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
        appBar: _appBar(),
        body: _formContainer(),
        bottomNavigationBar: _bottomButtons(),
      ),
    );
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      //foregroundColor: Colors.black,
      title: const Text("Meu Perfil",
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => _menuButtonWidget(context),
        ),
      );
  }

  _menuButtonWidget(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer());
  }

  _formContainer() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                formInfoTitle(text: "Contatos", icon: Icons.contact_page, iconColor: Color.fromRGBO(1, 106, 92, 1)),
                _contatoSection(),
                formInfoTitle(text: "Alterar Senha", icon: Symbols.passkey, iconColor: Color.fromRGBO(1, 106, 92, 1)),
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
          textInput(
            controller: TextEditingController(
              text: perfilPageController.user.value.email
            ),
            hintText: "E-mail",
            keyboardType: TextInputType.emailAddress,
            readOnly: false,
            enable: true,
            icon: Icons.edit,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obrigatório";
              }
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _areaCode(),
              ),
              Expanded(
                flex:2,
                child: _phoneNumber(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _phoneNumber() {
    return textInput(
      controller: phoneController,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.phone,
      inputFormatters: [phoneMaskFormatter],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: false,
      hintText: "Contato",
      fontSize: 16,
      icon: Icons.edit,
      onFieldSubmitted: (value) {
        if (value.length < 15) {
          phoneController.value = phoneMaskFormatter.updateMask(mask: "(##) ####-#####");
        } else {
          phoneController.value = phoneMaskFormatter.updateMask(mask: "(##) #####-####");
        }
      },
      validator: (value) {
        if (value == null || value.toString().trim().isEmpty) {
          return "Campo obrigatório";
        }
        if (value.length < 14) {
          return "Insira um telefone de contato válido";
        }
        return null;
      },
    );
  }

  _areaCode() {
    return CustomDropdownFormField(
      items: codeAreaList,
      value: selectedCodeArea,
      onChanged: (value) {
        setState(() {
          selectedCodeArea = value!;
        });
      },
      labelText: "Código de Área",
      labelStyle: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
      height: 70,
      decoration: InputDecoration(
        labelText: "Código de Área",
        labelStyle: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFFAF9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      // icon: Icons.arrow_drop_down,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo obrigatório";
        }
        return null;
      },
    );
  }

  _passwordSection() {
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textInput(
                controller: newPasswordController,
                hintText: "Nova Senha",
                obscureText: _obscureNewPassword,
                readOnly: false,
                enable: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    size: 24,
                    _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                validator: _passwordValidator(),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              textInput(
                controller: confirmPasswordController,
                hintText: "Confirmar Senha",
                obscureText: _obscureConfirmPassword,
                readOnly: false,
                enable: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    size: 24,
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: _confirmPasswordValidator(),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
        );
      },
    );
  }

  _passwordValidator() {
    return (String? value) {
      // if (value == null || value.isEmpty) {
      //   return "Campo obrigatório";
      // }
      if (value != null && value.isNotEmpty) {
        if (value!.length < 8) {
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
              if (result == "salvar") {
                // Salvar as alterações
                perfilPageController.updateUserName(confirmPasswordController.text);
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const VistoriasPage(),
                  ),);
                refreshPage();
              }
              else if (result == "cancelar") {
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(fontSize: 20, color: Colors.blue,),
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
        ) ,
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
        decoration: rightButtonDecoration(),
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