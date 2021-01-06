import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuchitoapp/models/user.dart';
import 'package:cuchitoapp/registro/login.dart';
import 'package:cuchitoapp/screens/EditProfilePage.dart';
import 'package:cuchitoapp/widgets/HeaderWidget.dart';
import 'package:cuchitoapp/widgets/PostTileWidget.dart';
import 'package:cuchitoapp/widgets/PostWidget.dart';
import 'package:cuchitoapp/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = "grid";
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  bool following = false;

  void initState() {
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await followingRefrence
        .document(widget.userProfileId)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      countTotalFollowings = querySnapshot.documents.length;
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersRefrence
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersRefrence
        .document(widget.userProfileId)
        .collection("userFollowers")
        .getDocuments();
    setState(() {
      countTotalFollowers = querySnapshot.documents.length;
    });
  }

  createProfileAvatar() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(datasnapshot.data);
        return Padding(
          padding: EdgeInsets.only(
            left: 130,
            right: 0,
            top: 10,
            bottom: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 46.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  createButtonEditar() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return circularProgress();
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [createButton()],
              ),
            ],
          ),
        );
      },
    );
  }

  createBio() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(datasnapshot.data);
        return Padding(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
            top: 0,
            bottom: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 0, right: 0),
                child: Text(
                  user.profileName,
                  style: TextStyle(fontSize: 17.0, color: Colors.white),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 2, right: 0),
                child: Text(
                  user.bio,
                  style: TextStyle(fontSize: 13.0, color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  createProfileTopView() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return circularProgress();
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 38,
            right: 16,
            top: 0,
            bottom: 0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            createColums("POSTS", countPost),
                            createColums("SEGUIDORES", countTotalFollowers),
                            createColums("SIGUIENDO", countTotalFollowings),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Column createColums(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.white,
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 5,
            bottom: 10,
          ),
          margin: EdgeInsets.only(top: 0.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 10.0,
                color: Colors.white,
                fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createBottonTitleAndFunction(
        title: "Editar perfil",
        performFunction: editUserProfile,
      );
    } else if (following) {
      return createBottonTitleAndFunction(
        title: "Dejar de seguir",
        performFunction: controlUnfollowUser,
      );
    } else if (!following) {
      return createBottonTitleAndFunction(
        title: "Seguir",
        performFunction: controlFollowUser,
      );
    }
  }

  controlUnfollowUser() {
    setState(() {
      following = false;
    });
    followersRefrence
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    followingRefrence
        .document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    activityFeedReference
        .document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  controlFollowUser() {
    setState(() {
      following = true;
    });

    followersRefrence
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .setData({});

    followingRefrence
        .document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .setData({});
    activityFeedReference
        .document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.userProfileId,
      "username": currentUser.username,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUser.url,
      "userId": currentOnlineUserId,
    });
  }

  createBottonTitleAndFunction({String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 200,
          height: 25.0,
          child: Text(
            title,
            style: TextStyle(
                color: following ? Colors.white : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: following ? Colors.transparent : Colors.green,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: header(
        context,
        srtTittle: "Perfil",
      ),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: size.height * 0.50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/background1.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    createProfileAvatar(),
                    Divider(),
                    createBio(),
                    Divider(),
                    createProfileTopView(),
                    Divider(),
                    createButtonEditar(),
                    Divider(),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  children: [
                    createListAndGridPostOrientation(),
                    Divider(),
                    displayProfilePost(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20, top: 10),
              child: Icon(
                Icons.photo_library,
                color: Colors.black,
                size: 100.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 1.0, bottom: 50),
              child: Text(
                "No existen publicaciones",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTilesList = [];
      postsList.forEach((eachPost) {
        gridTilesList.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 0.5,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postsList,
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postsReference
        .document(widget.userProfileId)
        .collection("usersPosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents
          .map((documentSnapshot) => Post.fromDocument(documentSnapshot))
          .toList();
    });
  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.web),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.black,
        ),
        IconButton(
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.image),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.black,
        ),
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
