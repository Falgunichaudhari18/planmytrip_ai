import 'package:flutter/material.dart';
import 'travel_screen.dart';
import 'dart:async';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  final PageController _controller = PageController();
  int currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late Timer _timer;

  List<Map<String, String>> onboardingData = [
    {
      "image": "https://cdn-icons-png.flaticon.com/512/201/201623.png",
      "title": "Discover, Plan,\nand Explore with AI",
      "subtitle": "Your Intelligent Companion for Seamless Travel Experiences"
    },
    {
      "image": "https://cdn-icons-png.flaticon.com/512/854/854878.png",
      "title": "Smart Itinerary",
      "subtitle": "AI generates day-wise plans for your trip"
    },
    {
      "image": "https://cdn-icons-png.flaticon.com/512/684/684908.png",
      "title": "Travel Made Easy",
      "subtitle": "Enjoy hassle-free travel planning with AI"
    },
  ];

  @override
  void initState() {
    super.initState();

    /// FLOAT ANIMATION
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    /// AUTO SWIPE
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      int nextPage = currentPage + 1;

      if (nextPage >= onboardingData.length) {
        nextPage = 0;
      }

      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {
        currentPage = nextPage;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFAED6CF),
              Color(0xFF74B49B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Stack(
            children: [

              /// MAIN CONTENT
              Column(
                children: [

                  /// PAGE VIEW
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {

                        final data = onboardingData[index];

                        return Padding(
                          padding: const EdgeInsets.all(20),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              const SizedBox(height: 20),

                              /// ANIMATED IMAGE
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _animation.value),
                                    child: child,
                                  );
                                },
                                child: Image.network(
                                  data["image"]!,
                                  height: 180,
                                ),
                              ),

                              /// TEXT
                              Column(
                                children: [
                                  Text(
                                    data["title"]!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    data["subtitle"]!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  /// DOTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? Colors.black
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {

                          if (currentPage ==
                              onboardingData.length - 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ),
                            );
                          } else {
                            _controller.nextPage(
                              duration:
                              const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }

                        },
                        child: Text(
                          currentPage ==
                              onboardingData.length - 1
                              ? "Start"
                              : "Next",
                          style:
                          const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              /// SKIP BUTTON
              Positioned(
                top: 10,
                right: 20,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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