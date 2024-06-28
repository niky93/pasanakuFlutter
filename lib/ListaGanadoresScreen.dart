import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Turno.dart';

class ListaGanadoresScreen extends StatefulWidget {
  final int idJuego;

  ListaGanadoresScreen({required this.idJuego});

  @override
  _ListaGanadoresScreenState createState() => _ListaGanadoresScreenState();
}

class _ListaGanadoresScreenState extends State<ListaGanadoresScreen> {
  List<Turno> turnos = [];

  @override
  void initState() {
    super.initState();
    fetchTurnos();
  }

  Future<void> fetchTurnos() async {
    var url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/juegos/${widget.idJuego}/turnos');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          turnos = List<Turno>.from(data['data'].map((turno) => Turno.fromJson(turno)));
        });
      } else {
        throw Exception('Failed to load turnos');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Ganadores del Juego'),
      ),
      body: ListView.builder(
        itemCount: turnos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Ganador: ${turnos[index].idGanadorJugadorJuego}'),
            subtitle: Text('Monto pagado: ${turnos[index].montoPago}'),
            trailing: Text('Turno: ${turnos[index].nroTurno}'),
          );
        },
      ),
    );
  }

}

