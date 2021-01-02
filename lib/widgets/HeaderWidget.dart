import 'package:cuchitoapp/screens/GoogleMapScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false,
    String srtTittle,
    disappearedBackButton = false,
    String strTitle}) {
  return AppBar(
    actions: [
      FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleMapScreen(),
          ),
        ),
        child: Icon(Icons.pin_drop_outlined),
      )
    ],
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: disappearedBackButton ? true : false,
    title: Text(
      isAppTitle ? "Cuchito" : srtTittle,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Billabong" : "",
        fontSize: isAppTitle ? 58.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
