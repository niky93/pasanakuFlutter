import 'package:flutter/cupertino.dart';

class CircularImage extends StatelessWidget {
  final String assetName;
  final double size;

  const CircularImage({
    Key? key,
    required this.assetName,
    this.size = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        assetName,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
