import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data.dart/categories.dart';
import 'package:shopping_list_app/models/groceryItems.dart';
import 'package:shopping_list_app/widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loaditems();
  }

  void _loaditems() async {
    final url = Uri.https('flutter-project-1-16358-default-rtdb.firebaseio.com',
        'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data try again later.';
        });
      } // print(response.body);
      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> _loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        _loadedItems.add(GroceryItem(
            category: category,
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity']));
      }
      setState(() {
        _groceryItems = _loadedItems;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch data try again later.';
      });
    }
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      // final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    _loaditems();

    // if (newItem == null) {
    //   return;
    // }
    // setState(() {
    //   _groceryItems.add(newItem);
    // });
  }

  void _onRemove(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('flutter-project-1-16358-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("Add Items to Your Shopping List"),
    );
    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _onRemove(_groceryItems[index]);
          },

          background: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.55),
          ),
          key: ValueKey(_groceryItems[index].id), //unique value
          child: ListTile(
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryItems[index].category.color,
            ),
            title: Text(_groceryItems[index].name),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
