import 'dart:io';

import 'package:flutter/material.dart';
import '../../widgets/pickers/user_image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SignUpMode { Candidiate, Employer }

class AuthForm extends StatefulWidget {
  final Function submitAuthForm;
  final isLoading;

  AuthForm(this.submitAuthForm, this.isLoading);
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String userEmail = "";
  String username = "";
  String password = "";
  var userImage;
  var isLogin = true;
  String dropdownValue;
  DateTime _selectedDate;

  void _pickedImage(File image) {
    userImage = image;
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _selectedDate = pickedDate;
      });
      print(_selectedDate);
    });
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (userImage == null && !isLogin) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: new Text(
            "Please pick an image",
            style: TextStyle(color: Theme.of(context).primaryColor),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    if (_selectedDate == null && !isLogin) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: new Text(
            "Please select your BirthDate",
            style: TextStyle(color: Theme.of(context).primaryColor),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      // print(userEmail);
      // print(username);
      // print(password);
      final signUpAs = 0;

      widget.submitAuthForm(
        userEmail.trim(),
        password,
        (username != null) ? username.trim() : username,
        userImage,
        signUpAs,
        _selectedDate,
        isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Center(
        child: AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeIn,
      height: isLogin ? 480 : deviceSize.height * 0.95,
      constraints:
          BoxConstraints(minHeight: isLogin ? 480 : deviceSize.height * 0.95),
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLogin)
                    SvgPicture.asset("assets/images/login.svg",
                        width: 150, height: 150),
                  if (!isLogin)
                    SvgPicture.asset("assets/images/signup.svg",
                        width: 100, height: 100),
                  if (!isLogin)
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: UserImagePicker(
                        imagePickedFn: _pickedImage,
                      ),
                    ),
                  TextFormField(
                    key: ValueKey("email"),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: Theme.of(context).textTheme.body1,
                    ),
                    validator: (value) {
                      if (value.isEmpty || !value.contains("@")) {
                        return "Please provide a valid email address";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      userEmail = value;
                    },
                  ),
                  if (!isLogin)
                    TextFormField(
                      key: ValueKey("username"),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: Theme.of(context).textTheme.body1,
                      ),
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return "Please provide a valid username";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        username = value;
                      },
                    ),
                  TextFormField(
                    key: ValueKey("password"),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: Theme.of(context).textTheme.body1,
                    ),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return "Password must be seven characters long";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value;
                    },
                  ),
                  if (!isLogin)
                    Container(
                      height: 70,
                      child: new Row(
                        children: [
                          // Get as much space as you can
                          Expanded(
                            child: new Text(
                              _selectedDate == null
                                  ? "No Date Chosen!"
                                  : "Picked Date: " +
                                      DateFormat.yMd().format(_selectedDate),
                            ),
                          ),
                          FlatButton(
                            textColor: Theme.of(context).primaryColor,
                            child: new Text(
                              "Choose Birth Date",
                              style: Theme.of(context).textTheme.body2,
                            ),
                            onPressed: _presentDatePicker,
                          )
                        ],
                      ),
                    ),
                  SizedBox(height: 12),
                  if (!widget.isLoading)
                    RaisedButton.icon(
                      icon: Icon(
                        Icons.create,
                        size: 17,
                      ),
                      color: Theme.of(context).primaryColor,
                      label: Text(
                        isLogin ? "Login" : "SignUp",
                        style: TextStyle(
                          fontFamily: 'Raleway',
                        ),
                      ),
                      onPressed: () {
                        _trySubmit();
                      },
                    ),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    FlatButton(
                      child: Text(
                        isLogin
                            ? "Create New Account"
                            : "I already have an account",
                        style: Theme.of(context).textTheme.body2,
                      ),
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      textColor: Theme.of(context).primaryColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
