import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // Define los colores base para el tema
    const Color primaryColor = Color(0xFF9368D9); // Un tono base de morado
    const Color listViewItemBackgroundColor = Color(0xFFB19DD1); // Un tono base de morado
    const Color lightPurple = Color(0xFF4f2f83); // Un morado más claro
    const Color darkPurple = Color(0xFF4C2A84); // Un morado más oscuro
    const Color listItemColor = Color(0xFFE1BEE7); // Un lila claro para los elementos de la lista
    const Color textColor =
        Colors.white; // Texto blanco para el resto de la aplicación
    const Color dialogTextColor = Colors.black; // Texto negro para los diálogos

    return ThemeData(
      // Configuración básica del tema
      brightness: Brightness.light,
      primaryColor: primaryColor,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        color: Colors.transparent,
        titleTextStyle: TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),

      // Configuración del tema de texto por defecto
      textTheme: TextTheme(
        headline6: TextStyle(
            color: textColor,
            fontSize: 20.0,
            fontWeight: FontWeight.bold), // Para títulos grandes en la app
        bodyText2: TextStyle(
            color: textColor), // Estilo por defecto para el cuerpo del texto
        bodyText1: TextStyle(
            color:
                textColor), // Estilo por defecto para el cuerpo del texto más grande
      ),

      // Colores de fondo para scaffold y otros contenedores
      scaffoldBackgroundColor: lightPurple,

      // Configuración del botón
      buttonTheme: ButtonThemeData(
        buttonColor: darkPurple,
        textTheme: ButtonTextTheme.primary,
      ),
      // Configuración del tema de listas
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,

        textColor: textColor,
        iconColor: textColor,
      ),

      // Configuración de los colores de los Floating Action Buttons
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPurple,
      ),

      // Configuración del tema de diálogos
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(
            color: dialogTextColor,
            fontSize: 20.0,
            fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: dialogTextColor),
      ),

      // Configuración adicional para otros widgets si es necesario
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: textColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: darkPurple),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: darkPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
      ),

    );
  }
}
