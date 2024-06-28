import 'HomeScreen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pasanaku1/GradientBackground.dart';
import 'package:pasanaku1/Juego.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class PaymentScreen extends StatefulWidget {
  final int idjugador;
  final int nroTurno;
  final int jugadorJuego;
  final Juego juego;

  PaymentScreen(
      {required this.idjugador,
      required this.nroTurno,
      required this.jugadorJuego,
        required this.juego});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _montoPagoController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();
  final TextEditingController _nombreGanadorController = TextEditingController();
  String imageUrl = "";
  int montoPago = 0;
  String jugadorNombre = "";
  int id_ganador_jugador_juego=0;
  var turno;
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
  Future<int> _obtenerTurno() async {
    var url = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/juegos/${widget.juego.id}/turnos/ultimo');
    try {
      var response = await http.get(url);
      if (response.statusCode <= 399) {
        var data = json.decode(response.body);
        if (!data['error']) {
          // Asume que los datos están ordenados y que el último elemento es el más reciente
          int nroTurno =data ['data']['nro_turno'];
          print("//////////////////////////");
          print(nroTurno);
          print("//////////// nro turno //////////////");
          id_ganador_jugador_juego=data ['data']['id_ganador_jugador_juego'];
          return nroTurno; // Retorna el número del ultimo turno
        } else {
          _mostrarDialogoError("No se pudo obtener el turno: ${data['message']}");
        }
      } else {
        _mostrarDialogoError("Error al obtener el turno: ${response.statusCode}");
      }
    } catch (e) {
      _mostrarDialogoError("Error de conexión al servidor: $e");
    }
    return -1; // Retorna -1 en caso de error
  }

  Future<void> obtenerImagen() async {
    // Solicitud para obtener el ID del jugador
    turno = await _obtenerTurno();
    var urlTurnos = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/juegos/turnos/$turno');
    print("////////////////// estoy dentro del metodo obtener imagen y este es el numero de turno////////////////");
    print(turno);
    print("////////////////// estoy dentro del metodo obtener imagen y este es el numero de turno////////////////");
    try {
      var response = await http.get(urlTurnos);
      if (response.statusCode <= 399) {
        var data = jsonDecode(response.body);
        if (!data['error']) {
          int idJugador =
              data['data']['jugador']['id']; // Extraemos el ID del jugador

          // Solicitud para obtener la URL del QR usando el ID del jugador
          var urlJugador = Uri.parse(
              'https://back-pasanaku.onrender.com/api/jugadores/$idJugador');
          var responseJugador = await http.get(urlJugador);
          if (responseJugador.statusCode <= 399) {
            var dataJugador = jsonDecode(responseJugador.body);
            if (!dataJugador['error'] && dataJugador['data']['qr'] != null) {
              setState(() {
                jugadorNombre = data['data']['jugador']['nombre'];
                montoPago = (data['data']['turno']['monto_pago']);;
                _nombreGanadorController.text = jugadorNombre;
                _montoPagoController.text = montoPago.toStringAsFixed(0);
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
    final monto = int.tryParse(_montoPagoController.text); // Intenta convertir y maneja un posible null
    if (monto == null) { // Verifica si el resultado es null y maneja el error
      _mostrarDialogoError('Por favor, ingresa un monto válido.');
      return; // Salir temprano si hay un error
    }

    final datosRegistro = {
      "id_jugador_remitente": widget.idjugador,
      "monto_pagado": monto, // Usa la variable monto que sabemos que es válida
      "detalle": _detalleController.text // Detalle del TextField
    };
    /*await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );*/
    var urlPago = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores_juegos/${id_ganador_jugador_juego}/turnos/${widget.nroTurno}/pagos');
    try {
      var responsePago = await http.post(
        urlPago,
        headers: {"Content-Type": "application/json"},
        body: json.encode(datosRegistro),
      );

      if (responsePago.statusCode <= 399) {
        var dataPago = jsonDecode(responsePago.body);
        if (!dataPago['error']) {
          print('Pago realizado con éxito, ID del pago: ${dataPago['data']['id_pago']}');
          /*final fcmToken = await FirebaseMessaging.instance.getToken();
          final db = FirebaseFirestore.instance;

          final pago = <String, dynamic>{
            "pago": 1,
            "idJuego":widget.juego.id,
            "idTurno":turno,

            "idFirebase": fcmToken,
            "timestamp": DateTime.now().toString()
          };

          db
              .collection("pago")
              .add(pago)
              .then((value) => print('DocumentSnapshot added with ID: ${value.id}'));
*/

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(jugadorId: widget.idjugador)), // Asume que HomeScreen toma un id de jugador como parámetro
          );
          // Posiblemente volver a la pantalla anterior o mostrar un mensaje de éxito
          Navigator.pop(context);
        } else {
          _mostrarDialogoError('Error en el pago: ${dataPago['message']}');
        }
      } else {
        _mostrarDialogoError('Error al registrar el pago: ${responsePago.statusCode}');
      }
    } catch (e) {
      _mostrarDialogoError('Error de conexión al servidor: $e');
    }
  }


  void _mostrarDialogoError(String mensaje) {
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

          TextFormField(
            controller: _nombreGanadorController,
            decoration: InputDecoration(labelText: 'Ganador'),
            enabled: false,
          ),
          TextFormField(
            controller: _montoPagoController,
            decoration: InputDecoration(labelText: 'Monto de Pago'),
            keyboardType: TextInputType.number,
            enabled: false,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _detalleController,
              decoration: InputDecoration(
                  labelText: 'Detalle',
                  hintText: 'Ingrese detalles del pago'
              ),
            ),
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
