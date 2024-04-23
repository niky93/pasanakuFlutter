import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomeScreen.dart';

class Login extends StatefulWidget {
  @override
  LoginApp createState() => LoginApp();
}

class LoginApp extends State<Login> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _isLoading = false;

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
           int jugadorId = int.parse(jugador['id'].toString());//var jugador = data['data']['jugador'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(jugadorId: jugadorId/*,jugadorId: jugador['id'], jwt: jwt*/)),
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Ingrese Login'),
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
                    child: Image.asset('images/User.png'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: TextField(
                  controller: _usuarioController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    labelText: 'Contraseña',
                    hintText: 'Digite su contraseña'

                  ),obscureText: true,
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
            ],
          ),
        )
    );
  }
}
