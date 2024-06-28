class Turno {
  final int id;
  final int idJuego;
  final int idGanadorJugadorJuego;
  final String estadoTurno;
  final String fechaTurno;
  final int tiempoPujaSeg;
  final String fechaInicioPago;
  final int tiempoPagoSeg;
  final int nroTurno;
  final int saldoRestante;
  final int montoMinimoPuja;
  final int montoPago;

  Turno({
    required this.id,
    required this.idJuego,
    required this.idGanadorJugadorJuego,
    required this.estadoTurno,
    required this.fechaTurno,
    required this.tiempoPujaSeg,
    required this.fechaInicioPago,
    required this.tiempoPagoSeg,
    required this.nroTurno,
    required this.saldoRestante,
    required this.montoMinimoPuja,
    required this.montoPago,
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'],
      idJuego: json['id_juego'],
      idGanadorJugadorJuego: json['id_ganador_jugador_juego'],
      estadoTurno: json['estado_turno'],
      fechaTurno: json['fecha_turno'],
      tiempoPujaSeg: json['tiempo_puja_seg'],
      fechaInicioPago: json['fecha_inicio_pago'],
      tiempoPagoSeg: json['tiempo_pago_seg'],
      nroTurno: json['nro_turno'],
      saldoRestante: json['saldo_restante'],
      montoMinimoPuja: json['monto_minimo_puja'],
      montoPago: json['monto_pago'],
    );
  }
}
