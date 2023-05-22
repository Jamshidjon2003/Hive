import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  final _shop = Hive.box("shop");

  final nameC = TextEditingController();
  final quantityC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ertangi vazifalar")),
      body: ListView.builder(
        itemBuilder: (_, index) {
          final currentItem = _items[index];
          return Card(
            color: Colors.white38,
            child: ListTile(
              title: Text(currentItem["name"]),
              subtitle: Text(currentItem["quantity"].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    color: Colors.white,
                    onPressed: () {
                      _showForm(context, currentItem["key"]);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    color: Colors.white,
                    onPressed: () => _deleteItem(currentItem["key"]),
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: _items.length,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white38,
        child: const Icon(Icons.add_task,color: Colors.white,),
        onPressed: () => _showForm(
          context,
          null,
        ),
      ),
    );
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
      _items.firstWhere((element) => element["key"] == itemKey);
      nameC.text = existingItem["name"];
      quantityC.text = existingItem["quantity"];
    }

    showModalBottomSheet(
      isScrollControlled: true,
      elevation:0,
      context: ctx,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                hintText: 'name',
              ),
            ),
            TextField(
              controller: quantityC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'quantity',
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (itemKey == null) {
                    _createItem({
                      "name": nameC.text,
                      "quantity": quantityC.text,
                    });
                  }
                  if (itemKey != null) {
                    _updateItem(
                      itemKey,
                      {
                        "name": nameC.text,
                        "quantity": quantityC.text,
                      },
                    );
                  }

                  nameC.clear();
                  quantityC.clear();
                  Navigator.pop(context);
                },
                child:
                itemKey == null ? const Text("save",style: TextStyle(
                  color:Colors.blueGrey
                ),) : const Text("update",style:TextStyle(
                  color: Colors.blueGrey
                ),))
          ],
        ),
      ),
    );
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shop.add(newItem);
    print("----> amount shop lenght: ${_shop.length}");
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> oldItem) async {
    await _shop.put(itemKey, oldItem);
    print("----> amount shop lenght: ${_shop.length}");
    _refreshItems();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _shop.delete(itemKey);
    print("----> amount shop lenght: ${_shop.length}");
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("item deleted!!!")));
    _refreshItems();
  }

  void _refreshItems() {
    final data = _shop.keys.map((key) {
      final item = _shop.get(key);
      return {
        "key": key,
        "name": item["name"],
        "quantity": item["quantity"],
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      print("----> _items length: ${_items.length}");
    });
  }
}
