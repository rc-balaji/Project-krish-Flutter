import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth,
      height: screenHeight * 0.5,
      color: Color.fromARGB(255, 255, 255, 255),
      child: Stack(
        children: [
          Positioned(
            top: -582 + screenHeight * 0.1,
            left: -200   + screenWidth * 0.3,
            child: Transform.rotate(
              angle: -72 * 3.1415926535897932 / 180, // Rotation angle in radians
              child: Container(
                width: 326.13 + screenWidth * 0.2,
                height: 1061.02 + screenWidth * 0.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(212, 22, 26, 1),Color.fromRGBO(255, 255, 255, 0.988) ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -420 + screenHeight * 0.1,
            left: 100+ screenWidth * 0.3,
            child: Transform.rotate(
              angle: -44.83, // Rotation angle in radians
              child: Container(
                width: 326.13 + screenWidth * 0.2,
                height: 861.02 + screenWidth * 0.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(212, 22, 26, 1), Color.fromRGBO(156, 23, 25, 1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -120 + screenHeight * 0.1,
            left: -222   +  screenWidth * 0.3,
            child: Transform.rotate(
              angle: 0, // Rotation angle in radians
              child: Image.asset('assets/images/drone.png', width: 297+ screenWidth * 0.2,  height: 388 + screenWidth * 0.2),
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MY',
                    style: GoogleFonts.staatliches(
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.2,
                        height: 1.0,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'DRONE',
                    style: GoogleFonts.staatliches(
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.2,
                        height: .6,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
          ),
          
        ],
      ),
    );
  }
}
