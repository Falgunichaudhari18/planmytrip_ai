import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {

  static Future<String> generateTripPlan(
      String destination,
      String days,
      List<String> interests,
      String budget) async {

    final apiKey = dotenv.env['API_KEY']; // ✅ FIX
    print("API KEY: $apiKey"); // 🔥 DEBUG

    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    String prompt =
        "Create a $days travel itinerary for $destination in India. "
        "Budget: $budget. Interests: ${interests.join(", ")}. "
        "Give a clean day-wise travel plan.";

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://planmytrip.ai",
        "X-Title": "PlanMyTrip AI"
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-chat",
        "messages": [
          {
            "role": "user",
            "content": prompt
          }
        ]
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (data["choices"] != null) {
      return data["choices"][0]["message"]["content"];
    }

    return "AI error: ${response.body}";
  }
}