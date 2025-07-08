import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../src.dart';

class MobileAuthScreen extends StatefulWidget {
  @override
  _MobileAuthScreenState createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  TextEditingController mobile = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 2.h,
              ),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationScreen(),
                  ),
                ),
                icon: Icon(
                  Icons.location_on_rounded,
                ),
                label: Text(
                  'Change Location',
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 80.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  lottie + 'logo.json',
                  height: 30.h,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter Mobile Number',
                      suffixIcon: Icon(
                        Icons.phonelink_setup_rounded,
                        size: 14.sp,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '+91 ',
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        maxHeight: 40,
                        maxWidth: 40,
                      ),
                    ),
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    controller: mobile,
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0.sp),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (mobile.text.length != 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Enter Valid Number"),
                          ),
                        );
                      } else {
                        await DatabaseService.getOtp(mobile.text).then((value) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpAuth(
                                  id: value.first.id,
                                  otp: value.first.otp,
                                  contact: value.first.mobile,
                                ),
                              ),
                              (route) => false);
                        });
                      }
                    },
                    child: Text(
                      'Get Otp',
                      style: TextStyle(
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpAuth extends StatefulWidget {
  final int? id;
  final int? otp;
  final String? contact;
  const OtpAuth({
    Key? key,
    this.id,
    this.otp,
    this.contact,
  }) : super(key: key);

  @override
  _OtpAuthState createState() => _OtpAuthState();
}

class _OtpAuthState extends State<OtpAuth> {
  TextEditingController otpController = TextEditingController();

  CountDownController _controller = CountDownController();
  int? countdown = 60;

  bool expired = false;

  int? id;
  int? otp;
  String? contact;

  @override
  void initState() {
    setState(() {
      id = widget.id!;
      otp = widget.otp!;
      contact = widget.contact!;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 80.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                lottie + 'logo.json',
                height: 30.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Received OTP',
                    suffixIcon: Icon(
                      Icons.mobile_friendly_rounded,
                      size: 14.sp,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  controller: otpController,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (otp.toString() == otpController.text) {
                      firebaseToken().then((token) {
                        return DatabaseService()
                            .verifyUser(
                          id!.toString(),
                          contact!,
                          otp!.toString(),
                          token,
                        )
                            .then((value) {
                          if (value == "success") {
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => DashBoardScreen(),
                                    ),
                                    (route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Unable to Login, Please Check Your OTP again.....",
                                ),
                              ),
                            );
                          }
                        });
                      });
                    }
                  },
                  child: Container(
                    child: Text(
                      'Submit',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularCountDownTimer(
                  duration: countdown!,
                  initialDuration: 0,
                  controller: _controller,
                  width: 50,
                  height: 50,
                  ringColor: Colors.blue,
                  ringGradient: null,
                  fillColor: Colors.blue[100]!,
                  fillGradient: null,
                  backgroundColor: Colors.blue[500],
                  backgroundGradient: null,
                  strokeWidth: 8.0,
                  strokeCap: StrokeCap.round,
                  textStyle: TextStyle(
                    fontSize: 28.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textFormat: CountdownTextFormat.S,
                  isReverse: true,
                  isReverseAnimation: false,
                  isTimerTextShown: true,
                  autoStart: true,
                  onStart: () {},
                  onComplete: () {
                    DatabaseService.expireOTP(
                      id.toString(),
                      contact!,
                      otp.toString(),
                    ).then((value) {
                      setState(() {
                        expired = true;
                      });
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  expired
                      ? 'Your OTP Expired'
                      : 'Your OTP Expires in 60 seconds',
                  style: TextStyle(
                    color: expired ? Colors.red : Colors.black,
                  ),
                ),
              ),
              expired
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text('+91 ' + widget.contact!),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                DatabaseService.getOtp(contact!).then((value) {
                                  setState(() {
                                    id = value.first.id;
                                    otp = value.first.otp;
                                    contact = value.first.mobile;
                                    expired = false;
                                    countdown = 60;
                                  });
                                });
                                _controller.start();
                              },
                              child: Text('Resend')),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
