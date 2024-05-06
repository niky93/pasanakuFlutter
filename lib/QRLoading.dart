import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'GradientBackground.dart';

class QRLoading extends StatefulWidget {
  final int idJugador;
  QRLoading({required this.idJugador});
  @override
  _QRLodingScreenState createState() => _QRLodingScreenState();
}

class _QRLodingScreenState extends State<QRLoading> {
  File? _image;
  String? _token;

  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  Future<void> fetchToken() async {
    _token = await FirebaseMessaging.instance.getToken();
    print("Firebase Messaging Token: $_token");
  }

  // Select image from gallery or camera
  Future pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    try {
      String filePath = 'uploads/$_token/${DateTime.now()}.png';
      FirebaseStorage storage = FirebaseStorage.instance;
      var task = storage.ref(filePath).putFile(image);

      // Get the download URL
      var snapshot = await task;
      var url = await snapshot.ref.getDownloadURL();
      print('Imagen subida correctamente');

      // Send the URL to your server
      await sendImageUrlToServer(url);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagen subida correctamente!'))
      );
    } on FirebaseException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fallo la subida de la imagen'))
      );
    }
  }

  Future<void> sendImageUrlToServer(String imageUrl) async {
    var url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/${widget.idJugador}'); // Asegúrate de usar la URL correcta
    try {
      var response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'qr': imageUrl}), // Asegúrate de que el campo coincide con lo que espera tu servidor
      );

      if (response.statusCode <= 399) {
        print("URL de la imagen enviada correctamente al servidor.");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('URL de la imagen enviada correctamente al servidor.'))
        );
      } else {
        print("Fallo al enviar la URL de la imagen al servidor: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fallo al enviar la URL de la imagen al servidor.'))
        );
      }
    } catch (e) {
      print("Error al conectar al servidor: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar al servidor.'))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cargar QR"),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                _image != null ? Image(image: FileImage(_image!), frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: child,
                  );
                }) : Text("No se han seleccionado imágenes"),
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.gallery),
                  child: Text("Seleccionar de la galeria"),
                ),
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.camera),
                  child: Text("Tomar una foto"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_image != null && _token != null) {
                      uploadImageToFirebase(_image!);
                    } else {
                      print("No se ha seleccionado imagen");
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se ha seleccionado imagen'))
                      );
                    }
                  },
                  child: Text("Subir Imagen"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
