// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_sharing/comment.dart';
import 'package:photo_sharing/photo.dart';
import 'global.dart' as global;


class Post extends StatefulWidget {
  
  Post() : super();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Post> {
  var listPhotos = [];
  var selectedPhotos = {};
  TextEditingController captionC = new TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  _MyHomePageState() {
    getPhotos();
  }

  Future<void> getPhotos() async {
    var response = await global.sendGet("/users/" + global.idUser + "/photos");

    response = jsonDecode(response.body);

    setState(() {
      listPhotos = response['data'];
    });
  }

  Future<String> getPhotoUrl(id_photo) async {
    print("id photo: " + id_photo);
    var response = await global.sendGet("/photos/" + id_photo);

    if(response.statusCode == 200){
      response = jsonDecode(response.body);
      return global.baseUrl + "/uploads/photos/" + response['data']['photo_name'];    //the url of photo
    }

    return "https://developers.google.com/static/maps/documentation/maps-static/images/error-image-generic.png";
  }

  postPost() async {
    var id_photos = [];

    selectedPhotos.forEach((key, value) {
      id_photos.add(key);
    });

    Map paramData = {
      'id_user': global.idUser,
      'caption': captionC.text,
      'id_photos': id_photos,
    };

    var parameter = json.encode(paramData);

    var response = await global.sendPost("/posts", parameter);

    var result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("berhasil");
      print(result['message']);

      Navigator.of(context).pop();

    }else{
      print("gagal");
      print(result['message']);
      
    }
  }

  showPhoto(id_photo){
    return
    Container(
      height: 150,
      margin: EdgeInsets.only(right: 20),
      child: FutureBuilder(
        future: getPhotoUrl(id_photo),
        builder:(context, AsyncSnapshot<String> snapshot) {
          return Image.network(snapshot.data ?? "https://developers.google.com/static/maps/documentation/maps-static/images/error-image-generic.png");
        },
      ),
    );
  }

  tooglePhoto(id_photo, checked){

    if(checked){
      selectedPhotos[id_photo] = true;
    }else{
      selectedPhotos.remove(id_photo);
    }
    setState(() {
      selectedPhotos;
    });

    // print('state controller');
    // print(photosContoller);
    // print("selected");
    // print(selectedPhotos);
  }

  Widget showPhotosItem(id_photo){
    return
    CheckboxListTile(
      value: selectedPhotos[id_photo] ?? false, 
      onChanged: (checked) => { 
        tooglePhoto(id_photo, checked)
       },
      title: showPhoto(id_photo),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: kIsWeb ? global.widthWeb : double.infinity,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Make Post')
            ),
          
            body: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: getPhotos,
                    child: ListView.builder(
                      itemCount: listPhotos.length,
                      itemBuilder: (BuildContext context, int index){
                        return showPhotosItem(listPhotos[index]);
                      }
                    ),
                  ),
                ),
          
                ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: global.inputText("Input Caption", captionC),
                  ),
                  trailing: global.button("Post", () => { postPost() })
                )
              ],
            )
          ),
      ),
    );
  }
}

