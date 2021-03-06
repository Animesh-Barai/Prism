import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Prism/screens/display2.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class Downloads extends StatefulWidget {
  int width;
  int height;
  Downloads(this.width, this.height);
  @override
  DownloadsState createState() => DownloadsState();
}

class DownloadsState extends State<Downloads> {
  bool dataFetched = false;
  Map<dynamic, dynamic> allImageInfo = new HashMap();
  List files = new List();

  Future<String> get localfile async {
    String path = 'storage/emulated/0/';
    print('$path/Prism');
    return '$path/Prism';
  }

  Future<void> readData() async {
    final file = await localfile;
    files = Directory(file).listSync();

    if (files.length == 0) {
      setState(() {
        dataFetched = false;
      });
    } else {
      setState(() {
        dataFetched = true;
      });
    }
    print('Images : $files');
  }

  @override
  void initState() {
    super.initState();
    dataFetched = false;
    files = [];
    readData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Null> refreshList() async {
    refreshKey2.currentState?.show(atTop: true);
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      files = [];
      dataFetched = false;
    });
    readData();

    return null;
  }

  ScrollController controller;
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 720, height: 1440, allowFontScaling: true);

    return dataFetched
        ? RefreshIndicator(
            key: refreshKey2,
            onRefresh: refreshList,
            child: new Container(
              color: DynamicTheme.of(context).data.primaryColor,
              child: Scrollbar(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  itemCount: files.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.75),
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned.fill(
                            child: new Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(24),
                                ),
                              ),
                              elevation: 0.0,
                              semanticContainer: true,
                              margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: new Container(
                                child: new Hero(
                                  tag: files[index].path.toString(),
                                  child: Image(
                                    image: FileImage(
                                      files[index],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Display2(files[index]);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          )
        : Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: DynamicTheme.of(context).data.primaryColor ==
                            Color(0xFFFFFFFF)
                        ? AssetImage("assets/images/loadingsw.png")
                        : DynamicTheme.of(context).data.primaryColor ==
                                Color(0xFF272727)
                            ? AssetImage("assets/images/loadingdb.png")
                            : DynamicTheme.of(context).data.primaryColor ==
                                    Color(0xFF000000)
                                ? AssetImage("assets/images/loadingab.png")
                                : DynamicTheme.of(context).data.primaryColor ==
                                        Color(0xFF263238)
                                    ? AssetImage("assets/images/loadingcd.png")
                                    : AssetImage("assets/images/loadingmc.png"),
                    height: 600.h,
                    width: 600.w,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Oops!",
                      style: GoogleFonts.raleway(
                          fontSize: 30,
                          color: DynamicTheme.of(context)
                              .data
                              .secondaryHeaderColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    "Download some awesome\n wallpapers to add them here.",
                    style: GoogleFonts.raleway(
                        fontSize: 16,
                        color:
                            DynamicTheme.of(context).data.secondaryHeaderColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
  }
}
