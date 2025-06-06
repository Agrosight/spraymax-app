import 'dart:io';

import 'package:arbomonitor/modules/aplicacao/entities.dart';
import 'package:arbomonitor/modules/armadilhaOvo/entities.dart';
// import 'package:arbomonitor/modules/common/consts.dart';
import 'package:arbomonitor/modules/common/utils.dart' as utils;
import 'package:arbomonitor/modules/di/di.dart';
import 'package:arbomonitor/modules/vistoriaResidencial/entities.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

BoxDecoration leftButtonDecoration() {
  return const BoxDecoration(
    border: Border(
      top: BorderSide(width: 1, color: Colors.grey),
      right: BorderSide(width: 0.5, color: Colors.grey),
    ),
    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4)),
  );
}

BoxDecoration leftButtonDecorationWithoutTopBorder() {
  return const BoxDecoration(
    border: Border(
      right: BorderSide(width: 0.5, color: Colors.grey),
    ),
    borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(4), topLeft: Radius.circular(4)),
  );
}

BoxDecoration rightButtonDecoration() {
  return const BoxDecoration(
    border: Border(
      top: BorderSide(width: 1, color: Colors.grey),
      left: BorderSide(width: 0.5, color: Colors.grey),
    ),
    borderRadius: BorderRadius.only(bottomRight: Radius.circular(4)),
  );
}

BoxDecoration rightButtonDecorationWithoutTopBorder() {
  return const BoxDecoration(
    border: Border(
      left: BorderSide(width: 0.5, color: Colors.grey),
    ),
    borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(4), topRight: Radius.circular(4)),
  );
}

BoxDecoration centerButtonDecoration() {
  return const BoxDecoration(
    border: Border(
      top: BorderSide(width: 1, color: Colors.grey),
      left: BorderSide(width: 0.5, color: Colors.grey),
      right: BorderSide(width: 0.5, color: Colors.grey),
    ),
    borderRadius: BorderRadius.only(bottomRight: Radius.circular(4)),
  );
}

BoxDecoration oneButtonDecoration() {
  return const BoxDecoration(
    border: Border(
      top: BorderSide(width: 1, color: Colors.grey),
    ),
    borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
  );
}

BoxDecoration oneButtonDecorationRed() {
  return const BoxDecoration(
    color: Color.fromRGBO(255, 93, 85, 1),
    // border: Border(
    //   top: BorderSide(width: 1, color: Colors.grey),
    // ),
    borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
  );
}

BoxDecoration textBorderDecoration() {
  return const BoxDecoration(
    border: Border(
      top: BorderSide(width: 1, color: Colors.grey),
      bottom: BorderSide(width: 1, color: Colors.grey),
      right: BorderSide(width: 1, color: Colors.grey),
      left: BorderSide(width: 1, color: Colors.grey),
    ),
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
}

showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black,
        elevation: 10,
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(message, style: TextStyle(fontSize: 16),),
        actionsPadding: EdgeInsets.zero,
        actions: [
          Row(
            children: [
              _okButton(context),
            ],
          ),
        ],
      );
    },
  );
}

_okButton(BuildContext context) {
  return Expanded(
    child: Container(
      width: double.infinity,
      decoration: oneButtonDecoration(),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: const Text('OK', style: TextStyle(fontSize: 20, color: Colors.blue),),
      ),
    ),
  );
}

Widget textWithBorder(String text, double fontSize) {
  return Expanded(
    child: Container(
      decoration: textBorderDecoration(),
      child: Container(
        padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    ),
  );
}

Widget textInput({
  double? fontSize,
  TextEditingController? controller,
  String? text,
  String? hintText,
  Color? labelTextColor,
  FocusNode? focusNode,
  String? Function(String?)? validator,
  AutovalidateMode? autovalidateMode,
  EdgeInsetsGeometry? padding,
  bool? readOnly,
  List<TextInputFormatter>? inputFormatters,
  void Function(String)? onFieldSubmitted,
  IconData? icon,
  bool? enable,
  Color? fontColor,
  TextInputType? keyboardType,
  TextCapitalization textCapitalization = TextCapitalization.none,
  String? errorText,
  int? maxLines,
  int? minLines,
  bool autoGrow = false,
  TextAlignVertical? textAlignVertical,
  double? height,
  bool required = false,
  bool? obscureText,
  Widget? suffixIcon,
  
}) {
  return Padding(
    padding: padding ?? const EdgeInsets.only(bottom: 8),
    child: SizedBox(
      height: height,
      child: Card(
        color: const Color(0xFFFAF9F9),
        shadowColor: Colors.grey,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: TextFormField(
                  obscureText: obscureText ?? false,
                  enabled: enable,
                  controller: controller,
                  focusNode: focusNode,
                  validator: validator ??
                      (required
                          ? (value) {
                              if (required && (value == null || value.trim().isEmpty)) {
                                return "Campo obrigatório";
                              }
                              return null;
                            }
                          : null),
                  autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
                  readOnly: readOnly ?? true,
                  inputFormatters: inputFormatters,
                  onFieldSubmitted: onFieldSubmitted,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  style: TextStyle(fontSize: fontSize ?? 16, color: fontColor),

                  minLines: autoGrow ? (minLines ?? 1) : null,
                  maxLines: autoGrow ? (maxLines ?? null) : 1,
                  expands: !autoGrow && height != null,
                  textAlignVertical: autoGrow
                      ? textAlignVertical ?? TextAlignVertical.center
                      : textAlignVertical ?? TextAlignVertical.top,

                  decoration: InputDecoration(
                    suffixIcon: suffixIcon,
                    labelText: hintText,
                    labelStyle: TextStyle(
                      color: labelTextColor ?? Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: InputBorder.none,
                    isDense: true,
                    // contentPadding: const EdgeInsets.only(top: 8),
                    errorText: errorText,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: icon != null
                  ? Icon(
                      icon,
                      color: Colors.grey,
                      size: 24,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget formInfoTitle({
  String text = '', 
  IconData? icon, 
  Color? iconColor,

  }) {
  return ListTile(
    textColor: Colors.black,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    leading: icon != null ? Icon(icon) : null,
    iconColor: iconColor ?? Colors.blue,
    title: Text(text),
  );
}

class CustomDropdownFormField extends StatelessWidget {
  final String? value;
  final String labelText;
  final TextStyle? labelStyle;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;
  final GlobalKey<FormFieldState>? dropdownKey;
  final double fontSize;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final double? height;

  const CustomDropdownFormField({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.dropdownKey,
    this.fontSize = 20,
    this.validator,
    this.autovalidateMode,
    this.decoration,
    this.labelStyle,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
          key: dropdownKey,
          value: value,
          dropdownColor: Colors.white,
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: autovalidateMode,
          isExpanded: true,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            // isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            labelText: labelText,
            labelStyle: labelStyle ?? const TextStyle(color: Colors.blue),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          items: items,
        ),
    );
  }


  // InputDecoration _defaultDecoration() {
  //   return InputDecoration(
  //     // isDense: true,
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
  //     labelText: labelText,
  //     labelStyle: labelStyle ?? const TextStyle(color: Colors.blue),
  //     filled: true,
  //     fillColor: Colors.white,
  //     enabledBorder: OutlineInputBorder(
  //       borderSide: const BorderSide(color: Colors.blue, width: 2),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderSide: const BorderSide(color: Colors.blue, width: 2),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     errorBorder: OutlineInputBorder(
  //       borderSide: const BorderSide(color: Colors.red, width: 2),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     focusedErrorBorder: OutlineInputBorder(
  //       borderSide: const BorderSide(color: Colors.red, width: 2),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //   );
  // }
}


class ArmadilhaCard extends StatelessWidget {
  final String id;
  final String endereco;
  final String lastVisitAt;
  final ArmadilhaOvo armadilhaOvo;

  const ArmadilhaCard({
    super.key,
    required this.id,
    required this.endereco,
    required this.lastVisitAt,
    required this.armadilhaOvo,
  });

  @override
  Widget build(BuildContext context) {
    
    String dataVisita = utils.dateFormatWithT(armadilhaOvo.instaladoEm);
    String lastVisitAt = "Instalado em: $dataVisita";
    if (armadilhaOvo.visitadoEm.isNotEmpty) {
      dataVisita = utils.dateFormatWithT(armadilhaOvo.visitadoEm);
      lastVisitAt = "Visitado em: $dataVisita";
    }

    return Card(
      color: Colors.grey[200],
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            id,
                            style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            endereco,
                            style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastVisitAt,
                            style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            ),
                          ),
                      ],
                    ),),
                  )
                ],
              ),
            ),
            SizedBox(
              child: Container(
                alignment: Alignment.centerRight,
                child: _widgetColetarEm(armadilhaOvo),
              )
            )
          ],
        ),
      ),
    );
  }
}

  Widget _widgetColetarEm(ArmadilhaOvo armadilhaOvo) {
    if (armadilhaOvo.diasParaColeta < 0) {
      return Container(
        alignment: Alignment.center,
        width: 90,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromRGBO(255, 93, 85, 0.8),
        ),
        
        child: const Text(
          "ATRASADA",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (armadilhaOvo.diasParaColeta == 0) {
      return Container(
        alignment: Alignment.center,
        width: 90,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromRGBO(1, 106, 92, 0.8),
        ),
        child: Text(
          "HOJE",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      alignment: Alignment.center,
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color.fromRGBO(255, 199, 32, 0.8),
      ),
      child: Text(
        "EM ${armadilhaOvo.diasParaColeta} DIAS",
        style: TextStyle(
          color: Colors.grey[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

class CheckBoxNumber extends StatelessWidget {
  final bool value;
  final void Function(bool?)? onChanged;
  final String text;
  final Color? activeColor;

  const CheckBoxNumber({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
    this.activeColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(!value),
            child: Text(
              text,
              style: TextStyle(
                color: activeColor,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget iconButton(
  IconData icon, 
  double iconSize, 
  Color color, 
  AlignmentGeometry alignment,
  EdgeInsetsGeometry padding, 
  {void Function()? onPressed}) {

  return Container(
    padding: padding,
    child: IconButton(
      icon: Icon(icon),
      iconSize: iconSize,
      color: color,
      // padding: const EdgeInsets.all(5),
      alignment: alignment,
      onPressed: onPressed,
    ),
  );
}

// class ImageCarousel extends StatelessWidget {
//   final List<String> imagePaths;
//   final void Function(int index)? onImageTap;
//   final void Function(int index)? onDeleteTap;
//   final bool showDeleteButton;
//   final BorderRadiusGeometry? imageBorderRadius;

//   const ImageCarousel({
//     super.key,
//     required this.imagePaths,
//     this.onImageTap,
//     this.onDeleteTap,
//     this.showDeleteButton = true,
//     this.imageBorderRadius,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (imagePaths.isEmpty) return const SizedBox();

//     return Container(
//       margin: const EdgeInsets.all(8),
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: SizedBox(
//         height: 140,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           itemCount: imagePaths.length,
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           separatorBuilder: (_, __) => const SizedBox(width: 10),
//           itemBuilder: (context, index) => _buildItem(context, index),
//         ),
//       ),
//     );
//   }

//   Widget _buildItem(BuildContext context, int index) {
//     return GestureDetector(
//       onTap: () => onImageTap?.call(index),
//       child: Container(
//         width: MediaQuery.of(context).size.width / 3.5,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.grey[200],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Imagem
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: imageBorderRadius ?? BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
//                 child: imagePaths[index].startsWith('http')
//                   ? Image.network(
//                       imagePaths[index],
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//                     )
//                   : Image.file(
//                       File(imagePaths[index]),
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//                     ),
//                 ),
//             ),

//             if (showDeleteButton)
//               GestureDetector(
//                 onTap: () => onDeleteTap?.call(index),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Color.fromRGBO(255, 93, 85, 1),
//                     borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.delete, color: Colors.white, size: 24),
//                       SizedBox(width: 4),
//                       Text("Excluir", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final void Function(int index)? onImageTap;
  final void Function(int index)? onDeleteTap;
  final bool showDeleteButton;
  final BorderRadiusGeometry? imageBorderRadius;

  const ImageCarousel({
    super.key,
    required this.imagePaths,
    this.onImageTap,
    this.onDeleteTap,
    this.showDeleteButton = true,
    this.imageBorderRadius,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) return const SizedBox();

    final showAutoPlay = widget.imagePaths.length >= 3;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: widget.imagePaths.length < 3
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(widget.imagePaths.length, (index) {
                return Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  margin: const EdgeInsets.only(right: 8),
                  child: _buildItem(context, index),
                );
              }),
            )
            : CarouselSlider.builder(
              itemCount: widget.imagePaths.length,
              options: CarouselOptions(
                height: 140,
                viewportFraction: 0.33,
                enlargeCenterPage: false,
                autoPlay: showAutoPlay,
                autoPlayInterval: const Duration(seconds: 3),
                enableInfiniteScroll: widget.imagePaths.length > 3,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIdx) => _buildItem(context, index),
            ),
          ),
          if (showAutoPlay)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imagePaths.length, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: i == _currentPage ? 7 : 5,
                    width: i == _currentPage ? 7 : 5,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? Colors.black : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => widget.onImageTap?.call(index),
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem
            Expanded(
              child: ClipRRect(
                borderRadius: widget.imageBorderRadius ??
                    const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                child: widget.imagePaths[index].startsWith('http')
                    ? Image.network(
                        widget.imagePaths[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      )
                    : Image.file(
                        File(widget.imagePaths[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
            ),
            if (widget.showDeleteButton)
              GestureDetector(
                onTap: () => widget.onDeleteTap?.call(index),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 93, 85, 1),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 24),
                      SizedBox(width: 4),
                      Text("Excluir",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class VistoriaCard extends StatelessWidget {
  final VistoriaGroupEndereco vistoriaGroup;
  final double? height;

  const VistoriaCard({
    super.key,
    required this.vistoriaGroup,
    this.height,
  });

  @override
  Widget build (BuildContext context) {
    String dataVisita = utils.dateFormatWithHours(vistoriaGroup.vistorias.first.dataVistoria);

    return Card(
      color: Colors.grey[200],
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        height: height ?? 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${vistoriaGroup.endereco.rua}, ${vistoriaGroup.endereco.numero}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${vistoriaGroup.endereco.cidade}/${vistoriaGroup.endereco.codigoEstado}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                          Text(
                            "Visitado por: ${vistoriaGroup.vistorias.first.pessoaVistoria.nome}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                          Text(
                            "Última visita: $dataVisita",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Container(
                alignment: Alignment.centerRight,
                child: _buildStatusTag(vistoriaGroup.vistorias, height ?? 100),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildStatusTag(List<Vistoria> vistorias, double heightTag) {
  int totalFocos = vistorias.fold(0, (sum, v) => sum + v.focos.length);
  int hasFechadoCount = vistorias.where((v) => v.situacao.codigo == "F").length;
  int hasRecusadoCount = vistorias.where((v) => v.situacao.codigo == 'R').length;

  bool hasFechado = vistorias.any((v) => v.situacao.codigo == "F");
  bool hasRecusado = vistorias.any((v) => v.situacao.codigo == 'R');

  String text;
  Color color;

  String _pluralize(String singular, String plural, int count) {
    return count == 1 ? singular : plural;
  }

  if (hasFechado) {
    text = "$hasFechadoCount ${_pluralize("FECHADO", "FECHADOS", hasFechadoCount)}\n"
           "$totalFocos ${_pluralize("FOCO", "FOCOS", totalFocos)}";
    color = const Color.fromRGBO(255, 199, 32, 0.8);
  } else if (hasRecusado) {
    text = "$hasRecusadoCount ${_pluralize("RECUSADO", "RECUSADOS", hasRecusadoCount)}\n"
           "$totalFocos ${_pluralize("FOCO", "FOCOS", totalFocos)}";
    color = const Color.fromRGBO(255, 199, 32, 0.8);
  } else if (totalFocos > 0) {
    text = "$totalFocos ${_pluralize("FOCO", "FOCOS", totalFocos)}";
    color = const Color.fromRGBO(255, 93, 85, 0.8);
  } else {
    text = "SEM FOCO";
    color = const Color.fromRGBO(1, 106, 92, 0.8);
  }

  return Container(
    width: 90,
    height: heightTag,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
    ),
    alignment: Alignment.center,
    child: Text(
      text,
      style: hasFechado || hasRecusado
      ? TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.bold,
      )
      : TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

class AplicacaoCard extends StatelessWidget {
  // final String id;
  // final String endereco;
  // final String lastVisitAt;
  final AtividadeAplicacao atividade;

  const AplicacaoCard({
    super.key,
    // required this.id,
    // required this.endereco,
    // required this.lastVisitAt,
    required this.atividade, 
    required trailing,
  });

  @override
  Widget build(BuildContext context) {
    final String titulo = atividade.activity.field.name;

    final String cidade_estado = atividade.activity.field.organizacao.name;
    final String ciclos = "Ciclos: ${atividade.executedCycles}/${atividade.totalCycles}";
    // final String subtitulo = "$uf\n $ciclos";

    return Card(
      color: Colors.grey[200],
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cidade_estado,
                            style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ciclos,
                            style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),),
                  )
                ],
              ),
            ),
            SizedBox(
              child: Container(
                alignment: Alignment.centerRight,
                child: _widgetExecutarEm(atividade),
              )
            )
          ],
        ),
      ),
    );
  }
}

  Widget _widgetExecutarEm(AtividadeAplicacao atividade) {
    DateTime now = DateTime.now();
    String dateString = now.toString().substring(0, 10);
    if (atividade.nextApplication.compareTo(dateString) < 0) {
      return Container(
        alignment: Alignment.center,
        width: 90,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromRGBO(255, 93, 85, 0.8),
        ),
        
        child: const Text(
          "ATRASADA",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (atividade.nextApplication.compareTo(dateString) == 0) {
      return Container(
        alignment: Alignment.center,
        width: 90,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromRGBO(1, 106, 92, 0.8),
        ),
        child: Text(
          "HOJE",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    int dias = utils.daysToNow(atividade.nextApplication);
    return Container(
      alignment: Alignment.center,
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color.fromRGBO(255, 199, 32, 0.8),
      ),
      child: Text(
        "EM $dias DIAS",
        style: TextStyle(
          color: Colors.grey[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

