import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());
late File _image;
bool _defaultImg = true;

class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

Future<String> fileToStorage() async {
  FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;

  var _url;

  if (_defaultImg) {
  } else {
    String fileName = basename(_image.path);

    Reference refBS = firebaseStorageRef.ref().child('diary').child(fileName);

    var uploadTask = await refBS.putFile(_image);

    _url = await uploadTask.ref.getDownloadURL();
  }
  return _url;
}

_getFromGallery() async {
  PickedFile? pickedFile = await ImagePicker().getImage(
    source: ImageSource.gallery,
    maxWidth: 1800,
    maxHeight: 1800,
  );
  if (pickedFile != null) {
    _image = File(pickedFile.path);
    _defaultImg = false;
  }
}

class _DiaryPageState extends State<DiaryPage> {
  CollectionReference products = FirebaseFirestore.instance.collection('diary');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 150, 0, 0),
          child: Center(
            child: Text(
              todayDate + "\n Diary Page",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
        Container(
          width: 400,
          height: 300,
          child: _defaultImg
              ? Image.network(
                  'http://handong.edu/site/handong/res/img/logo.png')
              : Image.file(File(_image.path)),
        ),
        Container(
          alignment: Alignment.topRight,
          child: IconButton(
              onPressed: () {
                _getFromGallery();
              },
              icon: Icon(Icons.camera)),
        ),
      ],
    );
  }
}
