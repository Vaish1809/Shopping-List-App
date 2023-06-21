import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data.dart/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _enteredCategory = categories[Categories.dairy]!;
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      //validates returns a bool
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
          'flutter-project-1-16358-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'category': _enteredCategory.title,
            'name': _enteredName,
            'quantity': _enteredQuantity
          }));
      print(response.body);
      print(response
          .statusCode); //500or 400 then error 200 or 100 then works fine
      if (!context.mounted) {
        //if the response is not yet recieved
        return;
      }
      Navigator.of(context).pop();
      //   Navigator.of(context).pop(GroceryItem(

      //       id: DateTime.now().toString(),
      //       // category: _enteredCategory,
      //       // name: _enteredName,
      //       // quantity: _enteredQuantity));
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a New Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Name must be between 1 to 50 characters. ';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Quantity must be valid positive number ';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _enteredCategory,
                        items: [
                          for (final category in categories
                              .entries) //.entries to convert map to list
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            _enteredCategory = value!;
                          });
                        }),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text("Reset")),
                  ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      // onPressed: () {
                      //   _saveItem();
                      // },
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text("Add Item"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
