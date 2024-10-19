import 'dart:math';

import 'package:aldrabo/components/snackbar_custom.dart';
import 'package:aldrabo/handlers/storage_handler.dart';
import 'package:aldrabo/providers/passwords_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ItemPage extends ConsumerStatefulWidget {
  final Map? data;
  const ItemPage({super.key, this.data});

  @override
  ConsumerState<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends ConsumerState<ItemPage> {

  late Map? data;
  bool _showReloadIcon = true;

  final TextEditingController _cTitle = TextEditingController();
  final TextEditingController _cUsername = TextEditingController();
  final TextEditingController _cPassword = TextEditingController();
  final TextEditingController _cDescription = TextEditingController();


  @override
  void initState() {
    data = widget.data;
    if(data != null){
      _cTitle.text = data!['title'];
      _cUsername.text = data!['username'];
      _cPassword.text = data!['password'];
      _cDescription.text = data!['description'] ?? '';
      _showReloadIcon = false;
      setState(() {
        
      });
    }

    super.initState();
  }

  

  void _savePassword(){
    
    if(
      _cTitle.text.isEmpty ||
      _cUsername.text.isEmpty ||
      _cPassword.text.isEmpty
    ){
      SnackBarCustom.showSnackBar(context, "Empty field!", alertType: 'yellow');
      return;
    } else if(
      _cTitle.text.contains(';') || _cTitle.text.contains(':') ||
      _cUsername.text.contains(';') || _cUsername.text.contains(':') ||
      _cPassword.text.contains(';') || _cPassword.text.contains(':') 
    ){
      SnackBarCustom.showSnackBar(context, "Character ; not allowed!", alertType: 'yellow');
      return;
    }
    List<String> savedIds = ref.watch(passwordListProvider).map((e) => e["id"].toString()).toList();  

    String id = data != null ? data!["id"] : const Uuid().v4();

    Map tempData = {
      "id": id,
      "title": _cTitle.text,
      "username": _cUsername.text,
      "password": _cPassword.text,
      "description": _cDescription.text
    };
    
    StorageHandler().savePasswordData(id, tempData).then((value) {
      SnackBarCustom.showSnackBar(context, "The password was saved", alertType: 'green');
      data = tempData;
      if(!savedIds.contains(id)) {
        savedIds.add(id); // adds to the list that goes to the devices
        ref.read(passwordListProvider.notifier).addPasswordData(tempData); // add to the state
      } else {
        ref.read(passwordListProvider.notifier).changePassword(id, tempData);
      }

      StorageHandler().saveAccountIds(savedIds); // save in the device

      Navigator.pop(context);
    });
    
  }

  // delete rotines
  Widget _deletePasswordWidget(){
    return data != null ? 
    GestureDetector(
      child: const Icon(Icons.delete),
      onTap: () {
        _popupDeletePassword();
      },
    )
    
    : const SizedBox();
  }

  void _popupDeletePassword(){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Alert'),
          content: const Text('Delete password?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Executar ação de confirmação
                _deletePassword().then((value) { 
                  Navigator.pop(context, true);
                  Navigator.pop(context);
                  });                
              },
              child: const Text('Ok'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
  }

  Future _deletePassword() async {
    List<String> savedIds = ref.watch(passwordListProvider).map((e) => e["id"].toString()).toList();

    StorageHandler().deletePassword(data!["id"]).then((value) {
      SnackBarCustom.showSnackBar(context, "The password was deleted", alertType: 'green');

      savedIds.remove(data!["id"]); // remove from list of ids, to save this ids later
      ref.read(passwordListProvider.notifier).deletePassword(data!); // delete data from state
      StorageHandler().saveAccountIds(savedIds); // save the 'new' ids list in the device
    });
  }

  Widget _customTextFormField(String fieldName, TextEditingController controller){
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: TextFormField(   
        controller: controller,
        cursorColor: Theme.of(context).highlightColor,  
        style: const TextStyle(fontSize: 17),      
        decoration: InputDecoration(          
          labelText: fieldName,
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 230, 230, 235),            
          ),
         
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 43, 43, 53), width: 2),
          ),
        ),
      ),
    );
  }
  
  Widget _customTextFormFieldPassword(String fieldName, TextEditingController controller){
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: TextFormField(   
        controller: controller,        
        cursorColor: Theme.of(context).highlightColor,  
        style: const TextStyle(fontSize: 17),   
        onChanged: (value) {
          if(_cPassword.text.isEmpty){
            _showReloadIcon = true;
          } else {
            _showReloadIcon = false;
          }
          setState(() {
            
          });
        },
        decoration: InputDecoration(          
          labelText: fieldName,
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 230, 230, 235),            
          ),
          suffixIcon: _showReloadIcon ?  GestureDetector(
            onTap: (){
              _generatePassword();
            },
            child: const Icon(
              Icons.replay_outlined,
            ),
          ): null,        
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 43, 43, 53), width: 2),
          ),
        ),
      ),
    );
  }

  void _generatePassword(){
    int size = 12;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final rng = Random();
    String  pwd =  String.fromCharCodes(Iterable.generate(size, (_) => chars.codeUnitAt(rng.nextInt(chars.length))));
    _cPassword.text = pwd;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
        title: Row(
          children: [
            Text(data != null ? "Edit Password" : "New Password"),
            const Spacer(),
            _deletePasswordWidget()
          ],
        ),),
        body: Column(children: [
          _customTextFormField('Title', _cTitle),
          const SizedBox(height: 15),
      
          _customTextFormField('Username', _cUsername),
          const SizedBox(height: 15),
          
          _customTextFormFieldPassword('Password', _cPassword),
          const SizedBox(height: 15),

          _customTextFormField('Description', _cDescription),
          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                     _savePassword();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 43, 43, 53), minimumSize: Size(MediaQuery.of(context).size.height / 2, 50)),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 20, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],),        
      ),
    );
  }
}