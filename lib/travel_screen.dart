import 'package:flutter/material.dart';
import 'trip_result_screen.dart';
import 'ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import 'dart:ui';
import 'profile_screen.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {

  final TextEditingController destinationController = TextEditingController();

  String? budget;
  String? travelType;
  String? transport;
  String? duration;
  DateTime? travelDate;

  List<String> interests = [];

  final Color primaryGreen = const Color(0xFF7ED321);

  final interestOptions = [
    "Adventure","Nature","Food","Historical","Relaxing","Shopping"
  ];

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => travelDate = picked);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void showLoadingPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Center(
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      "https://cdn-icons-png.flaticon.com/512/2921/2921822.png",
                      height: 95,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "PlanMyTrip_AI is designing your dream trip 🤖✨",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please wait while we create your perfect itinerary 🌍",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        valueColor: AlwaysStoppedAnimation(primaryGreen),
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🔥 MODERN SECTION TITLE WITH ICON
  Widget sectionTitle(String text, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: primaryGreen),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridOption({
    required String title,
    required IconData icon,
    required String? selected,
    required Function(String) onTap,
  }) {
    bool isSelected = selected == title;

    return GestureDetector(
      onTap: () => onTap(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? primaryGreen : Colors.grey),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? primaryGreen : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGrid(List<Map<String, dynamic>> items, String? selected, Function(String) onTap) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 65,
      ),
      itemBuilder: (context, index) {
        return buildGridOption(
          title: items[index]['title'],
          icon: items[index]['icon'],
          selected: selected,
          onTap: onTap,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// 🔥 MODERN APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        /// 🔥 ANIMATED LEFT TITLE
        title: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(-20 * (1 - value), 0), // slide from left
                child: child,
              ),
            );
          },

          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.public,
                  color: Colors.green,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "PlanMyTrip",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Smart Travel Planner",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),



      actions: [
      Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            ),
          );
        },
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.black),
        ),
      ),
    )
    ],
      ),
      /// 🌈 BACKGROUND
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade100,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              children: [

                sectionTitle("Where to Go?", Icons.location_on),
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    hintText: "Enter Destination 🌍",
                    prefixIcon: const Icon(Icons.location_on),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                sectionTitle("Date", Icons.calendar_today),
                GestureDetector(
                  onTap: pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          travelDate == null
                              ? "Select Travel Date"
                              : "${travelDate!.day}/${travelDate!.month}/${travelDate!.year}",
                        ),
                      ],
                    ),
                  ),
                ),

                sectionTitle("Who are you traveling with?", Icons.people),
                buildGrid([
                  {"title": "Solo", "icon": Icons.person},
                  {"title": "Friends", "icon": Icons.group},
                  {"title": "Family", "icon": Icons.family_restroom},
                  {"title": "Couple", "icon": Icons.favorite},
                ], travelType, (v)=>setState(()=>travelType=v)),

                sectionTitle("Transport", Icons.directions),
                buildGrid([
                  {"title": "Flight", "icon": Icons.flight},
                  {"title": "Train", "icon": Icons.train},
                  {"title": "Bus", "icon": Icons.directions_bus},
                  {"title": "Car", "icon": Icons.directions_car},
                ], transport, (v)=>setState(()=>transport=v)),

                sectionTitle("Trip Duration", Icons.access_time),
                buildGrid([
                  {"title": "1 Day", "icon": Icons.today},
                  {"title": "2 Days", "icon": Icons.calendar_view_day},
                  {"title": "3-4 Days", "icon": Icons.date_range},
                  {"title": "5+ Days", "icon": Icons.event},
                ], duration, (v)=>setState(()=>duration=v)),

                sectionTitle("Budget", Icons.account_balance_wallet),
                buildGrid([
                  {"title": "Low 5k", "icon": Icons.money_off},
                  {"title": "Medium 5k-30k", "icon": Icons.account_balance_wallet},
                  {"title": "Luxury 30k+", "icon": Icons.attach_money},
                ], budget, (v)=>setState(()=>budget=v)),

                sectionTitle("Select Interests", Icons.favorite),
                Wrap(
                  spacing: 8,
                  children: interestOptions.map((interest) {
                    bool isSelected = interests.contains(interest);
                    return ChoiceChip(
                      label: Text(interest),
                      selected: isSelected,
                      selectedColor: primaryGreen,
                      onSelected: (val) {
                        setState(() {
                          val ? interests.add(interest) : interests.remove(interest);
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {

                    showLoadingPopup();

                    String destination = destinationController.text;

                    String plan = await AIService.generateTripPlan(
                      destination,
                      duration ?? "",
                      interests,
                      budget ?? "",
                    );

                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripResultScreen(
                          plan: plan,
                          destination: destination,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Generate Trip Plan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),

    );

  }
}