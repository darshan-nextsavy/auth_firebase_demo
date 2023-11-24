import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BottomSheetModal {
  static showBottomSheet(
      BuildContext context, Function(ImageSource) pickImage) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                height: 150,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: [
                        IconButton(
                            iconSize: 65,
                            onPressed: () {
                              pickImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.image,
                              color: Colors.lightGreen,
                            )),
                        const Text(
                          'Gallery',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                            iconSize: 65,
                            onPressed: () {
                              pickImage(ImageSource.camera);
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.lightGreen,
                            )),
                        const Text(
                          'Camera',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16),
                        )
                      ],
                    ),
                  ],
                )));
      },
    );
  }
}
