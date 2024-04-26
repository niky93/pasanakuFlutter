import 'Juego.dart';

class Invitacion {
  final int idInvitado;
  final int idJuego;
  final String estadoInvitacion;
  final String estadoNotificacionWhatsapp;
  final String estadoNotificacionCorreo;
  final String nombreInvitado;
  final String periodo;
  final String fecha;
  final Juego juego;

  Invitacion({
    required this.idInvitado,
    required this.idJuego,
    required this.estadoInvitacion,
    required this.estadoNotificacionWhatsapp,
    required this.estadoNotificacionCorreo,
    required this.nombreInvitado,
    required this.periodo,
    required this.fecha,
    required this.juego,
  });

  factory Invitacion.fromJson(Map<String, dynamic> json) {
    return Invitacion(
      idInvitado: json['id_invitado'],
      idJuego: json['id_juego'],
      estadoInvitacion: json['estado_invitacion'],
      estadoNotificacionWhatsapp: json['estado_notificacion_whatsapp'],
      estadoNotificacionCorreo: json['estado_notificacion_correo'],
      nombreInvitado: json['nombre_invitado'],
      periodo: json['periodo'],
      fecha: json['fecha'],
      juego: Juego.fromJson(json['juego']),
    );
  }
}
