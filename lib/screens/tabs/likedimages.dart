import 'package:flutter/material.dart';
import 'package:cache_image/cache_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Prism/screens/display.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikedImages extends StatefulWidget {
  int width;
  int height;
  LikedImages(this.width, this.height);
  @override
  _LikedImagesState createState() => _LikedImagesState();
}

class _LikedImagesState extends State<LikedImages> {
  final databaseReference2 = Firestore.instance;
  Future<QuerySnapshot> dbr2;
  List liked = [];
  List<FlareControls> flareControls;
  List<FlareControls> flareControls2;
  SharedPreferences prefs;
  String userId = '';
  @override
  void initState() {
    super.initState();
    readLocal().then((value) {
      dbr2 = databaseReference2
          .collection("users")
          .document(value)
          .collection("images")
          .getDocuments();
    });
    setState(() {});
  }

  Future<String> readLocal() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
    setState(() {});
    return userId;
  }

  Future<Null> refreshList() async {
    refreshKey3.currentState?.show(atTop: true);
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      liked = [];
    });
    setState(() {
      dbr2 = databaseReference2
          .collection("users")
          .document(userId)
          .collection("images")
          .getDocuments();
    });

    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  ScrollController controller;
  var refreshKey3 = GlobalKey<RefreshIndicatorState>();

  List data = [];
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 720, height: 1440, allowFontScaling: true);
    return RefreshIndicator(
      key: refreshKey3,
      onRefresh: refreshList,
      child: FutureBuilder(
          future: dbr2,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              data = [];
              liked = [];
              flareControls = [];
              flareControls2 = [];
              snapshot.data.documents.forEach((f) => data.add(f.data));
              if (data.toString() != '[]') {
                data.forEach(
                  (v) => liked.add(v["id"]),
                );
                data.forEach(
                  (k) => flareControls.add(
                    new FlareControls(),
                  ),
                );
                data.forEach(
                  (k) => flareControls2.add(
                    new FlareControls(),
                  ),
                );

                return new Container(
                    height: double.infinity,
                    color: DynamicTheme.of(context).data.primaryColor,
                    child: Scrollbar(
                      child: GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          itemCount: data.length,
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
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
                                              Radius.circular(24))),
                                      elevation: 0.0,
                                      semanticContainer: true,
                                      margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: new Container(
                                          child: new Hero(
                                              tag:
                                                  "https://whvn.cc/${data[index]["url"].substring(16)}",
                                              child: Image(
                                                image: CacheImage(
                                                  data[index]["thumb"],
                                                ),
                                                fit: BoxFit.cover,
                                              ))),
                                    ),
                                  ),
                                  Positioned(
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: FlareActor(
                                        'assets/animations/like.flr',
                                        controller: flareControls[index],
                                        animation: 'idle',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: FlareActor(
                                        'assets/animations/dislike.flr',
                                        controller: flareControls2[index],
                                        animation: 'idle',
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
                                      return Display(
                                          data[index]["url"],
                                          data[index]["thumb"],
                                          data[index]["color"],
                                          data[index]["color2"],
                                          data[index]["views"],
                                          data[index]["resolution"],
                                          "https://whvn.cc/${data[index]["id"]}",
                                          data[index]["created"],
                                          data[index]["fav"],
                                          data[index]["size"]);
                                    },
                                  ),
                                );
                              },
                              onDoubleTap: () {
                                if (liked.contains(data[index]["id"])) {
                                  // print("Dislike");
                                  liked.remove(data[index]["id"]);
                                  final snackBar = SnackBar(
                                    content: Text(
                                        'Wallpaper removed from favorites!'),
                                    duration: Duration(milliseconds: 2000),
                                  );
                                  Scaffold.of(context).showSnackBar(snackBar);
                                  deleteData2(data[index]["id"]);
                                  flareControls2[index].play("dislike");
                                } else {
                                  // print("Like");
                                  liked.add(data[index]["id"]);
                                  final snackBar = SnackBar(
                                    content:
                                        Text('Wallpaper added to favorites!'),
                                    duration: Duration(milliseconds: 2000),
                                  );
                                  Scaffold.of(context).showSnackBar(snackBar);
                                  createRecord2(
                                      data[index]["id"],
                                      data[index]["url"],
                                      data[index]["thumb"],
                                      data[index]["color"],
                                      data[index]["color2"],
                                      data[index]["views"],
                                      data[index]["resolution"],
                                      data[index]["created"],
                                      data[index]["fav"],
                                      data[index]["size"]);
                                  flareControls[index].play("like");
                                }

                                // print(liked.toString());
                              },
                            );
                          }),
                    ));
              } else {
                return Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: DynamicTheme.of(context).data.primaryColor ==
                                  Color(0xFFFFFFFF)
                              ? AssetImage("assets/images/oopssw.png")
                              : DynamicTheme.of(context).data.primaryColor ==
                                      Color(0xFF272727)
                                  ? AssetImage("assets/images/oopsdb.png")
                                  : DynamicTheme.of(context)
                                              .data
                                              .primaryColor ==
                                          Color(0xFF000000)
                                      ? AssetImage("assets/images/oopsab.png")
                                      : DynamicTheme.of(context)
                                                  .data
                                                  .primaryColor ==
                                              Color(0xFF263238)
                                          ? AssetImage(
                                              "assets/images/oopscd.png")
                                          : AssetImage(
                                              "assets/images/oopsmc.png"),
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
                          "Double tap some awesome\nwallpapers to add them here.",
                          style: GoogleFonts.raleway(
                              fontSize: 16,
                              color: DynamicTheme.of(context)
                                  .data
                                  .secondaryHeaderColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return Container(
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
                                  : DynamicTheme.of(context)
                                              .data
                                              .primaryColor ==
                                          Color(0xFF263238)
                                      ? AssetImage(
                                          "assets/images/loadingcd.png")
                                      : AssetImage(
                                          "assets/images/loadingmc.png"),
                      height: 600.h,
                      width: 600.w,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        "Loading",
                        style: GoogleFonts.raleway(
                            fontSize: 30,
                            color: DynamicTheme.of(context)
                                .data
                                .secondaryHeaderColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      "Sit Back and wait a few seconds\nas your favourite wallpapers are\nloading.",
                      style: GoogleFonts.raleway(
                          fontSize: 16,
                          color: DynamicTheme.of(context)
                              .data
                              .secondaryHeaderColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void createRecord2(
      String id,
      String url,
      String thumb,
      String color,
      String color2,
      String views,
      String resolution,
      String created,
      String fav,
      String size) async {
    await databaseReference2
        .collection("users")
        .document(userId)
        .collection("images")
        .document(id)
        .setData({
      "id": id,
      "url": url,
      "thumb": thumb,
      "color": color,
      "color2": color2,
      "views": views,
      "resolution": resolution,
      "created": created,
      "fav": fav,
      "size": size,
    });
  }

  void getData2() {
    databaseReference2
        .collection("users")
        .document(userId)
        .collection("images")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => print('${f.data}}'));
    });
  }

  void deleteData2(String id) {
    try {
      databaseReference2
          .collection("users")
          .document(userId)
          .collection("images")
          .document(id)
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
