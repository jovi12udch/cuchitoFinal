import 'dart:async';

import 'package:cuchitoapp/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String username;
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  submitUsername() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackBar =
          SnackBar(content: Text('Bienvenido a cuchito: ' + username));
      _scaffoldkey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldkey,
      appBar:
          header(context, srtTittle: "CUCHITO", disappearedBackButton: false),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 50.0, bottom: 25),
                  child: Center(
                    child: Text(
                      'Configura tu Usuario',
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.face,
                  color: Colors.green,
                  size: 100,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 17.0, bottom: 50, left: 17, right: 17),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(color: Colors.black),
                        validator: (val) {
                          if (val.trim().length < 5 || val.isEmpty) {
                            return "el usuario es muy corto";
                          } else {
                            if (val.trim().length > 15 || val.isEmpty) {
                              return "el usuario es muy largo";
                            } else {
                              return null;
                            }
                          }
                        },
                        onSaved: (val) => username = val,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Nombre de usuario',
                          labelStyle: theme.textTheme.caption
                              .copyWith(color: Colors.black, fontSize: 15.0),
                          hintText: "Debe ser de al menos 5 caracteres",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submitUsername,
                  child: Container(
                    height: 40.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        'Continuar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
