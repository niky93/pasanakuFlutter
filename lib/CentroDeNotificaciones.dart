import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Asegúrate de tener este import para las opciones de Firebase

class CentroDeNotificaciones extends StatefulWidget {
  @override
  _CentroDeNotificacionesState createState() => _CentroDeNotificacionesState();
}

class _CentroDeNotificacionesState extends State<CentroDeNotificaciones> {
  List<String> notificaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarData();
  }

  void _cargarData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();
    final db = FirebaseFirestore.instance;

    db
        .collection("notifications")
        .orderBy("timestamp", descending: true)
        .get()
        .then((event) {
      List<String> tempNotificaciones = [];
      for (var doc in event.docs) {
        var notif = doc.data();
        if (notif['idFirebase'] == fcmToken) {
          tempNotificaciones.add("${notif['title']}: ${notif['body']}");
        }
      }

      setState(() {
        notificaciones = tempNotificaciones;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body: notificaciones.isEmpty
          ? Center(child: Text('No hay notificaciones.'))
          : ListView.builder(
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(notificaciones[index]),
                    trailing: Icon(Icons.notifications),

                  ),
                  color: Colors.transparent,
                );
              },
            ),
    );
  }
}
