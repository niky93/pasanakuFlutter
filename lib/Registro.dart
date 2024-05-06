import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'HomeScreen.dart';
import 'GradientBackground.dart';
import 'package:pasanaku1/CircularImage.dart';

class Registro extends StatefulWidget {
  @override
  RegistroApp createState() => RegistroApp();
}

class RegistroApp extends State<Registro> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _usuarioRegistroController =
      TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    _correoController.dispose();
    _telefonoController.dispose();
    _nombreController.dispose();
    _usuarioRegistroController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    String? token = await FirebaseMessaging.instance.getToken();
    String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      var ref = storage.ref('uploads/$token/$fileName');
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  void registrarUsuario() async {
    setState(() {
      _isLoading = true;
    });
    final String correo = _correoController.text.trim();
    final String telefono = _telefonoController.text.trim();
    final String nombre = _nombreController.text.trim();
    final String usuario = _usuarioRegistroController.text.trim();
    final String contrasena = _contrasenaController.text.trim();
    String? imageUrl;

    if (_image != null) {
      imageUrl = await uploadImageToFirebase(_image!);
    }

    final Map<String, dynamic> datosRegistro = {
      "invitado": {
        "correo": correo,
        "telf": '+591$telefono',
      },
      "jugador": {
        "nombre": nombre,
        "usuario": usuario,
        "contrasena": contrasena,
        "client_token": await FirebaseMessaging.instance.getToken(),
        "qr": imageUrl ?? ""
      }
    };

    final Uri url =
        Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(datosRegistro),
      );

      if (response.statusCode <= 399) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(jugadorId: 123)), // Actualizar con ID real
          (Route<dynamic> route) => false,
        );
      } else {
        mostrarDialogoError(
            'Error al registrar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      mostrarDialogoError('Error al conectar con el servidor: $e');
    }
  }

  void mostrarDialogoError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro Usuario')),
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
                    child:
                        CircularImage(assetName: 'image/logo.png', size: 80.0),
                  ),
                ),
              ),
              // Add button to pick and display image
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        5), // Ajusta el espacio horizontal y vertical entre elementos
                child: TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Digite su Nombre completo',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5)), // Agrega un borde al textfield
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        5), // Ajusta el espacio horizontal y vertical entre elementos
                child: TextField(
                  controller: _usuarioRegistroController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    hintText: 'Digite su usuario',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5)), // Agrega un borde al textfield
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        5), // Ajusta el espacio horizontal y vertical entre elementos
                child: TextField(
                  controller: _correoController,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    hintText: 'Digite su Correo',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5)), // Agrega un borde al textfield
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        5), // Ajusta el espacio horizontal y vertical entre elementos
                child: TextField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Telefono',
                    hintText: 'Digite su Telefono',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5)), // Agrega un borde al textfield
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        5), // Ajusta el espacio horizontal y vertical entre elementos
                child: TextField(
                  controller: _contrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Digite su Contraseña',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5)), // Agrega un borde al textfield
                  ),
                  obscureText: true,
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: _image != null
                    ? Image.file(_image!)
                    : Container(height: 100, color: Colors.transparent),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ElevatedButton(
                  onPressed: pickImage,
                  child: Text('Escoger QR de la galeria'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _isLoading
                    ? CircularProgressIndicator() // Muestra el indicador de carga
                    : ElevatedButton(
                        onPressed: registrarUsuario,
                        child: Text('Registrar'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
