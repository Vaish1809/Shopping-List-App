import'package:shopping_list_app/models/category.dart';

class GroceryItem{
 
  const GroceryItem({required this.category,required this.id,required this.name,required this.quantity});
  // id: 'a',
  //     name: 'Milk',
  //     quantity: 1,
  //     category: categories[Categories.dairy]!),
final String id;
final String name;
final int quantity;
final Category category;

}