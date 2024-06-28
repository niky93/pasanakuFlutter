import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:math' as mat;
import 'package:pasanaku1/GradientBackground.dart';
import 'package:flutter/material.dart';
import 'package:pasanaku1/QRViewExample.dart';
import 'Juego.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class JuegoScreen extends StatefulWidget {
  final Juego juego;
  final int idJugador;
  final int jugadorjuegoid;
  JuegoScreen(
      {required this.juego,
      required this.idJugador,
      required this.jugadorjuegoid});
  @override
  _JuegoScreenState createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  final TextEditingController _pujaController = TextEditingController();
  var turno;
  bool isOfertaEnabled = false;
  bool isPagoEnabled=false;
   var idganadorJugadorJuego;


  @override
  void initState() {
    super.initState();
    _habilitarOfertas();
  }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

  }
  void _mostrarDialogoPuja() {


    // Verificar que el input no esté vacío y sea un número
    double maxPuja = widget.juego.montoTotal as double ; // Promedio por jugador
    double minPuja = widget.juego.montoTotal  * 0.08; // 8% del monto total
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresa tu puja (El monto de la puja debe ser mayor a $minPuja  y menor a $maxPuja.)'),

          content: TextField(
            controller: _pujaController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: "Monto de la puja"),
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {

              // Convertir texto a número
              double? montoPuja = double.tryParse(_pujaController.text);

              if (_pujaController.text.isEmpty ||
                    double.tryParse(_pujaController.text) == null ) {
                  _mostrarMensaje("Por favor ingresa un monto válido.");
                  return;
                }
                // Verificar que el monto esté dentro de los límites
                if (montoPuja == null || montoPuja < minPuja || montoPuja > maxPuja) {
                  _mostrarMensaje("El monto de la puja debe ser mayor a $minPuja  y menor a $maxPuja.");
                  return;
                }
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


  Future<int> _obtenerTurno() async {
    var url = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/juegos/${widget.juego.id}/turnos/ultimo');
    try {
      var response = await http.get(url);
      if (response.statusCode <= 399) {
        var data = json.decode(response.body);
        if (!data['error']) {
          // Asume que los datos están ordenados y que el último elemento es el más reciente
          int nroTurno =data ['data']['nro_turno'];
          idganadorJugadorJuego=data ['data']['id_ganador_jugador_juego'];
          return nroTurno; // Retorna el número del ultimo turno
        } else {
          _mostrarMensaje("No se pudo obtener el turno: ${data['message']}");
        }
      } else {
        _mostrarMensaje("Error al obtener el turno: ${response.statusCode}");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión al servidor: $e");
    }
    return -1; // Retorna -1 en caso de error
  }
  void _habilitarOfertas() async {

   /*  var puja;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();
    final db = FirebaseFirestore.instance;

    db
        .collection("pujaypago")
        .get()
        .then((event) {
      List<String> tempNotificaciones = [];
      for (var doc in event.docs) {
        var notif = doc.data();
        if (notif['idFirebase'] == fcmToken && notif['idJuego']==widget.juego.id && notif['idTurno']==turno) {

         puja= notif['puja'];
        }
      }});
*/
      var url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/juegos/${widget.juego.id}/turnos/ultimo');
    try {
      var response = await http.get(url);
      if (response.statusCode <= 399) {

        var data = json.decode(response.body);
        if ( data['data']==null) {

          return;

        }
        if (!data['error'] && data['data']['estado_turno'] == "TiempoOfertas") {
          setState(() {
            isOfertaEnabled = true;

          });
        }
        if (!data['error'] && data['data']['estado_turno'] == "TiempoPagosTurnos" && data['data']['id_ganador_jugador_juego'] != widget.jugadorjuegoid) {
          setState(() {
            isPagoEnabled = true;

          });
        }

      } else {
        _mostrarMensaje("Error al obtener el turno: ${response.statusCode}");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión al servidor: $e");
    }
  }

  /*void _enviarPuja() async {
    print('**************************************************************');
    print(widget.juego.id);
    print('**************************************************************');
    turno = await _obtenerTurno();


    var url = Uri.parse(
        'https://back-pasanaku.onrender.com/api/jugadores/juegos/turno/${turno}');

    try {
      var response = await http.post(
        url,
        body: json.encode({
          'id_jugador_juego': widget.jugadorjuegoid,
          'monto_puja': int.parse(
              _pujaController.text), // Asegurándose de enviar un entero
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      var data = json.decode(response.body);
      if (response.statusCode <= 399) {
        if (!data['error']) {
          // Mensaje de éxito mostrando el monto de la puja confirmada
          setState(() {
            isOfertaEnabled = false;  // Deshabilitar el botón después de una puja exitosa
          });
          _mostrarMensaje(
              "Puja enviada correctamente monto: ${data['data']['monto_puja']}");
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
  }*/
  void _enviarPuja() async {
    _habilitarOfertas();
    turno = await _obtenerTurno();
    var url = Uri.parse('https://back-pasanaku.onrender.com/api/jugadores/juegos/turno/$turno');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    try {
      var response = await http.post(
        url,
        body: json.encode({
          'id_jugador_juego': widget.jugadorjuegoid,
          'monto_puja': int.parse(_pujaController.text),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      var data = json.decode(response.body);
      if (response.statusCode <= 399) {
        if (!data['error']) {
        /*  final fcmToken = await FirebaseMessaging.instance.getToken();
          final db = FirebaseFirestore.instance;

          final pujaypago = <String, dynamic>{
            "puja": 1,
            "idJuego":widget.juego.id,
            "idTurno":turno,

            "idFirebase": fcmToken,
            "timestamp": DateTime.now().toString()
          };

          db
              .collection("pujaypago")
              .add(pujaypago)
              .then((value) => print('DocumentSnapshot added with ID: ${value.id}'));
*/

          setState(() {
            isOfertaEnabled = false;  // Deshabilitar el botón después de una puja exitosa
          });
          _mostrarMensaje("Puja enviada correctamente monto: ${data['data']['monto_puja']}");
        } else {
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


  @override
  Widget build(BuildContext context) {
    print("/////////////////jugadorJuego////////////////////////////");
    print("JugadorJuegoId: ${widget.jugadorjuegoid}");

    print("jugadorID: ${widget.idJugador}");
    print("/////////////////////////////////////////////");
    return Scaffold(
      appBar: AppBar(
        title: Text('Pasanaku'),
          actions: <Widget>[
            /*IconButton(
            color: Colors.white,
            icon: Icon(Icons.download ),
            onPressed: () async {
              try {
                String qrUrl = await _obtenerImagen(); // Asegura obtener la URL después de la ejecución
                await downloadAndSaveImage(qrUrl);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error descargando QR: $e")));
              }
            },
          )
// Icono de actualizar QR
            onPressed: () async {
    turno = await _obtenerTurno();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRViewExample (juego:widget.juego,
                  idjugador: widget.idJugador,
                  nroTurno:
                  turno, // Pasar el turno obtenido a PaymentScreen
                  jugadorJuego: widget.jugadorjuegoid,)), // Navegar a QrLoading
              );
            },
            onPressed: () async {
              try {
                // Aquí asumimos que ya tienes la URL del QR como una variable
                String qrUrl = _obtenerImagen() as String; // Esta debería ser la URL real del QR
                await downloadAndSaveImage(qrUrl);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error descargando QR: $e")));
              }
            }) */]
      ),


      body: GradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nombre: ${widget.juego.nombre}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Fecha de inicio: ${widget.juego.fechaInicio}'),
            Text(
                'Monto total: ${widget.juego.montoTotal} ${widget.juego.moneda}'),
            Text('Cantidad de jugadores: ${widget.juego.cantJugadores} '),
            Text('Estado del juego: ${widget.juego.estadoJuego}'),
            Text('Lapso de turnos: ${widget.juego.lapsoTurnosDias} días'),

            // Incluir otros detalles que consideres necesarios
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: isOfertaEnabled ? _mostrarDialogoPuja : null,  // Button is enabled only if isOfertaEnabled is true
          child: Text('Ofertar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isOfertaEnabled ? Colors.white: Colors.grey,
          ),),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:isPagoEnabled ? () async {
                turno = await _obtenerTurno();
                if (turno != -1) {
                  // Asegurarse de que se obtuvo un turno válido antes de proceder
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => QRViewExample(juego:widget.juego,
                                idjugador: widget.idJugador,
                                nroTurno:
                                    turno, // Pasar el turno obtenido a PaymentScreen
                                jugadorJuego: widget.jugadorjuegoid,
                              )));
                } else {
                  _mostrarMensaje(
                      "No se pudo obtener un turno válido."); // Mostrar mensaje si no se obtiene un turno válido
                }
              }: null,
              child: Text('Pagar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPagoEnabled ? Colors.white: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
