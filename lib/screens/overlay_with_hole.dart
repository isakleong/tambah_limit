import 'package:flutter/material.dart';

class OverlayWithHole extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutterclutter: Holes")),
      body: _getExperimentOne()
    );
  }

  Stack _getExperimentOne() {
    return Stack(children: <Widget>[
      _getContent(),
      _getClipPathOverlay(),
      _getHint()
    ]);
  }

  Stack _getExperimentTwo(BuildContext context) {
    return Stack(children: <Widget>[
      _getContent(),
      _getCustomPaintOverlay(context),
      _getHint()
    ]);
  }

  Stack _getExperimentThree() {
    return Stack(children: <Widget>[
      _getContent(),
      _getColorFilteredOverlay(),
      _getHint()
    ]);
  }

  Widget _getContent() {
    return Container(
      color: Colors.redAccent,
      child: Center(
          child: Text("This is the Background")
      )
    );
  }

  ColorFiltered _getColorFilteredOverlay() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black54,
        BlendMode.srcOut
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.only(right: 4, bottom: 4),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  // Color does not matter but must not be transparent
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Center(child: Image.asset('assets/illustration/logo.png', width: 128, height: 128, fit: BoxFit.cover)),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text("Flutter is awesome", style: TextStyle(fontSize: 40))
            ),
          )
        ],
      ),
    );
  }

  Positioned _getHint() {
    return Positioned(
      bottom: 26,
      right: 96,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(4)
          )
        ),
        child: Row(
          children: [
            Text("You can add news pages with a tap"),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_forward, color: Colors.black54,)
            )
          ]
        ),
      )
    );
  }

  CustomPaint _getCustomPaintOverlay(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: HolePainter()
    );
  }

  ClipPath _getClipPathOverlay() {
    return ClipPath(
      clipper: InvertedClipper(),
        child: Container(
          color: Colors.black54,
        ),
    );
  }
}

class HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(
          Rect.fromLTWH(0, 0, size.width, size.height)
        ),
        Path()
          ..addOval(Rect.fromCircle(center: Offset(size.width -44, size.height - 44), radius: 40))
          ..close(),
      ),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class InvertedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(
          Rect.fromLTWH(0, 0, size.width, size.height)
      ),
      Path()
        ..addOval(Rect.fromCircle(center: Offset(size.width -44, size.height - 44), radius: 40))
        ..close(),
    );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}