import 'Juego.dart';
class Invitacion {
  final int id;
  final int idJuego;
  final String estadoInvitacion;
  final Juego juego;

  Invitacion({
    required this.id,
    required this.idJuego,
    required this.estadoInvitacion,
    required this.juego,
  });

  factory Invitacion.fromJson(Map<String, dynamic> json) {
    return Invitacion(
      id: json['id_invitado'],
      idJuego: json['id_juego'],
      estadoInvitacion: json['estado_invitacion'],

      juego: Juego.fromJson(json['juego']),
    );
  }
}
