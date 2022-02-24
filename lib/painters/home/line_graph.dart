import 'dart:math';

import 'package:crypto_mobile_app/theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class LineGraphPainter extends CustomPainter {
  final Map<String, double> graphValues;
  late Size size;
  late Canvas canvas;

  LineGraphPainter(this.graphValues);
  @override
  void paint(Canvas canvas, Size size) {
    Paint brush = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    this.canvas = canvas;
    this.size = size;
    var newX = standardizedX();
    var newY = standardizedY();
    List<Offset> graphOffsets = [];
    for (int pointIndex = 0; pointIndex < newY.length; pointIndex++) {
      graphOffsets
          .add(Offset(newX[pointIndex], size.height - newY[pointIndex]));
    }
    // brush.shader = ui.Gradient.linear(
    //   graphOffsets[0],
    //   graphOffsets[graphOffsets.length - 1],
    //   [
    //     Colors.white,
    //     MyTheme.grapeColor,
    //   ],
    // );
    Path graphPath = Path()..addPolygon(graphOffsets, false);
    // List<Offset> shadowOffset = List<Offset>.from(graphOffsets);
    // shadowOffset.insert(0, Offset(0, size.height * 0.8));
    // shadowOffset.add(
    //     Offset(graphOffsets[graphOffsets.length - 1].dx, shadowOffset[0].dy));
    // Path shadowPath = Path()..addPolygon(shadowOffset, false);
    drawShadow(graphOffsets);
    canvas.drawPath(graphPath, brush..color = MyTheme.grapeColor);
  }

  drawShadow(List<Offset> graphOffsets) {
    Paint brush = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (int offsetCounter = 0;
        offsetCounter < graphOffsets.length - 1;
        offsetCounter++) {
      double ratio = 0.05;
      double ratioIncrement = 0.1;
      while (ratio < 1) {
        Offset point = between(graphOffsets[offsetCounter],
            graphOffsets[offsetCounter + 1], ratio);
        Offset endOfShadow = Offset(point.dx, size.height);
        brush.shader = ui.Gradient.linear(point, endOfShadow, [
          const Color.fromRGBO(162, 163, 220, 0.1),
          Colors.white,
        ], [
          0.01,
          0.4
        ]);
        canvas.drawLine(point, endOfShadow, brush);
        ratio += ratioIncrement;
      }
    }
  }

  Offset between(Offset start, Offset end, double ratio) {
    double distance =
        sqrt(pow(end.dy - start.dy, 2) + pow(end.dx - start.dx, 2));
    Offset unitVector =
        Offset((end.dx - start.dx) / distance, (end.dy - start.dy) / distance);
    return Offset(start.dx + unitVector.dx * ratio * distance,
        start.dy + unitVector.dy * ratio * distance);
  }

  List<double> standardizedY() {
    List<double> currentVvalues = List<double>.from(graphValues.values);
    double maxYValues = currentVvalues.reduce(max);
    return List<double>.generate(currentVvalues.length,
        (index) => (currentVvalues[index] / maxYValues) * size.height);
  }

  List<double> standardizedX() {
    int numofDays = graphValues.keys.length;
    return List<double>.generate(
        numofDays, (index) => (index / numofDays) * size.width);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}