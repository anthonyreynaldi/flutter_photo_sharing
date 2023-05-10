// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'global.dart' as global;

// Navigator.push(contex, MaterialPageRoute(Builder: (context) => Profile(cobaParam: "test",)))

class Comment extends StatefulWidget {
  String idPost;
  
  Comment({required this.idPost}) : super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.idPost);
}

class _MyHomePageState extends State<Comment> {
  String idPost;
  var listComments = [];
  TextEditingController commentC = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  _MyHomePageState(this.idPost){
    getComments(idPost);
  }

  getComments(idPost) async {
    var response = await global.sendGet("/posts/" + idPost + "/comments");

    response = jsonDecode(response.body);

    setState(() {
      listComments = response['data'];
    });
  }

  postComment() async {
    Map paramData = {
      'id_user': global.idUser,
      'id_post': idPost,
      'comment': commentC.text,
    };

    var parameter = json.encode(paramData);

    var response = await global.sendPost("/comments", parameter);

    var result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("berhasil");
      print(result['message']);

      setState(() {
        commentC.text = "";
        getComments(idPost);
      });

    }else{
      print("gagal");
      print(result['message']);
    }
  }

  deleteComment(idComment) async {
    Map paramData = {
      '_method': "DELETE",
    };

    var parameter = json.encode(paramData);

    var response = await global.sendPost("/comments/$idComment", parameter);

    var result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("berhasil");
      print(result['message']);

      getComments(idPost);

    }else{
      print("gagal");
      print(result['message']);
    }
  }
  
  Future<dynamic> getComment(idComment) async {
    var response = await global.sendGet("/comments/" + idComment);

    if(response.statusCode == 200){
      response = jsonDecode(response.body);
      print(response);
      return response['data'];
    }

  }

  Future<String> getUsername(id_user) async {
    var response = await global.sendGet("/users/" + id_user);  

    if(response.statusCode == 200){
      response = jsonDecode(response.body);
      print(response);
      return response['data']['name'];
    }

    return "Unknown User";
  }

  showComment(id_comment){
    return FutureBuilder(
      future: getComment(id_comment),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        print("snapshot");
        print(snapshot.data);
        if(snapshot.hasData && snapshot.data != null){
          return
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: getUsername(snapshot.data['id_user']),
                      builder: (context2, AsyncSnapshot<String> snapshot2) {
                        if(snapshot2.hasData){
                          return
                          Text(
                            snapshot2.data ?? "Unknown User",
                            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold), 
                            textAlign: TextAlign.start,
                          );
                        }

                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                    Text(snapshot.data['comment'] ?? "Unable to load comment", textAlign: TextAlign.start,),
                  ],
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: snapshot.data['id_user'] == global.idUser,
                        child: IconButton(
                          alignment: Alignment.centerRight,
                          style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                          onPressed: () => { deleteComment(snapshot.data['id']) }, 
                          icon: Icon(Icons.delete),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: Container(
        width: kIsWeb ? global.widthWeb : double.infinity,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Comments'),
            ),
            body: 
            Column(
              children: [
                Expanded(
                  child: 
                  ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(color: Color.fromARGB(255, 221, 221, 221), indent: 10, endIndent: 10,);
                    },
                    itemCount: listComments.length,
                    itemBuilder: (context, index) {
                      return showComment(listComments[index]);
                    },
                  ),
                ),
          
                ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: global.inputText("Input Comment", commentC),
                  ),
                  trailing: global.button("Post", () => { postComment() })
                )
              ],
            )
          ),
      ),
    );
  }
}
