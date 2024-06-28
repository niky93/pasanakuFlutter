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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^[67]\d{7}$').hasMatch(phone);
  }

  bool isAlphabetic(String input) {
    return RegExp(r'^[a-zA-Z ]+$').hasMatch(input);
  }
  bool validateFields() {
    bool isValid = true;
    if (_nombreController.text.isEmpty || !isAlphabetic(_nombreController.text)) {
      isValid = false;
    }
    if (_usuarioRegistroController.text.isEmpty ) {
      isValid = false;
    }
    if (_correoController.text.isEmpty || !isValidEmail(_correoController.text)) {
      isValid = false;
    }
    if (_telefonoController.text.isEmpty || !isValidPhone(_telefonoController.text)) {
      isValid = false;
    }
    if (_contrasenaController.text.isEmpty) {
      isValid = false;
    }
    return isValid;
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
    if (!_formKey.currentState!.validate()) {
      mostrarDialogoError('Por favor corrija los errores en el formulario.');
      return;
    }
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

    final Uri url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(datosRegistro),
      );

      if (response.statusCode <= 399) {
        final responseData = json.decode(response.body);
        if (!responseData['error']) {
          final int jugadorId = responseData['data']['id'];  // Asegúrate de que este es el campo correcto

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(jugadorId: jugadorId)),
                (Route<dynamic> route) => false,
          );
        } else {
          mostrarDialogoError('Error en la respuesta del servidor: ${responseData['data']}');
        }
      } else {
        mostrarDialogoError('Error al registrar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      mostrarDialogoError('Error al conectar con el servidor: $e');
    } finally {
      setState(() {
        _isLoading = false;  // Asegúrate de resetear el estado de carga
      });
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
          child:Form(

            key: _formKey,
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
                child: TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Digite su Nombre completo',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5),
                       ),
                  ),
                    validator: (value) {
                      if (value == null || value.isEmpty|| !isAlphabetic(value)) {
                        return 'Escriba un nombre valido(los nombres solo pueden contener letras)';
                      }
                      return null;
                    }
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        5), // Ajusta el espacio horizontal y vertical entre elementos
                child: TextFormField(
                  controller: _usuarioRegistroController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    hintText: 'Digite su usuario',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5)), // Agrega un borde al textfield
                  ),validator: (value) {
                  if (value == null || value.isEmpty ) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                }
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        5), // Ajusta el espacio horizontal y vertical entre elementos
                child: TextFormField(
                  controller: _correoController,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    hintText: 'Digite su Correo',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5)),
                  ),validator: (value) {
                  if (value == null || value.isEmpty || !isValidEmail(value) ) {
                    return 'Escriba un correo valido';
                  }
                  return null;
                }
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        5), // Ajusta el espacio horizontal y vertical entre elementos
                child: TextFormField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Telefono',
                    hintText: 'Digite su Telefono',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            5)), // Agrega un borde al textfield
                  ),
                    validator: (value) {
                  if (value == null || value.isEmpty|| !isValidPhone(value)) {
                    return 'Escriba un numero de telefono valido';
                  }
                  return null;
                }
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextFormField(
                  controller: _contrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Digite su Contraseña',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    errorBorder: OutlineInputBorder( // Asegúrate de que la frontera en rojo se muestre cuando hay un error
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedErrorBorder: OutlineInputBorder( // Frontera en rojo cuando el campo esté seleccionado y haya un error
                      borderSide: BorderSide(color: Colors.red, width: 2.0),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio'; // Mensaje de error que se muestra
                    }
                    return null;
                  },
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
    ),);
  }
}
