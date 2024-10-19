import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';


class StorageHandler {
  final _secureStorage = const FlutterSecureStorage();
  final String _accountsKey = 'accountsId';

  Future<bool> saveAccountIds(List<String> ids) async {    
    String stringMap = ids.join(';');
    try {
      await _secureStorage.write(key: _accountsKey, value: stringMap);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<List<String>> readAccountIds() async {
    String? accountIds = await _secureStorage.read(key: _accountsKey);
    if(accountIds == null){ 
      // throw Exception("Ids not readed");
      return [];
    }
    return accountIds.split(';');
  }

  Future<void> savePasswordData(String key, Map data) async {    
    await _secureStorage.write(key: key, value: json.encode(data));    
  }

  Future<Map?> readPasswordData(String key) async {
    final data = await _secureStorage.read(key: key);
    if (data != null) {
      
      return json.decode(data);
    } else {
      return null;
    }
  }

  Future<void> deletePassword(String key) async {
    await _secureStorage.delete(key: key);      
  }

  Future<Directory?> getDownloadsDirectory() async {

    return Directory('/storage/emulated/0/Download');
    
  }


  Future<void> exportJsonToFile(BuildContext context, List<Map<dynamic, dynamic>> data) async {
    try {
      String jsonString = jsonEncode(data);

      // Solicitar ao usuário que selecione uma pasta usando o SAF
      final result = await FilePicker.platform.getDirectoryPath();

      if (result == null) {
        // Usuário cancelou a seleção da pasta
        return;
      }

      final String? directoryPath = result as String?;
      if (directoryPath == null) {
        // Tratamento para o caso de o resultado não ser uma String válida
        throw Exception('Invalid directory path selected');
      }

      final String filePath = '$directoryPath/aldrabo_exported_data.json';

      File file = File(filePath);
      await file.writeAsString(jsonString);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }
      
}