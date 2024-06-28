import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:pasanaku1/Juego.dart';
import 'package:pasanaku1/PaymentScreen.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:path_provider/path_provider.dart" show getTemporaryDirectory;
import 'package:gallery_saver/gallery_saver.dart' show GallerySaver;
import 'package:pasanaku1/GradientBackground.dart';

class QRViewExample extends StatefulWidget {
  final int idjugador;
  final int nroTurno;
  final int jugadorJuego;
  final Juego juego;

  QRViewExample(
      {required this.idjugador,
        required this.nroTurno,
        required this.jugadorJuego,
        required this.juego});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final ImagePicker _picker = ImagePicker();
  String? _qrText;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      // Inicia la navegación después de un retraso cuando se escanea un QR.
      navigateAfterDelay();
    });
  }



  void navigateAfterDelay() {
    if (result != null) { // Verifica que el resultado no sea nulo
      // Detener la cámara antes de iniciar el delay
      controller?.stopCamera(); // Asegura detener la cámara

      Future.delayed(Duration(seconds: 5), () {
        // Navega a la siguiente pantalla
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentScreen(
            juego: widget.juego,
            idjugador: widget.idjugador,
            nroTurno: widget.nroTurno,
            jugadorJuego: widget.jugadorJuego,
          )),
        ).then((_) {
          // Si necesitas reiniciar la cámara al regresar, puedes hacerlo aquí
          if (controller != null) {
            controller!.resumeCamera();
          }
        });
      });
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller != null) {
        controller!.resumeCamera(); // Reanuda la cámara cuando el widget se construye y está listo.
      }
    });
  }


  @override
  void dispose() {
    controller?.stopCamera(); // Asegura detener la cámara
    controller?.dispose(); // Luego desecha el controlador
    super.dispose();
  }

  Future<void> pickImageAndNavigate() async {
    final ImagePicker _picker = ImagePicker();
    // Detiene la cámara antes de abrir la galería.
    controller?.stopCamera();

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            idjugador: widget.idjugador,
            nroTurno: widget.nroTurno,
            jugadorJuego: widget.jugadorJuego,
            juego: widget.juego,
          ),
        ),
      ).then((_) {
        // Reanuda la cámara cuando regresas si es necesario.
        if (mounted && controller != null) {
          controller!.resumeCamera();
        }
      });
    } else {
      // Si no se selecciona una imagen y se regresa a la pantalla del escáner, reanuda la cámara.
      if (mounted && controller != null) {
        controller!.resumeCamera();
      }
      print("No image selected");
    }
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode <= 399) {
        final directory = await getTemporaryDirectory();
        File imgFile = File(
            '${directory.path}/QR_Image_${DateTime.now().millisecondsSinceEpoch}.png');
        await imgFile.writeAsBytes(response.bodyBytes);
        bool? success = await GallerySaver.saveImage(imgFile.path);
        if (success == true) {
          showFeedback("Image downloaded successfully!");
        } else {
          showFeedback("Failed to download image.");
        }
      } else {
        showFeedback("Failed to fetch image from the URL.");
      }
    } catch (e) {
      showFeedback("Error: $e");
    }
  }
  Future<String> _obtenerImagen() async {
    String imageUrl = "https://defaultqrurl.com"; // URL por defecto en caso de fallo
    var urlTurnos = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/juegos/turnos/${widget.nroTurno}');
    try {
      var response = await http.get(urlTurnos);
      if (response.statusCode <= 399) {
        var data = jsonDecode(response.body);
        if (!data['error']) {
          int idJugador = data['data']['jugador']['id'];
          var urlJugador = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/$idJugador');
          var responseJugador = await http.get(urlJugador);
          if (responseJugador.statusCode <= 399) {
            var dataJugador = jsonDecode(responseJugador.body);
            if (!dataJugador['error'] && dataJugador['data']['qr'] != null) {
              imageUrl = dataJugador['data']['qr'];
            }
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    return imageUrl;
  }
  void showFeedback(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: <Widget>[

            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: result != null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Barcode Type: ${describeEnum(result!.format)} Data: ${result!.code}'),
                    CircularProgressIndicator(), // Indicador de carga durante la espera
                  ],
                )
                    : Text('Scan a code'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    String qrUrl = await _obtenerImagen(); // Asegura obtener la URL después de la ejecución
                    await downloadAndSaveImage(qrUrl);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error descargando QR: $e")));
                  }
                },
                child: Text("Descargar QR"),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: pickImageAndNavigate, // Método que selecciona una imagen y navega
                child: Text("Seleccionar de la galería"),
              ),
            ),
          ],
        ),
      ),);
  }




}