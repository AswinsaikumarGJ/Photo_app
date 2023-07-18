import 'dart:convert';
import 'dart:io';
// import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:photo_app/Providers/home_page_provider.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController _searchController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<HomePageProvider>(context, listen: false).getApiData();

    Provider.of<HomePageProvider>(context, listen: false)
        .scrollController
        .addListener(() {
      if (Provider.of<HomePageProvider>(context, listen: false)
          .isScrolledToBottom()) {
        if (Provider.of<HomePageProvider>(context, listen: false).apicheck ==
            false) {
          Provider.of<HomePageProvider>(context, listen: false).getApiData();
        } else {
          Provider.of<HomePageProvider>(context, listen: false)
              .searchApiData(_searchController);
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Provider.of<HomePageProvider>(context, listen: false)
        .scrollController
        .dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var providerVar = Provider.of<HomePageProvider>(context, listen: false);
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        title: Text("Photos App"),
      ),
      body: Container(
        height: h,
        width: w,
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                focusNode: providerVar.weightFocus,
                onFieldSubmitted: (value) {
                  providerVar.weightFocus.unfocus();
                  providerVar.searchApiData(_searchController);
                },
                textInputAction: TextInputAction.done,
                controller: _searchController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(10)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  labelText: 'Search',
                  labelStyle: TextStyle(color: Colors.orange),
                  suffixIcon: IconButton(
                    color: Colors.deepOrange,
                    icon: Icon(Icons.search),
                    onPressed: () {
                      providerVar.searchApiData(_searchController);
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Provider.of<HomePageProvider>(context, listen: true)
                          .items
                          .length ==
                      0
                  ? Center(
                      child: Text(
                      "No Images found",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ))
                  : GridView.builder(
                      controller: providerVar.scrollController,
                      itemCount:
                          Provider.of<HomePageProvider>(context, listen: true)
                              .urlData
                              .length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(providerVar.apicheck ==
                                            true
                                        ? Provider.of<HomePageProvider>(context,
                                                listen: true)
                                            .urlData[i]["urls"]["small_s3"]
                                        : Provider.of<HomePageProvider>(context,
                                                listen: true)
                                            .urlData[i]["urls"]["small_s3"]),
                                    fit: BoxFit.cover)),
                            child: IconButton(
                                icon: Icon(
                                  Icons.download,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  await providerVar.downloadFileFn(providerVar
                                      .urlData[i]["urls"]["small_s3"]);

                                  if (providerVar.snackBar == true) {
                                    var snackBar = SnackBar(
                                      backgroundColor: Colors.deepOrange,
                                      duration: Duration(seconds: 2),
                                      content: Text(
                                          'Image Downloaded Successfully to gallery'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                }),
                          ),
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
