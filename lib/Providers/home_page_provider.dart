import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HomePageProvider extends ChangeNotifier {
  var urlData;
  List items = [];
  int page = 1;
  bool apicheck = false;
  bool snackBar = false;
  ScrollController scrollController = ScrollController();
  final FocusNode heightFocus = FocusNode();
  final FocusNode weightFocus = FocusNode();
  getApiData() async {
    var url = Uri.parse(
        "https://api.unsplash.com/photos?page=$page&client_id=ld4gOXuuc3yuiVI_b8E1lXqNKy3VolKpnJvgEccKm9c");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      urlData = await jsonDecode(res.body);
      final List newItems = List.from(urlData);
      items.addAll(newItems);
      page++;
      notifyListeners();
    }
  }

  void searchApiData(query) async {
    items = [];
    apicheck = true;
    if (query.text != "") {
      var url = Uri.parse(
          "https://api.unsplash.com/search/photos/?page=$page&client_id=ld4gOXuuc3yuiVI_b8E1lXqNKy3VolKpnJvgEccKm9c&query=${query.text}");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        var urlData1 = jsonDecode(res.body);
        urlData = urlData1["results"];
        final List newItems = List.from(urlData);
        items.addAll(newItems);
        page++;
        notifyListeners();
      }
    }
  }

  bool isScrolledToBottom() {
    return scrollController.position.pixels ==
        scrollController.position.maxScrollExtent;
  }

  downloadFileFn(url) async {
    var imageFile = await DefaultCacheManager().getSingleFile(url);
    CroppedFile? croppedFile;
    try {
      croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        maxWidth: 512,
        maxHeight: 512,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          )
        ],
      );
    } catch (e) {
      print("error");
    }

    Directory appDir = await getApplicationDocumentsDirectory();
    String dirPath = appDir.path;
    String filepath = "photos.jpg";
    String desiredPath = path.join(dirPath, filepath);
    File savedImage = File(desiredPath);
    try {
      final bytes = await croppedFile!.readAsBytes();
      await savedImage.writeAsBytes(bytes);
      await savetogallery(savedImage.path);
    } catch (e) {
      print(e);
    }
  }

  Future<void> savetogallery(String path) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dirPath = appDir.path;
    try {
      await GallerySaver.saveImage(path).whenComplete(() {
        snackBar = true;
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }
}
