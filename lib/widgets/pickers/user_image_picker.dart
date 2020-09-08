import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final Function imagePickedFn;

  const UserImagePicker({this.imagePickedFn});

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  void _pickImage() {
    ImagePicker.pickImage(
      source: ImageSource.gallery,
    ).then((pickedImage) {
      setState(() {
        _pickedImage = pickedImage;
      });
      widget.imagePickedFn(_pickedImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage) : null,
        ),
        FlatButton.icon(
          icon: Icon(Icons.image),
          onPressed: () {
            _pickImage();
          },
          label: new Text("Add Image"),
          textColor: Theme.of(context).primaryColor,
        )
      ],
    );
  }
}
