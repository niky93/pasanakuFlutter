import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class QRHandler extends StatefulWidget {
  final String imageUrl;

  QRHandler({required this.imageUrl});

  @override
  _QRHandlerState createState() => _QRHandlerState();
}

class _QRHandlerState extends State<QRHandler> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download Image from QR Code"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => downloadAndSaveImage(widget.imageUrl),
              child: Text("Download Image"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Get the temporary directory
        final directory = await getTemporaryDirectory();
        // Create a file in the temporary directory
        File imgFile = File('${directory.path}/QR_Image_${DateTime.now().millisecondsSinceEpoch}.png');
        // Write the bytes of the downloaded image to the file
        await imgFile.writeAsBytes(response.bodyBytes);

        // Save the image from the local file to the gallery
        bool? success = await GallerySaver.saveImage(imgFile.path);
        if (success == true) {
          showFeedback("Image downloaded successfully!");
        } else {
          showFeedback("Failed to download image.");
        }
      } else {
        showFeedback("Failed to fetch image from the URL.");
      }
    } catch (e) {
      showFeedback("Error: $e");
    }
  }

  void showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }
}
