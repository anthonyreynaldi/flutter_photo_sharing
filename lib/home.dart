// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_sharing/comment.dart';
import 'package:photo_sharing/photo.dart';
import 'package:photo_sharing/post.dart';
import 'global.dart' as global;


class Home extends StatefulWidget {
  
  Home() : super();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  var listPosts = [];

  @override
  void initState() {
    super.initState();
  }

  _MyHomePageState() {
    getPosts();
  }

  Future<void> getPosts() async {
    var response = await global.sendGet("/posts");

    response = jsonDecode(response.body);

    setState(() {
      listPosts = response['data'];
    });
  }

  Future<String> getUsername(id_user) async {
    var response = await global.sendGet("/users/" + id_user);

    print(id_user);

    if(response.statusCode == 200){
      response = jsonDecode(response.body);
      print(response);
      return response['data']['name'];
    }

    return "Unknown User";
  }

  Future<dynamic> getPost(id_post) async {
    var response = await global.sendGet("/posts/" + id_post);

    if(response.statusCode == 200){
      var aresponse = jsonDecode(response.body);
      
      return aresponse['data'];
    }

    response = {
      'id': "123",
      'id_user': "234",
      'caption': "Captions",
      'photos': ["345"],
    };

    return response;
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

  showComment(idPost){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Comment(idPost: idPost)));
  }

  deletePost(idPost) async {
    Map paramData = {
      '_method': "DELETE",
    };

    var parameter = json.encode(paramData);

    var response = await global.sendPost("/posts/$idPost", parameter);

    var result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("berhasil");
      print(result['message']);

      getPosts();

    }else{
      print("gagal");
      print(result['message']);
    }
  }

  showPhoto(id_photo){
    return
    Container(
      margin: EdgeInsets.only(right: 20),
      child: Center(
        child: FutureBuilder(
          future: getPhotoUrl(id_photo),
          builder:(context, AsyncSnapshot<String> snapshot) {
            return Image.network(snapshot.data ?? "https://developers.google.com/static/maps/documentation/maps-static/images/error-image-generic.png");
          },
        ),
      ),
    );
  }

  Widget showPost(post){
    return
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //username
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 0, 0))),
          onPressed: null,
          child: FutureBuilder(
            future: getUsername(post["id_user"]),
            builder: ( (BuildContext context, AsyncSnapshot<String> snapshot) {
              if(snapshot.hasData){
                return Text( snapshot.data ?? "Unkown User");
              }              
              return Center(child: CircularProgressIndicator());
            })
          )
        ),

        //list view photos
        Container(
          height: 300,
          child: FutureBuilder(
            future: getPost(post['id']),
            builder:(context, AsyncSnapshot<dynamic> snapshot) {
              if(snapshot.hasData){
                return 
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!['photos'].length,
                  itemBuilder: (context, index) {
                    // return Text(snapshot.data!['photos'].toString());
                    return showPhoto(snapshot.data!['photos'][index]);
                  },
                );
              }

              return Center(child: CircularProgressIndicator());
            },
          ),
        ),

        //caption
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: Text(post['caption']),
        ),

        //comments and delete
        Row(
          children: [
            IconButton(
              style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
              onPressed: () => { showComment(post['id']) }, 
              icon: Icon(Icons.comment),
            ),

            Visibility(
              visible: post['id_user'] == global.idUser,
              child: IconButton(
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                onPressed: () => { deletePost(post['id']) }, 
                icon: Icon(Icons.delete),
              ),
            ),
          ],
        ),

        SizedBox(height: 15,),
        Divider(color: Color.fromARGB(255, 221, 221, 221), indent: 10, endIndent: 10,),
        SizedBox(height: 15,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: kIsWeb ? global.widthWeb : double.infinity,
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Home'),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          alignment: Alignment.centerRight,
                          style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 255, 255, 255)), backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple)),
                          onPressed: () => { Navigator.of(context).push(MaterialPageRoute(builder: (context) => Photo())) }, 
                          icon: Icon(Icons.upload),
                        ),
                      ],
                    )
                  )
          
                ],
              )
            ),
          
            floatingActionButton: FloatingActionButton(
              onPressed: () => { Navigator.of(context).push(MaterialPageRoute(builder: (context) => Post())).then((value) => getPosts()) },
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(Icons.add, color: Colors.white,)
            ),
          
            body: RefreshIndicator(
              onRefresh: getPosts,
              child: ListView.builder(
                itemCount: listPosts.length,
                itemBuilder: (BuildContext context, int index){
                  return showPost(listPosts[index]);
                }
              ),
            )
          ),
      ),
    );
  }
}

