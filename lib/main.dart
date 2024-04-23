import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'Registro.dart';
import 'Login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  requestNotificationPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground');
    print('Message data:${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification:${message.notification}');
    }
  });

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('Message data:$fcmToken');
  runApp(const MyApp());
}

void requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('Notification permission granted:${settings.authorizationStatus}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pasanaku',
        theme: AppTheme.lightTheme, // tema claro

        home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  HomeStart createState() => HomeStart();
}

class HomeStart extends State<Home> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _isLoading = false;
  //final TextEditingController _controller= TextEditingController();
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse('https://back-pasanaku.onrender.com/api/login');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario': _usuarioController.text,
          'contrasena': _contrasenaController.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (!data['error']) {
          // Extrayendo el JWT y la información del jugador directamente de la respuesta
          var jwt = data['data']['jwt'];
          var jugador = data['data']['jugador'];
          int jugadorId = int.parse(jugador['id']
              .toString()); //var jugador = data['data']['jugador'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                    jugadorId:
                        jugadorId /*,jugadorId: jugador['id'], jwt: jwt*/)),
          );
        } else {
          _showError('Login fallido. Intente nuevamente.');
        }
      } else {
        _showError('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error al conectar con el servidor: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ocurrió un Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method a-+++++++++bove.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text('Pasanaku'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  child: Image.asset('image/User.png'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  labelText: 'Usuario',
                  hintText: 'Digite su usuario',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _contrasenaController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    labelText: 'Contraseña',
                    hintText: 'Digite su contraseña'),
                obscureText: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 50, right: 10),
              child: Center(
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text('Ingresar'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 10, right: 10),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    //     print('Boton presionado');
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Registro()));
                  },
                  child: Text('Registro'),
                ),
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
