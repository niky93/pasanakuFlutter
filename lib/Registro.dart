import 'dart:convert';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'package:http/http.dart' as http;

class Registro extends StatefulWidget{

  @override
  RegistroApp createState()=> RegistroApp();
}


class RegistroApp extends State<Registro>{
  // Controladores para los campos de texto
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoRegistroController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();


  @override
  void dispose() {
    // Limpia los controladores cuando el widget se deshaga
    _correoController.dispose();
    _telefonoController.dispose();
    _nombreController.dispose();
    _correoRegistroController.dispose();
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
      final Uri url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/norelacionar');

      // Ajustando la estructura del mapa para que coincida con el formato requerido
      final Map<String, dynamic> datosRegistro = {
        "invitado": {
          "correo": _correoController.text, // Asume que este es el correo del invitado
          "telf": '+${_telefonoController.text}', // Asume que este es el teléfono del invitado
        },
        "jugador": {
          "nombre": _nombreController.text,
          "usuario": _correoRegistroController.text, // Asume que 'usuario' se refiere al correo de registro
          "contrasena": _contrasenaController.text,
        }
      };

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(datosRegistro),
        );

        if (response.statusCode <399 ) {
          final responseData = json.decode(response.body);
          print('***************************************************');
          print(responseData);
          print('***************************************************');
          final int jugadorId = responseData['data']['id']; // Asumiendo que recibes 'jugadorId' así

          // Si el servidor responde con éxito, maneja la respuesta aquí.
          // Por ejemplo, puedes navegar a la pantalla principal o mostrar un mensaje de éxito.
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(jugadorId: jugadorId)),
                (Route<dynamic> route) => false,
          );
        } else {
          // Maneja respuestas no exitosas aquí
          mostrarDialogoError('Error al registrar el usuario: ${response.statusCode}');
        }
      } catch (e) {
        // Maneja errores de red o del servidor aquí
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

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro Usuario'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Padding(padding: EdgeInsets.all(20),
              child: TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  labelText:'Correo',
                  hintText:'Digite su correo',
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(20),
              child: TextField(
                controller: _telefonoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  labelText:'Telefono',
                  hintText:'Digite su telefono',
                ),
              ),
            ),


//campos que solo estaran habilitados si la peticion get es correcta
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre completo'),

            ),
            TextField(
              controller: _correoRegistroController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _contrasenaController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true, // Oculta la contraseña
            ),

            // Botón de registro, solo visible si los campos están habilitados
              ElevatedButton(
                onPressed: registrarUsuario,
                child: Text('Registrar'),

              ),
          ],
        ),
      ),
    );
  }



}