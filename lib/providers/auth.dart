import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier {
  String _toke;
  DateTime _expiryDate;
  String _userId;

  Future<void> signup(String email, String password) async {
    const api_key = 'AIzaSyDq304K-ApdojX5vRwVub__1iOXDXnbZMs';
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$api_key';

    var response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    print(json.decode(response.body));
  }
}
