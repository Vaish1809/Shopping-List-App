import 'package:flutter/material.dart';
enum Categories{
  vegetables,
  fruit,
  meat,
  spices,
  dairy,
  carbs,
  sweets,
  convenience,
  hygiene,
  other,
}

class Category{
  //we use positional arguments instead of required. because in our data we dont have title: 'string' we have position ie.the first one is title and other is color
  const Category(this.title,this.color);
  final String title;
  final Color color;
}