import 'package:flutter/material.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TripResultScreen extends StatefulWidget {
  final String plan;
  final String destination;

  const TripResultScreen({
    super.key,
    required this.plan,
    required this.destination,
  });

  @override
  State<TripResultScreen> createState() => _TripResultScreenState();
}

class _TripResultScreenState extends State<TripResultScreen> {

  bool isDarkMode = false;
  String weather = "";
  String displayedText = "";
  int index = 0;

  final Color primaryGreen = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    startTyping();
    fetchWeather();
  }

  Future<void> saveTrip() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> savedTrips = prefs.getStringList('trips') ?? [];

    savedTrips.add(
      "${widget.destination}|||${widget.plan}",
    );

    await prefs.setStringList('trips', savedTrips);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Trip saved ❤️")),
    );
  }

  Future<void> fetchWeather() async {
    final apiKey = "ab7d0dcadd635116f58bc343b2214d72"; // 👈 replace later
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=${widget.destination}&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          weather =
          "${data['main']['temp']}°C, ${data['weather'][0]['main']}";
        });
      } else {
        setState(() {
          weather = "Weather not found";
        });
      }
    } catch (e) {
      setState(() {
        weather = "Error loading weather";
      });
    }
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    // 👉 Split text into lines
    List<String> lines =
    (displayedText.isNotEmpty ? displayedText : widget.plan)
        .split('\n');

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Text(
              "Travel Plan for ${widget.destination}",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            // 👉 Add each line separately (VERY IMPORTANT)
            ...lines.map(
                  (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Text(
                  line,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  /// 🔥 Typing animation
  void startTyping() {
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (index < widget.plan.length) {
        setState(() {
          displayedText += widget.plan[index];
          index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// 🔥 Clean AI text
  String cleanText(String text) {
    return text
        .replaceAll("##", "")
        .replaceAll("#", "")
        .replaceAll("**", "")
        .replaceAll("*", "")
        .replaceAll("•", "")
        .replaceAll('"', '')
        .trim();
  }

  /// 🔥 Proper day splitting (FIXED)
  List<String> splitDaysProperly(String text) {
    final regex = RegExp(r'(Day\s*\d+:.*?)(?=Day\s*\d+:|$)', dotAll: true);
    final matches = regex.allMatches(text);

    return matches.map((m) => m.group(0)!.trim()).toList();
  }

  /// 🔥 Section UI
  Widget buildSectionBox(String title, IconData icon, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(icon, size: 18, color: primaryGreen),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...items.map((e) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "• $e",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// 🔥 Day Card
  Widget buildDayCard(int day, String content) {

    List<String> lines = content.split("\n");

    /// Extract theme
    String theme = lines.isNotEmpty ? lines.first : "";
    theme = theme.replaceAll(RegExp(r'Day\s*\d+:'), '').trim();

    if (lines.isNotEmpty) lines.removeAt(0);

    List<String> morning = [];
    List<String> afternoon = [];
    List<String> evening = [];
    List<String> night = [];

    String current = "";

    for (var line in lines) {
      String l = line.toLowerCase().trim();

      if (l.contains("morning")) {
        current = "morning";
        continue;
      }
      if (l.contains("afternoon")) {
        current = "afternoon";
        continue;
      }
      if (l.contains("evening")) {
        current = "evening";
        continue;
      }
      if (l.contains("night")) {
        current = "night";
        continue;
      }

      if (current == "morning") morning.add(line);
      else if (current == "afternoon") afternoon.add(line);
      else if (current == "evening") evening.add(line);
      else if (current == "night") night.add(line);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Day Title
          Text(
            "Day $day",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 6),

          /// Theme
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              theme,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 10),

          if (morning.isNotEmpty)
            buildSectionBox("Morning", Icons.wb_sunny, morning),

          if (afternoon.isNotEmpty)
            buildSectionBox("Afternoon", Icons.sunny, afternoon),

          if (evening.isNotEmpty)
            buildSectionBox("Evening", Icons.nightlight_round, evening),

          if (night.isNotEmpty)
            buildSectionBox("Night", Icons.bedtime, night),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    String cleaned = cleanText(displayedText);
    List<String> days = splitDaysProperly(cleaned);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(widget.destination),
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Header Image with Overlay + Error Handling
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    "https://source.unsplash.com/featured/?${widget.destination},travel",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,

                    // 🔥 If API fails → fallback image
                    errorBuilder: (context, error, stackTrace) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ), // ✅ VERY IMPORTANT COMMA HERE

                /// Gradient overlay
      /// 🌈 Gradient overlay
      Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ]
                : [
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),

      /// ✨ Destination Text
      Positioned(
        bottom: 15,
        left: 15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Explore",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.destination,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      ],
    ),

    const SizedBox(height: 15),

    /// 🌦 Weather Card (UPGRADED LOOK)
    Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    gradient: LinearGradient(
    colors: isDarkMode
    ? [Colors.blueGrey.shade800, Colors.blueGrey.shade600]
        : [Colors.blue.shade100, Colors.blue.shade50],
    ),
    ),
    child: Row(
    children: [
    const Icon(Icons.wb_cloudy, size: 30, color: Colors.blue),
    const SizedBox(width: 12),

    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    weather.isEmpty ? "Loading..." : weather,
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: isDarkMode ? Colors.white : Colors.black,
    ),
    ),
    Text(
    widget.destination,
    style: TextStyle(
    fontSize: 13,
    color: isDarkMode ? Colors.white70 : Colors.black54,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),

    const SizedBox(height: 20),

    /// ✨ Title Row
    Row(
    children: [
    const Icon(Icons.travel_explore, color: Colors.green),
    const SizedBox(width: 8),
    Text(
    "Your Travel Plan",
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: isDarkMode ? Colors.white : Colors.black,
    ),
    ),
    const SizedBox(width: 6),
    const Text("✨", style: TextStyle(fontSize: 20)),
    ],
    ),

    const SizedBox(height: 20),

    /// 🔥 Day Cards
    ...days.asMap().entries.map((entry) {
    int i = entry.key;
    String content = entry.value.trim();

    if (content.isEmpty) return const SizedBox();

    return buildDayCard(i + 1, content);
    }).toList(),

    const SizedBox(height: 20),

            /// ❤️ Save Button
            ElevatedButton.icon(
              onPressed: () {
                saveTrip();
              },
              icon: const Icon(Icons.favorite),
              label: const Text("Save Trip"),
            ),

            /// 🔥 Share Button
            ElevatedButton.icon(
              onPressed: () {
                Share.share(
                  "🌍 Travel Plan for ${widget.destination}\n\n${widget.plan}",
                );
              },
              icon: const Icon(Icons.share),
              label: const Text("Share Plan"),
            ),

            const SizedBox(height: 10),

            /// 🔥 PDF Button
            ElevatedButton.icon(
              onPressed: () {
                generatePDF();
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Download PDF"),
            ),

            const SizedBox(height: 20),

            Text(
              "Enjoy your journey ✈️🌍",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "© 2026 Falguni Chaudhari",
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ], ), ), ); } }