import 'package:flutter/cupertino.dart';

extension DoubleOperations on double {

  Widget get vrSpace => SizedBox(height: this);
  Widget get hrSpace => SizedBox(width: this);

}


extension ColorOperations on Color {

  Color withPredefinedOpacity(double opacity) {

    final red = (r * 255).round();
    final green = (g * 255).round();
    final blue = (b * 255).round();

    // Convert opacity (0-1) to alpha (0-255)
    final alpha = (opacity * 255).round();

    return Color.fromARGB(alpha, red, green, blue);

  }



}