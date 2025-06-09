import 'package:flutter/material.dart';
import 'package:spraymax/modules/common/collor.dart'; 

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primarySwatch: CustomColor.colorLightPrimarySwatch,
  primaryColor: CustomColor.primaryColor,
  scaffoldBackgroundColor: CustomColor.backgroundColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: CustomColor.primaryColor,
    primary: CustomColor.primaryColor,
    secondary: CustomColor.secundaryColor,
    error: CustomColor.errorColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: Colors.grey), 
    floatingLabelStyle: const TextStyle(color: CustomColor.primaryColor),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: CustomColor.primaryColor),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: CustomColor.errorColor),
    ),
    focusedErrorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: CustomColor.errorColor),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      return states.contains(WidgetState.selected)
          ? CustomColor.primaryColor
          : Colors.grey;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      return states.contains(WidgetState.selected)
          ? CustomColor.primaryColor
          : Colors.grey;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      return states.contains(WidgetState.selected)
          ? CustomColor.primaryColor.withValues(alpha: 0.5)
          : Colors.grey.withValues(alpha:0.3);
    }),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: CustomColor.primaryColor,
    selectionColor: CustomColor.primaryColor.withValues(alpha:.3),
    selectionHandleColor: CustomColor.primaryColor,
  ),
);