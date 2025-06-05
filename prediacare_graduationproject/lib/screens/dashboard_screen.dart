import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_button.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  String _userName = '';
  int _selectedIndex = 0;

  // Placeholder for pages; populate with your actual widgets
  final List<Widget> _pages = [];
  Map<String, dynamic>? _recommendations;
   bool _isLoading = false;


@override
void initState() {
  super.initState();
  _loadUserName();
}

Future<void> _loadUserDataAndFetchRecommendations() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    print("❌ No user signed in");
    return;
  }

  // ── start loading state ──
  setState(() {
    _isLoading = true;
    _recommendations = null;
  });

  try {
    // Fetch user + profile from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final profileDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('details')
        .doc('profile')
        .get();

    final userData = userDoc.data();
    final profileData = profileDoc.data();

    print("👤 User Data: $userData");
    print("📋 Profile Data: $profileData");

    if (userData == null || profileData == null) {
      // stop loading if no data
      setState(() => _isLoading = false);
      print('❌ No profile data found');
      return;
    }

    // Extract fields
    final governorate = userData['governorate'] ?? 'Ramallah';
    final healthCondition = profileData['healthCondition'] ?? 'Minor';
    final smoking = profileData['smoking'] ?? 'No';
    final alcohol = profileData['alcohol'] ?? 'No';

    // Compute BMI
    final bmi = _calculateBmi(
      double.tryParse(profileData['weight']?.toString() ?? '') ?? 70,
      double.tryParse(profileData['height']?.toString() ?? '') ?? 160,
    );

    // Get time & weather
    final timeAndWeather = await _getTimeAndWeather(governorate);

    final inputData = {
      "BMI": bmi,
      "TimeOfDay": timeAndWeather['time'],
      "Weather": timeAndWeather['weather'],
      "HealthCondition": healthCondition,
      "Smoking": smoking,
      "Alcohol": alcohol,
    };

    print("📤 Input Data to send to Flask: $inputData");

    // Send to Flask and await response
    final response = await _sendToFlask(inputData);
    print("📥 Received from Flask: $response");

    // Update state with recommendations (or just stop loading)
    setState(() {
      _recommendations = response;
      _isLoading = false;
    });
  } catch (e) {
    // stop loading on error
    setState(() => _isLoading = false);
    print("❌ Error fetching recommendations: $e");
  }
}



String _calculateBmi(double weightKg, double heightCm) {
  final heightM = heightCm / 100;
  final bmi = weightKg / (heightM * heightM);
  if (bmi < 18.5) return 'Low';
  if (bmi < 25) return 'Medium';
  if (bmi < 30) return 'High';
  return 'Very High';
}
Future<Map<String, String>> _getTimeAndWeather(String city) async {
  final apiKey = 'c230de2e4ed21662cb10acadb35c13b3';
  final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey');

  try {
    final res = await http.get(url);
    final data = jsonDecode(res.body);

    final id = data['weather'][0]['id'];
    final weather = _mapWeather(id);
    final utc = DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000, isUtc: true);
    final offset = Duration(seconds: data['timezone']);
    final localTime = utc.add(offset);
    final time = _categorizeTime(localTime.hour);

    return {"weather": weather, "time": time};
  } catch (e) {
    print('Error fetching weather/time: $e');
    return {"weather": "Sunny", "time": "Morning"};
  }
}

String _mapWeather(int id) {
  if (id >= 200 && id <= 622) return 'Rainy/Snowy';
  if (id >= 701 && id <= 804) return 'Cloudy';
  return 'Sunny';
}

String _categorizeTime(int hour) {
  if (hour >= 5 && hour < 12) return 'Morning';
  if (hour >= 12 && hour < 17) return 'Afternoon';
  if (hour >= 17 && hour < 21) return 'Evening';
  return 'Night';
}
Future<Map<String, dynamic>?> _sendToFlask(Map<String, dynamic> data) async {
final url = Uri.parse("http://10.0.2.2:5000/recommend");
  try {
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      print("Flask error: ${res.statusCode}");
    }
  } catch (e) {
    print("API call failed: $e");
  }
  return null;
}


  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    String name = 'User';
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        name = user.displayName!;
      } else if (user.email != null) {
        name = user.email!.split('@')[0];
        if (name.isNotEmpty) {
          name = name[0].toUpperCase() + name.substring(1);
        }
      }
    }
    setState(() => _userName = name);
  }

  String _userEmail() =>
      FirebaseAuth.instance.currentUser?.email ?? '';

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // You can also use Navigator.pushNamed for separate routes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Beige background
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'PreDiaCare Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: SafeArea( 
        child: Padding( 
          padding: const EdgeInsets.all(16.0), 
child: _pages.isNotEmpty 
    ? _pages[_selectedIndex] 
    : Column(
        children: [
FadeInUp( 
                      duration: const Duration(milliseconds: 800), 
                      child: CustomButton( 
                        text: 'Get Your Recommendations', 
                        onPressed: _loadUserDataAndFetchRecommendations, 
                      ), 
                    ),  
          const SizedBox(height: 16),

          if (_isLoading || _recommendations != null)
            Expanded(child: _buildRecommendations()),
        ],
      ),

        ), 
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person),
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F1E8), // Beige drawer background
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                          FontAwesomeIcons.heartbeat,
                        
                        size: 40,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Hello, $_userName!',
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 0, 0, 0), 
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail(),
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 0, 0, 0), 
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildDrawerItem(
                icon: Icons.home,
                label: 'Dashboard',
                selected: _selectedIndex == 0,
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(0);
                },
              ),
              _buildDrawerItem(
                icon: Icons.person,
                label: 'Profile',
                selected: _selectedIndex == 1,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/edit-profile');
                },
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                label: 'Settings',
                selected: _selectedIndex == 2,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Spacer(),
              _buildDrawerItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () =>
                    Navigator.popAndPushNamed(context, '/'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    
  }) {
    final color = selected ? Colors.green.shade700 : Colors.green;
    return FadeInLeft(
      delay: const Duration(milliseconds: 100),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.black87 : Colors.black54,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        horizontalTitleGap: 0,
      ),
    );
  }
  

Widget _buildRecommendations() {
  if (_recommendations == null) {
    return const Center(child: CircularProgressIndicator());
  }

  final keys = _recommendations!.keys.toList();

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: keys.length,
    itemBuilder: (context, index) {
      final key = keys[index];
      final value = _recommendations![key];

      return Card(
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const FaIcon(FontAwesomeIcons.heartPulse, color: Colors.green),
          title: Text(key.replaceAll("_", " "), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text(value.toString(), style: GoogleFonts.poppins()),
        ),
      );
    },
  );
}

}
