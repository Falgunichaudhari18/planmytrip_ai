import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'travel_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  bool isLogin = true;
  bool isPasswordVisible = false;
  bool rememberMe = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  void toggleCard() {
    if (isLogin) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> signUpUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('email', email);
    await prefs.setString('password', password);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created successfully ✅")),
    );

    emailController.clear();
    passwordController.clear();

    toggleCard();
  }

  Future<void> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    if (email == savedEmail && password == savedPassword) {

      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TravelScreen()),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials ❌")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🔥 FIXED CARD (SCROLLABLE)
  Widget buildCard(bool showFront) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView( // ✅ FIX
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              showFront ? "Sign In" : "Sign Up",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text("Email Address"),
            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Password"),
            const SizedBox(height: 8),

            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: "Enter your password",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const Text("Remember Me"),
                  ],
                ),

                const Text(
                  "Forgot Password",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {

                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  if (showFront) {
                    await loginUser(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  } else {
                    await signUpUser(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  }
                },
                child: Text(
                  showFront ? "Sign In" : "Sign Up",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            Center(
              child: GestureDetector(
                onTap: toggleCard,
                child: Text(
                  showFront
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Login",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: true, // ✅ IMPORTANT

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAED6CF), Color(0xFF74B49B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 20),

              Image.network(
                "https://cdn-icons-png.flaticon.com/512/201/201623.png",
                height: 100,
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView( // ✅ FIX
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {

                      final isFront = _animation.value < pi / 2;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(_animation.value),
                        child: isFront
                            ? buildCard(true)
                            : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(pi),
                          child: buildCard(false),
                        ),
                      );
                    },
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