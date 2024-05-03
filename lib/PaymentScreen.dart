import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pasanaku1/GradientBackground.dart';

class PaymentScreen extends StatefulWidget {
  final int idjugador;
  final int nroTurno;
  final int jugadorJuego;

  PaymentScreen(
      {required this.idjugador,
      required this.nroTurno,
      required this.jugadorJuego});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String imageUrl = "";
  int montoPago = 0;
  String jugadorNombre = "";
  @override
  void initState() {
    super.initState();
    //fetchImageUrl();
    obtenerImagen();
  }

/*
  Future<void> fetchImageUrl() async {
    var url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/${widget.idjugador}');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (!data['error'] && data['data']['qr'] != null) {
          setState(() {
            imageUrl = data['data']['qr'];
          });
        }
      } else {
        showFeedback("Failed to fetch data from the server.");
      }
    } catch (e) {
      showFeedback("Error: $e");
    }
  }
*/
  Future<void> obtenerImagen() async {
    // Solicitud para obtener el ID del jugador
    var urlTurnos = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/juegos/turnos/${widget.nroTurno}');
    try {
      var response = await http.get(urlTurnos);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (!data['error']) {
          int idJugador =
              data['data']['jugador']['id']; // Extraemos el ID del jugador

          // Solicitud para obtener la URL del QR usando el ID del jugador
          var urlJugador = Uri.parse(
              'https://back-pasanaku.onrender.com/api/jugadores/$idJugador');
          var responseJugador = await http.get(urlJugador);
          if (responseJugador.statusCode == 200) {
            var dataJugador = jsonDecode(responseJugador.body);
            if (!dataJugador['error'] && dataJugador['data']['qr'] != null) {
              setState(() {
                jugadorNombre = data['data']['jugador']['nombre'];
                imageUrl = data['data']['jugador']['qr'];
                montoPago = (data['data']['turno']['monto_pago']);
              });
            }
          } else {
            showFeedback("fallo al obtener la url del qr");
          }
        }
      } else {
        showFeedback("fallo al obtener la imagen");
      }
    } catch (e) {
      showFeedback("Error: $e");
    }
  }

  Future<void> _pagar() async {
    var urlTurnos = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/juegos/turnos/${widget.nroTurno}');
    try {
      var response = await http.get(urlTurnos);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (!data['error']) {
          montoPago = data['data']['turno']
              ['monto_pago']; // Extraemos el monto del pago

          final datosRegistro = {
            "id_jugador_remitente": widget
                .idjugador, // Asegúrate de que este es el ID correcto del remitente
            "monto_pagado": montoPago,
            "detalle": "ok"
          };

          final Uri urlPago = Uri.parse(
              'https://back-pasanaku.onrender.com/api/jugadores_juegos/${widget.idjugador}/turnos/${widget.nroTurno}/pagos');

          final responsePago = await http.post(
            urlPago,
            headers: {"Content-Type": "application/json"},
            body: json.encode(datosRegistro),
          );

          if (responsePago.statusCode == 200) {
            var dataPago = jsonDecode(responsePago.body);

            if (!dataPago['error']) {
              // Navegación o manejo de éxito aquí, por ejemplo:
              print(
                  'Pago realizado con éxito, ID del pago: ${dataPago['data']['id_pago']}');
            } else {
              mostrarDialogoError('Error en el pago: ${dataPago['message']}');
            }
          } else {
            mostrarDialogoError(
                'Error al registrar el pago: ${responsePago.statusCode}');
          }
        }
      } else {
        mostrarDialogoError(
            'Error al obtener el monto de pago: ${response.statusCode}');
      }
    } catch (e) {
      mostrarDialogoError('Error al conectar con el servidor: $e');
    }
  }

  void mostrarDialogoError(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
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

  void showFeedback(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pagar"),
      ),
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                imageUrl.isNotEmpty
                    ? Image.network(imageUrl) // Muestra la imagen de la URL
                    : Text("No valid image URL provided"),
                SizedBox(height: 20),
                Text('Ganador: $jugadorNombre', style: TextStyle(fontSize: 20)),
                Text('Monto de Pago: \$${montoPago.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20)),
                ElevatedButton(
                  onPressed: imageUrl.isNotEmpty
                      ? () => downloadAndSaveImage(imageUrl)
                      : null,
                  child: Text("Descargar imagen"),
                ),
                ElevatedButton(
                  onPressed: _pagar,
                  child: Text('Pagar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
