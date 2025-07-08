import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

import '../src.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Box<String> box = Hive.box('user');

  TextEditingController name = TextEditingController();

  year() {
    DateTime dateTime = new DateTime.now();
    final String year = DateFormat.y().format(dateTime);
    return year;
  }

  String profileName = '';
  final ImagePicker _picker = ImagePicker();

  File? image;
  pickImage() async {
    final pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 400,
      maxWidth: 500,
    );
    if (pickedImage == null) {
      return;
    } else {
      // await ImageCropper.cropImage(
      //     sourcePath: pickedImage.path,
      //     aspectRatioPresets: [
      //       CropAspectRatioPreset.square,
      //       CropAspectRatioPreset.ratio3x2,
      //       CropAspectRatioPreset.original,
      //       CropAspectRatioPreset.ratio4x3,
      //       CropAspectRatioPreset.ratio16x9
      //     ],
      //     androidUiSettings: AndroidUiSettings(
      //         toolbarTitle: 'Cropper',
      //         toolbarColor: Colors.blue,
      //         toolbarWidgetColor: Colors.white,
      //         initAspectRatio: CropAspectRatioPreset.original,
      //         lockAspectRatio: false),
      //     iosUiSettings: IOSUiSettings(
      //       minimumAspectRatio: 1.0,
      //     )).then((value) {
      //   setState(() {
      //     image = value as File?;
      //     profileName = value.toString().split('/').last;
      //   });
      // }
      // );  // Balu
    }
  }

  @override
  void initState() {
    setState(() {
      name.text = box.get('name').toString();
      profileName = box.get('profile').toString().split('/').last;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              box.delete('id');
              box.delete('name');
              box.delete('profile');
              box.delete('contact');
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => DashBoardScreen(),
                  ),
                  (route) => false);
            },
            icon: Icon(
              FontAwesomeIcons.signOutAlt,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 20.h,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        image: image != null
                            ? DecorationImage(
                                image: FileImage(File(image!.path)),
                              )
                            : DecorationImage(
                                image: NetworkImage(
                                  box.get('profile').toString(),
                                ),
                              ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ElevatedButton.icon(
                            onPressed: () => pickImage(),
                            icon: Icon(
                              FontAwesomeIcons.pen,
                              size: 12,
                            ),
                            label: Text(
                              'Edit',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    image != null
                        ? Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              color: Colors.red,
                              onPressed: () {
                                setState(() {
                                  image = null;
                                  profileName = box
                                      .get('profile')
                                      .toString()
                                      .split('/')
                                      .last;
                                });
                              },
                              icon: Icon(
                                Icons.close,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  box.get('contact').toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 30,
                ),
                child: TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    hintText: 'Enter UserName',
                    labelText: 'UserName',
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (image == null) {
                    DatabaseService()
                        .updateProfileOnlyName(name.text)
                        .then((value) {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => DashBoardScreen(),
                              ),
                              (route) => false);
                    });
                  } else {
                    DatabaseService()
                        .updateProfile(name.text, profileName, image!)
                        .then((value) {
                      if (value == 'success') {
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => DashBoardScreen(),
                                ),
                                (route) => false);
                      }
                    });
                  }
                },
                child: Text(
                  'Update',
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              letterSpacing: 1,
                            ),
                            text: "Copyright \u00a9 " + year.call() + " ",
                          ),
                          TextSpan(
                            style: TextStyle(
                              color: Colors.blue,
                              letterSpacing: 1,
                            ),
                            text: "Suvidha Softwares.",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = 'https://suvidhasoft.com/';
                                if (await canLaunch(url)) {
                                  await launch(
                                    url,
                                    forceSafariVC: false,
                                  );
                                }
                              },
                          ),
                          TextSpan(
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.4),
                              letterSpacing: 1,
                            ),
                            text: "All rights reserved",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
