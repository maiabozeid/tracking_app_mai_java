import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/auth/sign_in_screen.dart';
import 'package:tracking_app/screen/main_screen/main_screen.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/dimensions.dart';
import 'package:tracking_app/util/images.dart';
import 'package:tracking_app/util/styles.dart';

import '../main_screen_booking.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log("Higgs-Boson detected! Bailing out");

    // Get the user identifier from CacheHelper
    String? userIdentifier = CacheHelper.getData(key: AppConstants.
    trackVehicleNumber);
    if (userIdentifier != null) {
      // Set the user identifier for Crashlytics
      FirebaseCrashlytics.instance.setUserIdentifier(userIdentifier);
    } else {
      // Handle the case when userIdentifier is null
      // For example, you could use a default user identifier or log a message
    }
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    String formattedTime = DateFormat.jm().format(
        DateTime.parse(DateTime.now().toString()));
        String formattedDate = formatter.format(now);


    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Dimensions.height * 0.25,
              child: Stack(
                children: [
                  Container(
                    height: Dimensions.height * 0.2,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Color(0xff008d36),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(70),
                            bottomRight: Radius.circular(70))),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "اهلا : ${CacheHelper.getData(
                                      key: AppConstants.name)}",
                                  style: robotoRegular.copyWith(
                                      color: Colors.white, fontSize: 14)),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,color: Colors.white),
                                  const SizedBox(width: 5,),
                                  Text(formattedTime,style: const TextStyle(color:Colors.white),)
                                ],
                              ), Row(
                                children: [
                                  const Icon(Icons.date_range,color: Colors.white),
                                  const SizedBox(width: 5,),
                                  Text(formattedDate,style: const TextStyle(color:Colors.white))
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.note,color: Colors.white),
                                  const SizedBox(width: 5,),
                                  Text( AppConstants.appVersion,
                                      style: const TextStyle(color:Colors.white))
                                ],
                              ),
                              SizedBox( height: Dimensions.height * 0.02,),

                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    CacheHelper.clearData();
                                    Get.offAll(() => const SignInScreen());
                                  },
                                  icon: Image.asset(Images.logIcon)),


                            ],
                          ),

                        ],
                      ),

                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Image.asset(
                      Images.logo,
                      height: Dimensions.height * 0.13,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: Dimensions.height * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const MainScreenBooking());
                },
                child: Card(
                  shadowColor: Colors.grey,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Image.asset(
                          Images.roadMap,
                          height: Dimensions.height * 0.15,
                          width: Dimensions.width * 0.4,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Container(
                        width: Dimensions.width * 0.42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xff008d36).withOpacity(0.9),
                        ),
                        child: Center(
                          child: Text(
                            "المسارات اليوميه",
                            style: robotoRegular.copyWith(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
