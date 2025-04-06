import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rice_fertile_ai/Utils/app_fonts.dart';
import 'package:rice_fertile_ai/Utils/app_icons.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  int _currentIndex = 0;
  List<LandingStyle> landingStyles = [
    landingStyle1,
    landingStyle2,
    landingStyle3,
    // Add more image paths as needed
  ];

  @override
  void initState() {
    super.initState();
  }

  saveHoverInfoToSp() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('hovered', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Image Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayAnimationDuration: const Duration(seconds: 1),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: landingStyles.map((style) {
              return Container(
                child: Image.asset(
                  style.backgroundImage,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                ),
              );
            }).toList(),
          ),
          // Content
          SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  landingStyles[_currentIndex].titleHeader != null
                      ? Text(
                          landingStyles[_currentIndex].titleHeader!,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: AppFonts.MANROPE),
                        )
                      : Container(),
                  Text(
                    landingStyles[_currentIndex].title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: AppFonts.MANROPE),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildDots(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      child: Text(
                        landingStyles[_currentIndex].description,
                        maxLines: 3,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: AppFonts.MANROPE),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 60, // Set height
                    decoration: BoxDecoration(
                      color: landingStyles[_currentIndex]
                          .buttonColor, // Background color
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                          20), // Match container's borderRadius
                      onTap: () {
                        saveHoverInfoToSp();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Center(
                        child: Text(
                          'Proceed',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: AppFonts.MANROPE),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDots() {
    return List.generate(
      landingStyles.length,
      (index) => Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentIndex == index
              ? landingStyles[_currentIndex].buttonColor
              : Colors.grey,
        ),
      ),
    );
  }
}

class LandingStyle {
  String? titleHeader;
  String title;
  String description;
  String backgroundImage;
  Color buttonColor;

  LandingStyle({
    this.titleHeader,
    required this.title,
    required this.description,
    required this.buttonColor,
    required this.backgroundImage,
  });
}

final landingStyle1 = LandingStyle(
  titleHeader: "Welcome to",
  title: 'LCC AI',
  description:
      'Empowering farmers with cutting-edge technology. Snap a picture of your paddy leaf and let our AI determine the precise amount of fertilizer your field needs to thrive.',
  buttonColor: const Color(0xFFCAA204),
  backgroundImage: AppIcons.bg1,
);

final landingStyle2 = LandingStyle(
  titleHeader: "Did You Know?",
  title: 'Get Precise Fertilizer Recommendations',
  description:
      'Unleash the power of AI to optimize your farming. Simply capture an image of your paddy leaf, and our intelligent system will calculate the exact fertilizer requirements, ensuring the best yield from your fields.',
  buttonColor: const Color(0xFF91AC00),
  backgroundImage: AppIcons.bg2,
);

final landingStyle3 = LandingStyle(
  titleHeader: "Stay Informed and Efficient",
  title: 'Timely Reminders for Leaf Inspections',
  description:
      'Ensure top productivity with timely reminders. Our app will notify you when it\'s time to check your soil and leaves again, helping you maintain the optimal health of your crops.',
  buttonColor: const Color(0xFFE58E14),
  backgroundImage: AppIcons.bg3,
);
