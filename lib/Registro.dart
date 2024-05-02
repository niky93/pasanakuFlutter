import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'GradientBackground.dart';
import 'package:pasanaku1/CircularImage.dart';

class Registro extends StatefulWidget {
  @override
  RegistroApp createState() => RegistroApp();
}

class RegistroApp extends State<Registro> {
  // Controladores para los campos de texto
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _usuarioRegistroController =
      TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se deshaga
    _correoController.dispose();
    _telefonoController.dispose();
    _nombreController.dispose();
    _usuarioRegistroController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  // Método para realizar la solicitud HTTP get
/*
  Future<void> verificarDatos() async {
    // URL para  petición
    // Endpoint real
    final Uri url = Uri.parse('https://back-pasanaku.onrender.com/api/invitados/validar?correo=${_correoController.text}&telf=${_telefonoController.text}');
      print('////////////////////////////////////////');
    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body); // Deserializa la respuesta
        print(responseData);
      // Verifica si la respuesta tiene un campo 'data' y no es nulo
      if (response.statusCode < 402) {
        print('******************************');
        // Si la solicitud fue exitosa, procede según necesites
        // Por ejemplo, podrías navegar a otra pantalla o mostrar un diálogo de éxito
       // Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));

      } else {
        // Manejo de errores, por ejemplo, mostrar un diálogo de error
        mostrarDialogoError('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Error al realizar la petición
      mostrarDialogoError('Error al conectar con el servidor: $e');
    }
  }*/
  void registrarUsuario() async {
    final String correo = _correoController.text.trim();
    final String telefono = _telefonoController.text.trim();
    final String nombre = _nombreController.text.trim();
    final String usuario = _usuarioRegistroController.text.trim();
    final String contrasena = _contrasenaController.text.trim();

    // Obtener el token de Firebase
    String? token = await FirebaseMessaging.instance.getToken();

    // Preparar el cuerpo de la solicitud POST
    final Uri url =
        Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/');
    final Map<String, dynamic> datosRegistro = {
      "invitado": {
        "correo": correo,
        "telf": '+$telefono',
      },
      "jugador": {
        "nombre": nombre,
        "usuario": usuario,
        "contrasena": contrasena,
        "client_token":
            token ?? "No token available" // Enviar token o un valor por defecto
      }
    };

    try {
      // Realizar la solicitud POST
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(datosRegistro),
      );

      if (response.statusCode <= 299) {
        // Si la solicitud fue exitosa
        final responseData = json.decode(response.body);
        final int jugadorId =
            responseData['data']['id']; // Asumiendo que recibes 'jugadorId' así

        // Navegar a la pantalla principal o mostrar mensaje de éxito
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(jugadorId: jugadorId)),
          (Route<dynamic> route) => false,
        );
      } else {
        // Mostrar error si la respuesta no es exitosa
        mostrarDialogoError(
            'Error al registrar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      // Mostrar error si hay un problema en la conexión
      mostrarDialogoError('Error al conectar con el servidor: $e');
    }
  }

  void mostrarDialogoError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registro Usuario'),
        ),
        body: GradientBackground(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      child: CircularImage(
                        assetName: 'image/logo.png',
                        size: 80.0, // Ajusta al tamaño que prefieras
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Nombre completo',
                      hintText: 'Digite su nombre',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _usuarioRegistroController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Usuario',
                      hintText: 'Digite su nombre de usuario',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _correoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Correo',
                      hintText: 'Digite su correo',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _telefonoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Telefono',
                      hintText: 'Digite su telefono',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _contrasenaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Contraseña',
                      hintText: 'Digite su Contraseña',
                    ),
                  ),
                ),

                // Botón de registro, solo visible si los campos están habilitados
                ElevatedButton(
                  onPressed: registrarUsuario,
                  child: Text('Registrar'),
                ),
              ],
            ),
          ),
        ));
  }
}
