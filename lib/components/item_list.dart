import 'package:aldrabo/pages/item_page.dart';
import 'package:flutter/material.dart';

class ItemList extends StatefulWidget {
  final Map data;
  const ItemList({super.key, required this.data});

  @override
  State<ItemList> createState() => _ItemListState();
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}


class _ItemListState extends State<ItemList> {
  bool showPass = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(boxShadow: [ BoxShadow(
        color: Color.fromARGB(230, 14, 14, 14),
        blurRadius: 4,
        offset: Offset(3, 5), // Shadow position
      ),]),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ItemPage(data: widget.data)),
                );
              },
              child: Container(
                height: 62,
                padding: const EdgeInsets.only(left: 15, top: 3),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 43, 43, 53),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4))
                ),
              
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.data[(!showPass ? "title" : "password")].toString().capitalize(), style: const TextStyle(fontSize: 25),),
                      Text(widget.data["username"], style: const TextStyle(fontSize: 10),)
                    ],
                  )          
                ),
              ),
            ),
          ),
      
      
          // eye 
          Expanded(
            child: GestureDetector(
                onTap: () 
                   {
                    showPass = !showPass;                
                    setState(() {});
                   },
                child: Container(
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 43, 43, 53),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))
                  ),
                  child: !showPass ? const Icon(Icons.remove_red_eye): const Icon(Icons.visibility_off),
                ),
              ),
          ),
        ],
      ),
    );
  }
}