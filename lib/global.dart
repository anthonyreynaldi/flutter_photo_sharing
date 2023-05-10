import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// String baseUrl = "https://192.168.1.4/SOA/UtsPhotoSharing/public";
String baseUrl = "https://uts-soa.000webhostapp.com";
String idUser = "";
double? widthWeb = 576;

inputText(label, inputC){
  return
  TextField(
    controller: inputC,
    keyboardType: TextInputType.text,
    autofocus: false,
    decoration: InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.symmetric(
        vertical:  10,
        horizontal:  20
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[200],
    ),
  );
}

button(text, onPress){
  return
  FilledButton(
    // style: ButtonStyle(
    //   foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),

    // ),
    onPressed: onPress,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 15),
        
      ),
    )
  );
}

sendPost(url, body) async {
  var result = null;
  await http.post(Uri.parse(baseUrl + url), 
      headers: {"Content-Type": "application/json"}, body: body)
      .then((res) {
        print(res.body);
        result = res;
        // return jsonDecode(res.body);
      }).catchError((err) {
        print(err);
        result = err;
        // return jsonDecode(err);
      });
  return result;
}

sendGet(url) async {
  var result = null;
  await http.get(Uri.parse(baseUrl + url), 
      headers: {"Content-Type": "application/json"})
      .then((res) {
        print(res.body);
        result = res;
        // if (res.body.contains("sukses")) {
        // }
      }).catchError((err) {
        print(err);
        result = err;
      });

  return result;
}

// class CustomResponse{
//   final String statusCode;
//   final String message;
//   final data;

//   const CustomResponse({required this.statusCode, required this.message, this.data})

//   factory 
// }