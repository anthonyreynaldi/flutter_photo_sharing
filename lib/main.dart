// ignore_for_file: prefer_final_fields, avoid_init_to_null, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:photo_sharing/home.dart';
import 'global.dart' as global;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Sharing',
      theme: ThemeData(
        primarySwatch: Colors.blue, useMaterial3: true
      ),
      home: const MyHomePage(title: 'SOA Photo Sharing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  signUp() async {
    Map paramData = {
      'name': namaC.text,
      'email': emailC.text,
      'password': passC.text,
    };

    var parameter = json.encode(paramData);

    var response = await global.sendPost("/users", parameter);

    var result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("berhasil");
      print(result['message']);

      setState(() {
        message = result['message'];
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home()));

    }else{
      print("gagal");
      print(result['message']);
      
      setState(() {
        message = result['message'];
      });
    }

    // Navigator.push(this.context, MaterialPageRoute(Builder: (context) => null))
  }
  
  signIn() async {
    var response = await global.sendGet("/users");

    var result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("berhasil");
      print(result['message']);

      var listUsers = result['data'];

      for (var user in listUsers) {
        if(emailC.text == user['email']){
          message = "Berhasil Login";
          global.idUser = user['id'];
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home()));
          break;
        }
      }

      setState(() {
        message;
      });

    }else{
      print("gagal");
      print(result['message']);
      
      setState(() {
        message = result['message'];
      });
    }
  }

  bodySignup(){
    return
    Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          global.inputText("Masukan Nama", namaC),
          SizedBox(height: 10,),
          global.inputText("Masukan Email", emailC),
          SizedBox(height: 10,),
          global.inputText("Masukan Password", passC),
          SizedBox(height: 10,),
          Text(message, style: TextStyle(color: Color.fromARGB(150, 255, 0, 0)),),
          SizedBox(height: 10,),
          global.button("Sign Up", signUp),
        ],
      ),
    );
  }
  
  bodySignin(){
    return
    Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          global.inputText("Masukan Email", emailC),
          SizedBox(height: 10,),
          global.inputText("Masukan Password", passC),
          SizedBox(height: 10,),
          Text(message, style: TextStyle(color: Color.fromARGB(150, 255, 0, 0)),),
          SizedBox(height: 10,),
          global.button("Sign In", signIn),
        ],
      ),
    );
  }

  TextEditingController namaC = new TextEditingController();
  TextEditingController emailC = new TextEditingController();
  TextEditingController passC = new TextEditingController();
  String message = "";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: kIsWeb ? global.widthWeb : double.infinity,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(tabs: [
                Tab(icon: Icon(Icons.person_add_alt_1),),
                Tab(icon: Icon(Icons.login),),
              ],),
              title: Text(widget.title),
            ),
            body: TabBarView(
              children: [
                bodySignup(),
                bodySignin(),
              ],
            )
          ),
        ),
      ),
    );
  }
}