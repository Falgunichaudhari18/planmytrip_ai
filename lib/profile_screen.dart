import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip_result_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String? email;
  List<String> trips = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
    );
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      email = prefs.getString('email');
      trips = prefs.getStringList('trips') ?? [];
    });
  }

  void openTrip(String data) {
    List<String> parts = data.split("|||");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripResultScreen(
          destination: parts[0],
          plan: parts[1],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// 🔥 APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        /// ✨ Animated Title
        title: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(-20 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Row(
            children: const [
              Icon(Icons.person, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        /// 🔴 Logout Button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        ],
      ),

      /// 🔥 BODY (IMPORTANT FIX)
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 👤 USER INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      email ?? "User",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved Trips ❤️",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            /// 📄 LIST
            Expanded(
              child: trips.isEmpty
                  ? const Center(child: Text("No trips saved"))
                  : ListView.builder(
                itemCount: trips.length,
                itemBuilder: (context, index) {

                  List<String> parts = trips[index].split("|||");

                  return Card(
                    child: ListTile(
                      title: Text(parts[0]),
                      subtitle: const Text("Tap to view plan"),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.blueGrey),
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();

                              trips.removeAt(index);
                              await prefs.setStringList('trips', trips);

                              setState(() {});
                            },
                          ),

                          const Icon(Icons.arrow_forward),
                        ],
                      ),

                      onTap: () => openTrip(trips[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}