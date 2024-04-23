
import 'dart:developer';

import 'package:flutter/material.dart';
import'Juego.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class JuegoScreen extends StatefulWidget {
  final Juego juego;
  final int idJugador;

  JuegoScreen({required this.juego, required this.idJugador});
  @override
  _JuegoScreenState createState() => _JuegoScreenState();

}
class _JuegoScreenState extends State<JuegoScreen> {
  final TextEditingController _pujaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.juego.nombre),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nombre: ${widget.juego.nombre}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Fecha de inicio: ${widget.juego.fechaInicio}'),
            Text('Monto total: ${widget.juego.montoTotal} ${widget.juego.moneda}'),
            Text('Cantidad de jugadores: ${widget.juego.cantJugadores} '),
            Text('Estado del juego: ${widget.juego.estadoJuego}'),
            Text('Lapso de turnos: ${widget.juego.lapsoTurnosDias} días'),
            Text('Tiempo de puja: ${widget.juego.tiempoPujaSeg} segundos'),
            // Incluir otros detalles que consideres necesarios
            ElevatedButton(
                onPressed: _mostrarDialogoPuja,
                child: Text('Ofertar'),
            )
          ],
        ),
      ),
    );
  }
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

  void _enviarPuja() async {
    // Verificar que el input no esté vacío y sea un número
    if (_pujaController.text.isEmpty || double.tryParse(_pujaController.text) == null) {
      _mostrarMensaje("Por favor ingresa un monto válido.");
      return;
    }

    // Ajustando la URL para que incluya los ID's correctos y el endpoint para pujar
    var url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/${widget.idJugador}/juegos/${widget.juego.id}/turno/1');

    try {
      var response = await http.post(
        url,
        body: json.encode({
          'monto_puja': int.parse(_pujaController.text), // Asegurándose de enviar un entero
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      var data = json.decode(response.body);
      if (response.statusCode == 200) {

        if (!data['error']) {
          // Mensaje de éxito mostrando el monto de la puja confirmada
          _mostrarMensaje("Puja enviada correctamente monto: ${data['data']['monto_puja']}");
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


}