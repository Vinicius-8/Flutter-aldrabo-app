import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a StateNotifier to manage the mutable state of the list of strings
class PasswordListNotifier extends Notifier<List<Map>> {

  // Method to add a new Map to the list
  void addPasswordData(Map data) {
    state = [...state, data];
  }

  void deletePassword(Map data){
    state.removeWhere((element) => element["id"] == data["id"]);
  }

  void init(List<Map> list){
    state = list;
  }

  void changePassword(String id, Map data){
    int index = state.indexWhere((e) => e["id"] == id);
    state[index] = data;
  }
  
  @override
  List<Map> build() {    
    return [];
  }
}

// Create a StateNotifierProvider to provide the instance of StateNotifier
final passwordListProvider = NotifierProvider<PasswordListNotifier, List<Map>>(() {
  return PasswordListNotifier();
});

// // Inside your widget where you want to update the state
// final passwordList = context.read(passwordListProvider); // or context.watch(passwordListProvider);

// // Add a new password to the list
// passwordList.addPassword('newPassword');
