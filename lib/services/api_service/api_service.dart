import 'package:api_and_json_server/data/database/moor_database.dart';
import 'package:api_and_json_server/data/person/person.dart';
import 'package:api_and_json_server/services/api_service/api_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app.dart';

class ApiService extends ApiInterface {
  final String url = 'http://localhost:3000/people';
  Dio dio = Dio();

  @override
  // ignore: missing_return
  //TODO: It should actually rethrow error (please never silence errors expect its totally required)
  //TODO: Remove try catch from here and handle error in method's caller.
  Future<List<User>> fetchData() async {
    try {
      Response response = await dio.get(url);
      final List<Person> persons = (response.data as List<dynamic>)
          .map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList();
      List<User> users = persons.map((user) => user.toEntity()).toList();

      App.appDatabase.userDao.insertAll(users);

      return users;
    } catch (e) {}
  }

  @override
  Future<void> insertUser({@required int id, @required String name}) async {
    await dio.post('$url', data: {'id': id, 'name': name, 'isFavorite': false});
  }

  @override
  Future<void> deleteUser({@required int id}) async {
    await dio.delete('$url/$id');
  }

  @override
  Future<void> updateName({@required int id, @required String name}) async {
    await dio.patch('$url/$id', data: {'name': name});
  }

  @override
  Future<void> updateIsFavorite(
      {@required int id, @required bool isFavorite}) async {
    await dio.patch('$url/$id', data: {'isFavorite': isFavorite});
  }
}
