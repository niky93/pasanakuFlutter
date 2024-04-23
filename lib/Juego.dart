import 'package:flutter/material.dart';

class Juego {
  final int id;
  final String estadoJuego;
  final String moneda;
  final String nombre;
  final String fechaInicio;
  final int montoTotal;
  final int cantJugadores;
  final int tiempoPujaSeg;
  final int lapsoTurnosDias;
  final int saldoRestante;

  Juego({
    required this.id,
    required this.estadoJuego,
    required this.moneda,
    required this.nombre,
    required this.fechaInicio,
    required this.montoTotal,
    required this.cantJugadores,
    required this.tiempoPujaSeg,
    required this.lapsoTurnosDias,
    required this.saldoRestante,
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
      tiempoPujaSeg: json['tiempo_puja_seg'],
      lapsoTurnosDias: json['lapso_turnos_dias'],
      saldoRestante: json['saldo_restante'],
    );
  }
}
