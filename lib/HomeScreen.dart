import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'CentroDeNotificaciones.dart';
import 'Juego.dart';
import 'Invitacion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'JuegoScreen.dart';
import 'GradientBackground.dart';
import 'QRLoading.dart';

class HomeScreen extends StatefulWidget {
  final int jugadorId;

  HomeScreen({required this.jugadorId});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Juego> juegos = [];
  List<Invitacion> invitaciones = [];
  Timer? _timer;
  Timer? _timer2;
  var idJugadorJuego;
  var viewContextt;
  bool _hasNotification = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Asumiremos que el creador es parte del objeto juego. Si no, necesitarás ajustar esto.

  @override
  void initState() {
    super.initState();
    _cargarJuegos();
    _cargarInvitaciones();
    _startInvitationsPolling();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      reverseDuration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 0.1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("//////////////////////////");
      print(message.data);
      print("//////////////////////////");
      // if(message.data['event'] != null && message.data['event'] == 'invitacion-juego'){
      _cargarInvitaciones();
      _cargarJuegos();
      setState(() {
        _hasNotification = true;
        _animationController.forward(from: 0.0); // Start the bell animation
      });
      // }
      if (message.notification != null) {
        showDialog(
          context: viewContextt,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Notificación Recibida'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      'Título: ${message.notification?.title ?? "Sin título"}'),
                  Text('Cuerpo: ${message.notification?.body ?? "Sin cuerpo"}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer2
        ?.cancel(); // Asegurarte de cancelar el timer cuando el estado se destruya.
    _animationController.dispose();
    super.dispose();
  }

  void _handleNotificationTap() {
    setState(() {
      _hasNotification = false;
      _animationController.stop();
      _animationController.value = 0; // Reset the animation
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CentroDeNotificaciones()),
    );
  }

  void _startInvitationsPolling() {
    _timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => _cargarInvitaciones());
    _timer2 =
        Timer.periodic(Duration(seconds: 10), (Timer t) => _cargarJuegos());
  }

  void _cargarJuegos() async {
    var url = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/${widget.jugadorId}/juegos');
    print("***********************************");
    print(widget.jugadorId);
    print("***********************************");
    try {
      var response = await http.get(url);
      if (response.statusCode <= 399) {
        var responseData = json.decode(response.body);
        if (!responseData['error']) {
          List<Juego> listaJuegos = [];
          for (var usuario in responseData['data']) {
            for (var juegoJugador in usuario['jugadores_juegos']) {
              print("///////////////////***********//////////////////");
              print(juegoJugador);
              print("///////////////////***********//////////////////");

              Juego juego = Juego.fromJson(juegoJugador[
                  'juego']); // Asegúrate de que 'juego' contiene los datos correctos.
              juego.estadoJugador = (juegoJugador['estado']);
              juego.jugadorjuegoid = (juegoJugador['id']);
              listaJuegos.add(juego);
            }
          }
          setState(() {
            juegos =
                listaJuegos; // Actualiza la lista de juegos con los nuevos datos
          });
        }
      } else {
        print('Error al cargar los juegos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
    }
  }

  void _cargarInvitaciones() async {
    var urlInvitaciones = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/${widget.jugadorId}/juegos/pendientes');
    try {
      var responseInvitaciones = await http.get(urlInvitaciones);
      if (responseInvitaciones.statusCode <= 399) {
        var responseDataInvitaciones = json.decode(responseInvitaciones.body);
        if (!responseDataInvitaciones['error']) {
          print(responseDataInvitaciones['data'][0]['invitado']
              ['invitados_juegos'] as List);
          setState(() {
            invitaciones = (responseDataInvitaciones['data'][0]['invitado']
                    ['invitados_juegos'] as List)
                .map((invitacionData) => Invitacion.fromJson(invitacionData))
                .toList();
          });
        }
      } else {
        print(
            'Error al cargar las invitaciones: ${responseInvitaciones.statusCode}');
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
    }
  }

  Widget _buildInvitacionesSection() {
    if (invitaciones.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Esta sección está vacía', textAlign: TextAlign.center),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: invitaciones.length,
      itemBuilder: (context, index) {
        var invitacion = invitaciones[index];
        return Card(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                20.0), // Define el radio de la curvatura aquí
          ),
          child: ListTile(
            title: Text(invitacion.juego.nombre),
            subtitle: Text('Estado: ${invitacion.estadoInvitacion}'),
            trailing: IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => _mostrarDetallesInvitacion(context, invitacion),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDetallesInvitacion(BuildContext context, Invitacion invitacion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Invitación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    'Bienvenido, te han invitado a unirte al juego ${invitacion.juego.nombre} '
                    ' con fecha de inicio ${invitacion.juego.fechaInicio} con cuotas de : ${invitacion.juego.montoTotal}  ${invitacion.juego.moneda}'
                    ' con un total de ${invitacion.juego.cantJugadores} jugadores'
                    ' y los turnos son en lapsos de ${invitacion.juego.lapsoTurnosDias} dias',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Estado: ${invitacion.estadoInvitacion}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _manejarAceptarInvitacion(
                    invitacion.idJuego, invitacion.idInvitado);
              },
              child: Text('Aceptar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _manejarRechazarInvitacion(invitacion.idInvitado);
              },
              child: Text('Rechazar'),
            ),
          ],
        );
      },
    );
  }

  void _manejarAceptarInvitacion(int idJuego, int idInvitado) async {
    var urlAceptar = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/${widget.jugadorId}/juegos/$idJuego/invitados/$idInvitado');
    try {
      var response = await http.post(urlAceptar);
      if (response.statusCode <= 399) {
        // Si la invitación fue aceptada correctamente, puedes actualizar el estado aquí
        print("Invitación aceptada con éxito.");
        // Recargar las invitaciones para actualizar la lista
        _cargarInvitaciones();
        _cargarJuegos();
      } else {
        // Manejo de errores si la API no retorna un 200 OK
        print('Error al aceptar invitación: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
      }
    } catch (e) {
      // Manejo de errores de conexión o de la solicitud
      print('Error al conectar con el servidor: $e');
    }
  }

  void _manejarRechazarInvitacion(int idInvitado) async {
    // Implementa la lógica para rechazar la invitación
  }

  @override
  Widget build(BuildContext context) {
    viewContextt = context;
    return Scaffold(
        appBar: AppBar(
          title: Text('Pasanaku'),
          actions: <Widget>[
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.qr_code), // Icono de actualizar QR
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QRLoading(
                          idJugador: widget.jugadorId)), // Navegar a QrLoading
                );
              },
            ),
            IconButton(
              icon: Transform.rotate(
                angle: _hasNotification ? _animation.value : 0,
                child: Icon(Icons.notifications,
                    color: _hasNotification ? Colors.red : Colors.white),
              ),
              onPressed: _handleNotificationTap,
            ),
          ],
        ),
        body: GradientBackground(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Juegos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                juegos.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: juegos.length,
                        itemBuilder: (context, index) {
                          Juego juego = juegos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0), // Reducido el margen vertical
                            // elevation: 2.0,  // Añade sombra
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Ajusta el radio aquí
                            ),
                            child: ListTile(
                              title: Text(juego.nombre),
                              subtitle: Text(
                                  'Estado de Jugador: ${juego.estadoJugador}\nIniciado el: ${juego.fechaInicio}\nMonto Total: ${juego.montoTotal} ${juego.moneda}\nCantidad de participantes: ${juego.cantJugadores} '),
                              trailing: IconButton(
                                icon: const Icon(Icons.navigate_next_rounded),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => JuegoScreen(
                                            juego: juego,
                                            idJugador: widget.jugadorId,
                                            jugadorjuegoid:
                                                juego.jugadorjuegoid)),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(child: Text('No hay juegos disponibles')),
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Invitaciones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                // Llamada a _buildInvitacionesSection()
                _buildInvitacionesSection(),
              ],
            ),
          ),
        ));
  }
}
