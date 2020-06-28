import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _toke;
  DateTime _expiryDate;
  String _userId;

  Future<void> authenticate(String email, String password, urlSegment) async {
    const api_key = 'AIzaSyDq304K-ApdojX5vRwVub__1iOXDXnbZMs';
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$api_key';

    try {
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
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException('${responseData['error']['message']} hi error!');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    // 리턴을 해줘야 await http.post가 기다리면서 스피너 효과가 나옴 안쓸경우 바로 보내버림
    return authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }
}
