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
import 'main.dart';



class HomeScreen extends StatefulWidget {
  final int jugadorId;
  HomeScreen({required this.jugadorId});

  @override
  HomeScreenState createState() => HomeScreenState();
}
class HomeScreenState extends State<HomeScreen> {
  List<Juego> juegos = [];
  List<Invitacion> invitaciones = [];
  Timer? _timer;
  Timer? _timer2;

  var viewContextt;

  // Asumiremos que el creador es parte del objeto juego. Si no, necesitarás ajustar esto.

  @override
  void initState() {
    super.initState();
    _cargarJuegos();
    _cargarInvitaciones();
    _startInvitationsPolling();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("//////////////////////////");
      print(message.data);
      print("//////////////////////////");
      // if(message.data['event'] != null && message.data['event'] == 'invitacion-juego'){
        _cargarInvitaciones();
        _cargarJuegos();
      // }
      if(message.notification!= null){
        showDialog(
          context: viewContextt,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Notificación Recibida'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Título: ${message.notification?.title ?? "Sin título"}'),
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
    _timer2?.cancel(); // Asegurarte de cancelar el timer cuando el estado se destruya.
    super.dispose();
  }


  void _startInvitationsPolling() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) => _cargarInvitaciones());
    _timer2 = Timer.periodic(Duration(seconds: 10), (Timer t) => _cargarJuegos());
  }

  void _cargarJuegos() async {
    var url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/${widget.jugadorId}/juegos');
    print("***********************************");
    print(widget.jugadorId);
    print("***********************************");
    try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          if (!responseData['error']) {
            List<Juego> listaJuegos = [];
            for (var usuario in responseData['data']) {
              for (var juegoJugador in usuario['jugadores_juegos']) {
                Juego juego = Juego.fromJson(juegoJugador['juego']); // Asegúrate de que 'juego' contiene los datos correctos.
                listaJuegos.add(juego);
              }
            }
            setState(() {
              juegos = listaJuegos;  // Actualiza la lista de juegos con los nuevos datos
            });
          }
        }else {
          print('Error al cargar los juegos: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al conectar con el servidor: $e');
      }
    }
  void _cargarInvitaciones() async {

    var urlInvitaciones = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/${widget.jugadorId}/juegos/pendientes');
    try {
      var responseInvitaciones = await http.get(urlInvitaciones);
      if (responseInvitaciones.statusCode == 200) {

        var responseDataInvitaciones = json.decode(responseInvitaciones.body);
        if (!responseDataInvitaciones['error']) {


          print(responseDataInvitaciones['data'][0]['invitado']['invitados_juegos'] as List);
          setState(() {
            invitaciones = (responseDataInvitaciones['data'][0]['invitado']['invitados_juegos'] as List)
                .map((invitacionData) => Invitacion.fromJson(invitacionData))
                .toList();
          });
        }
      } else {
        print('Error al cargar las invitaciones: ${responseInvitaciones.statusCode}');
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
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Define el radio de la curvatura aquí
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
              Text('Bienvenido te han invitado a unirte al juego ${invitacion.juego.nombre} '
                  ' con fecha de inicio ${invitacion.juego.fechaInicio} con cuotas de : ${invitacion.juego.montoTotal}  ${invitacion.juego.moneda}'
                  ' con un total de ${invitacion.juego.cantJugadores} jugadores'
                  ' y los turnos son en lapsos de ${invitacion.juego.lapsoTurnosDias} dias'
                  , style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Estado: ${invitacion.estadoInvitacion}'),

            ],
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _manejarAceptarInvitacion(invitacion.idJuego, invitacion.idInvitado);
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
    var urlAceptar = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/${widget.jugadorId}/juegos/$idJuego/invitados/$idInvitado');
    try {
      var response = await http.post(urlAceptar);
      if (response.statusCode == 200) {
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
    viewContextt=context;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pasanaku'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CentroDeNotificaciones()),
              );
            },
          ),
        ],

      ),
      body:GradientBackground(
      child:SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Juegos',
                style: Theme.of(context).textTheme.headline6,
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
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),

                ),
                child: ListTile(
                title: Text(juego.nombre),
                subtitle: Text('Creador: ${juego.nombre}, Iniciado el: ${juego.fechaInicio}, Monto Total: ${juego.montoTotal} ${juego.moneda}'),
                trailing: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JuegoScreen(juego: juego, idJugador: widget.jugadorId)),
                );
                    },
                ),
                ),
                );
              },
            )
                : Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text('No hay juegos disponibles')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Invitaciones',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            // Aquí puedes poner tu lógica para cargar y mostrar las invitaciones
            // Por ahora solo mostrará un mensaje que el espacio está vacío
            _buildInvitacionesSection(),
          ],
        ),
      ),
    )
    );
  }


}

