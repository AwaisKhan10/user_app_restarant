import 'package:flutter/material.dart';



class CustomLabelPaint extends StatelessWidget {
  const CustomLabelPaint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(110, 30),
      painter: LabelPaint(),
    );
  }
}


class LabelPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();


    // Path number 1


    paint.color = Color(0xffFF6B00);
    path = Path();
    path.lineTo(0, size.height * 0.27);
    path.cubicTo(0, size.height * 0.12, size.width * 0.04, 0, size.width * 0.08, 0);
    path.cubicTo(size.width * 0.08, 0, size.width * 0.97, 0, size.width * 0.97, 0);
    path.cubicTo(size.width, 0, size.width, size.height * 0.1, size.width, size.height * 0.17);
    path.cubicTo(size.width, size.height * 0.17, size.width * 0.95, size.height * 0.35, size.width * 0.95, size.height * 0.35);
    path.cubicTo(size.width * 0.93, size.height * 0.44, size.width * 0.93, size.height * 0.56, size.width * 0.95, size.height * 0.65);
    path.cubicTo(size.width * 0.95, size.height * 0.65, size.width, size.height * 0.83, size.width, size.height * 0.83);
    path.cubicTo(size.width, size.height * 0.9, size.width, size.height, size.width * 0.97, size.height);
    path.cubicTo(size.width * 0.97, size.height, 0, size.height, 0, size.height);
    path.cubicTo(0, size.height, 0, size.height * 0.27, 0, size.height * 0.27);
    path.cubicTo(0, size.height * 0.27, 0, size.height * 0.27, 0, size.height * 0.27);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
