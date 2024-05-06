import 'dart:developer';
import 'package:pasanaku1/PaymentScreen.dart';
import 'package:pasanaku1/QRLoading.dart';
import 'package:pasanaku1/GradientBackground.dart';
import 'package:flutter/material.dart';
import 'Juego.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class JuegoScreen extends StatefulWidget {
  final Juego juego;
  final int idJugador;
  final int jugadorjuegoid;

  JuegoScreen(
      {required this.juego,
      required this.idJugador,
      required this.jugadorjuegoid});
  @override
  _JuegoScreenState createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  final TextEditingController _pujaController = TextEditingController();
  var turno;
  @override
  void _mostrarDialogoPuja() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresa tu puja'),
          content: TextField(
            controller: _pujaController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: "Monto de la puja"),
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enviarPuja();
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<int> _obtenerTurno() async {
    var url = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/juegos/${widget.juego.id}/turnos');
    try {
      var response = await http.get(url);
      if (response.statusCode <= 399) {
        var data = json.decode(response.body);
        if (!data['error']) {
          // Asume que los datos están ordenados y que el último elemento es el más reciente
          int nroTurno = data['data'].first['nro_turno'];
          print("//////////////////////////");
          print(nroTurno);
          print("//////////// nro turno //////////////");
          return nroTurno; // Retorna el número de turno del último elemento
        } else {
          _mostrarMensaje("No se pudo obtener el turno: ${data['message']}");
        }
      } else {
        _mostrarMensaje("Error al obtener el turno: ${response.statusCode}");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión al servidor: $e");
    }
    return -1; // Retorna -1 en caso de error
  }

  void _enviarPuja() async {
    print('**************************************************************');
    print(widget.juego.id);
    print('**************************************************************');
    turno = await _obtenerTurno();

    // Verificar que el input no esté vacío y sea un número
    if (_pujaController.text.isEmpty ||
        double.tryParse(_pujaController.text) == null) {
      _mostrarMensaje("Por favor ingresa un monto válido.");
      return;
    }

    // Ajustando la URL para que incluya los ID's correctos y el endpoint para pujar
    var url = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/juegos/turno/${turno}');

    try {
      var response = await http.post(
        url,
        body: json.encode({
          'id_jugador_juego': widget.jugadorjuegoid,
          'monto_puja': int.parse(
              _pujaController.text), // Asegurándose de enviar un entero
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      var data = json.decode(response.body);
      if (response.statusCode <= 399) {
        if (!data['error']) {
          // Mensaje de éxito mostrando el monto de la puja confirmada
          _mostrarMensaje(
              "Puja enviada correctamente monto: ${data['data']['monto_puja']}");
        } else {
          // Mensaje de error devuelto por el servidor
          log("Error en el servidor: ${data['message']}");
          _mostrarMensaje("La oferta para este juego no está habilitada");
        }
      } else {
        print('Error al enviar la puja: ${response.body}');
        _mostrarMensaje("Error al enviar la puja: ${data['message']}");
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
      log("Error al conectar con el servidor: $e");
      _mostrarMensaje("La oferta para este juego no está habilitada");
    }
  }

  void _mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resultado de la Puja'),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("/////////////////jugadorJuego////////////////////////////");
    print("JugadorJuegoId: ${widget.jugadorjuegoid}");

    print("JuegoId: ${widget.idJugador}");
    print("/////////////////////////////////////////////");
    return Scaffold(
      appBar: AppBar(
        title: Text('Pasanaku'),
      ),
      body: GradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nombre: ${widget.juego.nombre}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Fecha de inicio: ${widget.juego.fechaInicio}'),
            Text(
                'Monto total: ${widget.juego.montoTotal} ${widget.juego.moneda}'),
            Text('Cantidad de jugadores: ${widget.juego.cantJugadores} '),
            Text('Estado del juego: ${widget.juego.estadoJuego}'),
            Text('Lapso de turnos: ${widget.juego.lapsoTurnosDias} días'),

            // Incluir otros detalles que consideres necesarios
            ElevatedButton(
              onPressed: _mostrarDialogoPuja,
              child: Text('Ofertar'),
            ),
            ElevatedButton(
              onPressed: () async {
                turno = await _obtenerTurno();
                if (turno != -1) {
                  // Asegurarse de que se obtuvo un turno válido antes de proceder
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                                idjugador: widget.idJugador,
                                nroTurno:
                                    turno, // Pasar el turno obtenido a PaymentScreen
                                jugadorJuego: widget.jugadorjuegoid,
                              )));
                } else {
                  _mostrarMensaje(
                      "No se pudo obtener un turno válido."); // Mostrar mensaje si no se obtiene un turno válido
                }
              },
              child: Text('Pagar'),
            ),
          ],
        ),
      ),
    );
  }
}
