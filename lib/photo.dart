// ignore_for_file: prefer_final_fields, avoid_init_to_null, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:photo_sharing/home.dart';
import 'global.dart' as global;


class Photo extends StatefulWidget {
  const Photo();

  @override
  State<Photo> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Photo> {

  ImagePicker _picker = ImagePicker();
  XFile? _selectedImage = null;
  Uint8List webImage = Uint8List(8);

  Future getImageFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){

      if(kIsWeb){
        var temp = await image.readAsBytes();
        setState(() {
          print("iamgeee");
          print(image.path);
          // print(File(image.path).readAsBytesSync());
          webImage = temp;
        });
      }

      setState(() {
        _selectedImage = image;
      });

      String namaFileGallery = image.path;
      print(namaFileGallery);
    }

  }

  uploadImage() async {
    if (_selectedImage == null) return "";

    String base64Image = "";
    if(kIsWeb){
      base64Image = base64.encode(webImage);
    }else{
      base64Image = base64.encode(File(_selectedImage!.path).readAsBytesSync());
    }
    String fileName = _selectedImage!.path.split("/").last;

    Map paramData = {
      'id_user': global.idUser,
      'photo_name': fileName,
      'photo_file': base64Image,
    };

    var parameter = json.encode(paramData);
    print(parameter);

    var response = await global.sendPost("/photos", parameter);

    var result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("berhasil");
      print(result['message']);

      Navigator.of(context).pop();

    }else{
      print("gagal");
      print(result['message']);
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: kIsWeb ? global.widthWeb : double.infinity,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Upload Photo"),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200.0,
                child: Center(
                  child: _selectedImage == null
                      ? Text('No image selected.', textAlign: TextAlign.center,)
                      : kIsWeb ? Image.memory(webImage) : Image.file(File(_selectedImage!.path)),
                ),
              ),
          
              SizedBox(height: 20,),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  global.button("Select Photo", getImageFromGallery),
                  SizedBox(width: 10,),
                  global.button("Upload Photo", uploadImage)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}



