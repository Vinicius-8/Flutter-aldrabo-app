import 'dart:io';

import 'package:aldrabo/components/snackbar_custom.dart';
import 'package:aldrabo/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final localAuth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    final supported = await localAuth.isDeviceSupported();
    if (!supported) {
      // Handle the case where biometrics is not supported      
      return false;
    }    
    return true;
  }

  Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app securely',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true
        ),        
      );
      return authenticated;
    } on PlatformException catch (e) {

      if (e.code == 'NotAvailable') {
        // Handle the case where biometrics is not available
        debugPrint('Biometrics not available at this time.');
      } else if (e.code == 'PassphraseNotSet') {
        // Handle the case where no fingerprint/face ID is enrolled
        debugPrint('No fingerprint or face ID enrolled on this device.');
      } else {
        // Handle other errors
        debugPrint(e.message);
      }
      return false;
    }
  }

  void login() async {
    
    authenticate().then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()
      )).then((value) => exit(0));
      
    }).onError((error, stackTrace) {
      if(mounted) SnackBarCustom.showSnackBar(context, "Biometrics not supported on this device.", alertType: "red", seconds: 3);
    });
      
  }

  @override
  void initState() {
    login();
    super.initState();        
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(child: 
       Column(
         children: [
            const Expanded(child: SizedBox()),
            Expanded(child: Column(children: [
              const SizedBox(height: 80,),
              Center(
                child: SizedBox(
                width: 150,
                height: 150,
                child: Image.asset('assets/logo_blue.png')),
              ),

              // ElevatedButton(onPressed: () => login(), child:  Text('Login')),
            ],)),
            const Expanded(child: SizedBox())
         ],
       ),),
    );
  }
}