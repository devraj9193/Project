import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late File _selectedFile;
  bool _inProcess = false;

  var rootBundle;

  Widget getImageWidget() {
    if (_selectedFile != null) {
      return Image.file(
        _selectedFile,
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/placeholder.jpg",
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    }
  }

  getImage(ImageSource source) async {
      this.setState((){
        _inProcess = true;
      });
      XFile? image = await ImagePicker.pickImage(source: source);
      if(image != null){
        File? cropped = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(
                ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 700,
            maxHeight: 700,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.deepOrange,
              toolbarTitle: "Image Cropper",
              statusBarColor: Colors.deepOrange.shade900,
              backgroundColor: Colors.white,
            )
        );

        this.setState((){
          _selectedFile = cropped!;
          _inProcess = false;
        });
      } else {
        this.setState((){
          _inProcess = false;
        });
      }
  }

  uploadImage(String title) async {
    var croppedImage = File;

    var request = http.MultipartRequest("POST",Uri.parse("APIURL"),);

    request.fields['title'] = "Upload Image";
    request.headers['Authorization'] = "";

    var picture = http.MultipartFile.fromBytes('image', (await rootBundle.load(croppedImage)).buffer.asUint8List());

  request.files.add(picture);

  var response = await request.send();

  var responseData = await response.stream.toBytes();

  var result = String.fromCharCodes(responseData);

  print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getImageWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                      color: Colors.green,
                      child: Text(
                        "Camera",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        getImage(ImageSource.camera);
                      }),
                  MaterialButton(
                      color: Colors.deepOrange,
                      child: Text(
                        "Upload",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        uploadImage('image');
                      })
                ],
              )
            ],
          ),
          (_inProcess)?Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.95,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ):Center()
        ],
      )
    );
  }
}
