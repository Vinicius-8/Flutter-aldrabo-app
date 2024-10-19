import 'package:flutter/material.dart';

class SnackBarCustom {
  static void showSnackBar(BuildContext context, String message, {String? alertType, int seconds = 2}) {
      late Color? alert;

      switch (alertType) {
        case "green": alert = Colors.green[600];
          break;
        case "red": alert = Colors.redAccent[400]!;
          break;        
        case "yellow": alert = Colors.yellow[900];
          break;        
        case "blue": alert = Colors.blue[400];
          break;        
        default:
        alert = ThemeData().primaryColor;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: seconds),
          backgroundColor: alert
        ),
      );
    }
}