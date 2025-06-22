import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {

  final String os;
  final double? strokeWidth;
  const LoadingIndicator({super.key, required this.os, this.strokeWidth});

  @override
  Widget build(BuildContext context) {

    if(os == 'android' || os == 'web') {

      return FadeIn(
        duration: Duration(milliseconds: 100),
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
          strokeCap: StrokeCap.round,
          strokeWidth: strokeWidth ?? 4.0,
        ),
      );

    } else {

      return FadeIn(
        duration: Duration(milliseconds: 100),
        child: CupertinoActivityIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );

    }
  }
}
