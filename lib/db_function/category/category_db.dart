

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_manager/models/category/category_model.dart';

const CATEGORY_DB_NAME = 'category-database';

abstract class CategoryDbFunction{
  Future<List<CategoryModel>> getCategories();
  Future<void> insertCategory(CategoryModel value);
} 


class CategoryDB implements CategoryDbFunction{

  CategoryDB._internal();

  static CategoryDB instance = CategoryDB._internal();

  factory CategoryDB(){
    return instance;
  }


  ValueNotifier<List<CategoryModel>> incomeCategoryListListener = ValueNotifier([]);
  ValueNotifier<List<CategoryModel>> expenseCategoryListListener = ValueNotifier([]);

  

  @override
  Future<void> insertCategory(CategoryModel value) async{

    final _categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
   await _categoryDB.add(value);
   refreshUI();
  }
  
  @override
  Future<List<CategoryModel>> getCategories()async {
     final _categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
     return _categoryDB.values.toList();
  }

  Future<void> refreshUI() async {
    final _allCategories = await getCategories();
    incomeCategoryListListener.value.clear();
    expenseCategoryListListener.value.clear();
   await Future.forEach(
      _allCategories,
       (CategoryModel category) {
        if(category.type == CategoryType.income){
          incomeCategoryListListener.value.add(category);
        }else{
          expenseCategoryListListener.value.add(category);
        }
       },
    );

    incomeCategoryListListener.notifyListeners();
    expenseCategoryListListener.notifyListeners();
  }
}