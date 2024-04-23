
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
    var url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/${widget.idJugador}/juegos/${widget.juego.id}/pujar');
    try {
      var response = await http.post(
        url,
        body: json.encode({
          'monto': _pujaController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Puja enviada correctamente.');
      } else {
        print('Error al enviar la puja: ${response.body}');
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
    }
  }
}