import 'package:aldrabo/components/item_list.dart';
import 'package:aldrabo/handlers/storage_handler.dart';
import 'package:aldrabo/pages/item_page.dart';
import 'package:aldrabo/providers/passwords_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';


class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {

  final TextEditingController _cSearch = TextEditingController();

  List<Map> pwds = [];
  List<Map> pwdsFiltered = [];

  bool allowVisibilityDetector = false;

  void _searchPassword(String value){
    pwdsFiltered = ref.watch(passwordListProvider).where((e) => e["title"].toLowerCase().contains(value) || e["username"].toLowerCase().contains(value)).toList();
    setState(() {});
  }

  Widget _passwordListing(){
   return pwdsFiltered.isNotEmpty ? Column(
    children: pwdsFiltered.map((e) => Column(
      children: [
        ItemList(data: e,),
        const SizedBox(height: 8,)
      ],
    )).toList()) : const Text('Nothing yet', style: TextStyle(color: Color.fromARGB(255, 81, 81, 102)),);
  }

  void _loadPasswords() async {
    // List<String> ids = ref.watch(passwordListProvider);
    StorageHandler sh = StorageHandler();
    sh.readAccountIds().then((value) async {// reads all ids from device's storage
      for (var id in value) {
        var data  = await sh.readPasswordData(id); // read each password data by it's id
        if(data != null) pwds.add(data); // adds the data into list if not null
      }
      pwdsFiltered = pwds;
      ref.read(passwordListProvider.notifier).init(pwds);
      setState(() {});
    });    
  }
 
  @override
  void initState() {
    _loadPasswords();
    super.initState();
  }


  Widget _exportWidget(){
    return GestureDetector(
      onTap: () {
         _popupExportPasswords();
      },              
      child: const Icon(Icons.file_download),
    );
  }

  void _popupExportPasswords(){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Alert'),
          content: const Text('Export all passwords?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Executar ação de confirmação
                _exportAllPasswords();  
                Navigator.pop(context); 
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

  void _exportAllPasswords() async {   
    await StorageHandler().exportJsonToFile(context, pwds);
  }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title:  Row(
            children: [
              const SizedBox(),
              const Spacer(),
              const Text('ALDRABO'),
              const Spacer(),
              _exportWidget()
            ],
          ), automaticallyImplyLeading: false,),
      
        body: VisibilityDetector(
          key: Key(widget.key.toString()),
          onVisibilityChanged: (info) {      
            if(info.visibleBounds.bottom != 0 && allowVisibilityDetector){
              pwds = ref.watch(passwordListProvider);
              pwdsFiltered = ref.watch(passwordListProvider);  
              allowVisibilityDetector = false;
              setState(() {});       
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
          
                  // search bar
                  SearchBar(
                    controller: _cSearch,
                    hintText: "Search password",
                    leading: const Icon(Icons.search),
                    onChanged: (value) => {
                      _searchPassword(value)
                    },
                  ),
                  const SizedBox(height: 20),
          
          
                  // listing
                  _passwordListing(),
                  // const SizedBox(height: 20,)
                ],
              ),
            ),
          ),
        ),
        floatingActionButton:  FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  const ItemPage()),
            ).then((value) {
              allowVisibilityDetector = true;
            },);
          },
          backgroundColor: const Color.fromARGB(255, 76, 76, 117),
          child: const Icon(Icons.add),
        ),
        
      ),
    );
  }
}