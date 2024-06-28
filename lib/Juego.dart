import 'package:flutter/material.dart';

class Juego {

  int jugadorjuegoid=0;
  String estadoJugador="";
  final int id;
  final String estadoJuego;
  final String moneda;
  final String nombre;
  final String fechaInicio;
  final int montoTotal;
  final int cantJugadores;
  final int lapsoTurnosDias;

  Juego({
    required this.id,
    required this.estadoJuego,
    required this.moneda,
    required this.nombre,
    required this.fechaInicio,
    required this.montoTotal,
    required this.cantJugadores,
    required this.lapsoTurnosDias,
  });

  factory Juego.fromJson(Map<String, dynamic> json) {
    return Juego(
      id: json['id'],
      estadoJuego: json['estado_juego'],
      moneda: json['moneda'],
      nombre: json['nombre'],
      fechaInicio: json['fecha_inicio'],
      montoTotal: json['monto_total'],
      cantJugadores: json['cant_jugadores'],
      lapsoTurnosDias: json['lapso_turnos_dias'],
    );
  }
}
