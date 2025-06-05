import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_button.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController sleepController = TextEditingController();
  final TextEditingController walkMinutesController = TextEditingController();
  final TextEditingController sportMinutesController = TextEditingController();
  final TextEditingController fruitController = TextEditingController();
  final TextEditingController vegetableController = TextEditingController();
  final TextEditingController fastFoodController = TextEditingController();

  final TextEditingController bmiController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController fbgController = TextEditingController();
  final TextEditingController hba1cController = TextEditingController();
  final TextEditingController tcController = TextEditingController();

  // Dropdown / toggles
  String? maritalStatus;
  String? smoking;
  String? alcohol;
  String? healthCondition;
  String? familyHistory;
  String? gestationalDiabetes;
  String? diabetesAfterDelivery;
  bool doYouWalk = false;
  bool doSports = false;
  bool isFemale = false;  
  bool isSubmitting = false;
  String? walkingCategory;
  String? sportCategory;
  String? sittingCategory;
  String? sleepCategory;
  String? fastFoodCategory;
  bool diagnosedHighChol = false;
  bool diagnosedCancer = false;
  bool diagnosedCardio = false;
  bool diagnosedKidney = false;
  bool diagnosedLiver = false;




  String? _mapHealthCondition(String? label) {
  if (label == null) return null;

  if (label.startsWith('Healthy')) return 'Healthy';
  if (label.startsWith('Moderate')) return 'Moderate';
  if (label.startsWith('Major')) return 'Major';

  return label; // fallback
}

String? _mapFastFoodIntake(String? label) {
  if (label == null) return null;

  if (label.startsWith('0')) return 'Never';
  if (label.startsWith('1')) return 'Rare';
  if (label.startsWith('2')) return 'Occasional';
  if (label.startsWith('>')) return 'Frequent';

  return label; // fallback
}

String? _extractLabel(String? input) {
  if (input == null) return null;
  final match = RegExp(r'\((.*?)\)').firstMatch(input);
  return match?.group(1)?.trim();
}


@override
void initState() {
  super.initState();

  // Load user's sex
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((snap) {
      final sex = snap.data()?['sex'] as String?;
      if (sex != null) {
        setState(() => isFemale = sex.toLowerCase() == 'female');
      }
    }).catchError((e) {
      debugPrint('Error fetching user sex: $e');
    });
  }

  // Rebuild form on any field change
  for (final c in [
    heightController,
    weightController,
    waistController,
    fbgController,
    hba1cController,
    tcController,
    fastFoodController,
    sleepController,
  ]) {
    c.addListener(() => setState(() {}));
  }
}


bool get _isFormValid {
  return heightController.text.trim().isNotEmpty &&
      weightController.text.trim().isNotEmpty &&
      waistController.text.trim().isNotEmpty &&
      // fbgController.text.trim().isNotEmpty &&
      // hba1cController.text.trim().isNotEmpty &&
      // tcController.text.trim().isNotEmpty &&
      maritalStatus != null &&
      smoking != null &&
      alcohol != null &&
      sittingCategory != null &&
      sleepCategory != null &&
      fastFoodCategory != null &&
      familyHistory != null &&
      healthCondition != null &&
      (!doYouWalk || walkingCategory != null) &&
      (!doSports || sportCategory != null) &&
      (!(isFemale && maritalStatus == 'Currently married') ||
          (gestationalDiabetes != null &&
              (gestationalDiabetes == 'No' ||
                  diabetesAfterDelivery != null)));
}
  /// Void wrapper to satisfy CustomButton's VoidCallback
  void _onSubmitPressed() {
    _submitProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Complete Your Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.userCircle,
                          size: 80,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Complete Your Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Help us tailor recommendations for you',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Physical
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildExpansionSection(
                          title: 'Physical',
                          children: [
                            _buildNumberField(
                                heightController, 'Height (cm)'),
                            _buildNumberField(
                                weightController, 'Weight (kg)'),
                          ],
                        ),
                      ),
                      // Lifestyle
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildExpansionSection(
                          title: 'Lifestyle',
                          children: [
                            _buildDropdown(
                              'Marital Status',
                              ['Currently married', 'Never married', 'Divorced', 'Widowed'], 
                               maritalStatus, 
                              (val) => setState(() => maritalStatus = val),
                            ),
                            _buildDropdown(
                              'Smoking',
                              ['Yes', 'No'],
                              smoking,
                              (val) => setState(() => smoking = val),
                            
                            ),
                            _buildDropdown(
                              'Alcohol',
                              ['Yes', 'No'],
                              alcohol,
                              (val) => setState(() => alcohol = val),
                            ),
                            _buildDropdown(
                            'Daily Sitting Time in minutes',
                            ['< 240 (Very Low)', '240 - 359 (Low)', '360 - 479 (Medium)', '480 - 599 (High)', '≥ 600 (Very High)'],
                            sittingCategory,
                            (val) => setState(() => sittingCategory = val),
),
                            _buildDropdown(
                              'Total Sleep per Day in minutes',
                              ['< 360 (Very Short)', '360 - 419 (Short)', '420 - 540 (Recommended)', '> 540 (Long)'],
                              sleepCategory,
                              (val) => setState(() => sleepCategory = val),
                            ),
                            SwitchListTile(
                              title: Text('Do you walk?',
                                  style: GoogleFonts.poppins()),
                              value: doYouWalk,
                              activeColor: Colors.green,
                              onChanged: (val) =>
                                  setState(() => doYouWalk = val),
                            ),
                            if (doYouWalk) ...[
                                _buildDropdown(
                                  'Walking Duration per Week in minutes',
                                  ['≤ 50 (Very Low)', '51 - 140 (Low)', '141 - 160 (Medium)', '161 - 180 (High)', '> 180 (Very High)'],
                                  walkingCategory,
                                  (val) => setState(() => walkingCategory = val),
                                ),
                            ],
                            SwitchListTile(
                              title: Text('Moderate sports?',
                                  style: GoogleFonts.poppins()),
                              value: doSports,
                              activeColor: Colors.green,
                              onChanged: (val) =>
                                  setState(() => doSports = val),
                            ),
                            if (doSports) ...[
                              _buildDropdown(
                                'Moderate Sport per Week in minutes',
                                ['< 50 (Very Low)', '50 - 149 (Low)', '150 - 300 (Moderate)', '> 300 (High)'],
                                sportCategory,
                                (val) => setState(() => sportCategory = val),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Diet
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildExpansionSection(
                          title: 'Diet',
                          children: [
                            _buildNumberField(waistController, 'Waist Circumference (cm)'),
                            _buildNumberField(fbgController, 'Fasting Blood Glucose (FBG)', isRequired: false, min: 50, max: 300),
                            _buildNumberField(hba1cController, 'Hemoglobin A1C (HBA1C)', isRequired: false, min: 3, max: 15),
                            _buildNumberField(tcController, 'Total Cholesterol (TC)', isRequired: false, min: 100, max: 500),


                            _buildDropdown(
                              'How many times do you eat fast food per week?',
                              ['0 (Never)', '1 (Rare)', '2 - 3 (Occasional)', '> 3 (Frequent)'],
                              fastFoodCategory,
                              (val) => setState(() => fastFoodCategory = val),
                            ),
                          ],
                        ),
                      ),
                      // Medical History
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildExpansionSection(
                          title: 'Medical History',
                          children: [
                            _buildDropdown(
                              'Family history of diabetes',
                              ['Yes', 'No'],
                              familyHistory,
                              (val) => setState(() => familyHistory = val),
                            ),
                            _buildDropdown(
                            'Describe your current health status?',
                            [
                              'Healthy (no health problems)',
                              'Moderate (some manageable health issues)',
                              'Major (serious or unstable health problems)'
                            ],
                            healthCondition,
                            (val) => setState(() => healthCondition = val),
                          ),

                            if (isFemale && maritalStatus == 'Currently married') ...[
                              _buildDropdown(
                                'Gestational diabetes',
                                ['Yes', 'No'],
                                gestationalDiabetes,
                                (val) => setState(
                                    () => gestationalDiabetes = val),
                              ),
                              if (gestationalDiabetes == 'Yes')
                                _buildDropdown(
                                  'Status after delivery',
                                  ['Resolved', 'Still Diabetic', 'Unknown'],
                                  diabetesAfterDelivery,
                                  (val) => setState(
                                      () => diabetesAfterDelivery = val),
                                ),
                            ],
                            SwitchListTile(
                            title: Text('Diagnosed with High Cholesterol?', style: GoogleFonts.poppins()),
                            value: diagnosedHighChol,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => diagnosedHighChol = val),
                          ),

                          SwitchListTile(
                            title: Text('Diagnosed with Cancer?', style: GoogleFonts.poppins()),
                            value: diagnosedCancer,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => diagnosedCancer = val),
                          ),

                          SwitchListTile(
                            title: Text('Diagnosed with Cardiovascular Disease?', style: GoogleFonts.poppins()),
                            value: diagnosedCardio,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => diagnosedCardio = val),
                          ),

                          SwitchListTile(
                            title: Text('Diagnosed with Kidney Disease?', style: GoogleFonts.poppins()),
                            value: diagnosedKidney ,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => diagnosedKidney = val),
                          ),

                          SwitchListTile(
                            title: Text('Diagnosed with Liver Disease?', style: GoogleFonts.poppins()),
                            value: diagnosedLiver ,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => diagnosedLiver = val),
                          ),

                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit (disabled until form valid)
                      isSubmitting
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Opacity(
                              opacity:
                                  _isFormValid ? 1.0 : 0.6,
                              child: AbsorbPointer(
                                absorbing: !_isFormValid,
                                child: CustomButton(
                                  text: 'Submit',
                                  onPressed: _onSubmitPressed,
                                ),
                              ),
                            ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        collapsedIconColor: Colors.green,
        iconColor: Colors.green,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: children,
      ),
    );
  }
Widget _buildNumberField(
  TextEditingController controller,
  String label, {
  bool isRequired = true,
  double? min,
  double? max,
}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return isRequired ? 'Please enter $label' : null;
          }

          final parsed = double.tryParse(val);
          if (parsed == null) return 'Invalid number for $label';

          if (min != null && parsed < min) {
            return '$label must be ≥ $min';
          }

          if (max != null && parsed > max) {
            return '$label must be ≤ $max';
          }

          return null;
        },
      ),
    );


  Widget _buildDropdown(
    String label,
    List<String> items,
    String? currentValue,
    Function(String?) onChanged,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: DropdownButtonFormField<String>(
          value: currentValue, 
           isExpanded: true, 
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Colors.green, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Colors.green, width: 2),
            ),
          ),
          style: GoogleFonts.poppins(color: Colors.black87),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: GoogleFonts.poppins()),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Please select $label' : null,
        ),
      );

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

 try {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('details')
      .doc('profile')
      .set({
    'height': double.tryParse(heightController.text),
    'weight': double.tryParse(weightController.text),
    'maritalStatus': maritalStatus,
    'smoking': smoking,
    'alcohol': alcohol,
    'doYouWalk': doYouWalk  ? 'Yes' : 'No',
    'walkingMinutesRange': _extractLabel(walkingCategory),
    'doSports': doSports  ? 'Yes' : 'No',
    'moderateMinutesRange': _extractLabel(sportCategory),
    'fastFoodMeals': _mapFastFoodIntake(fastFoodCategory),
    'timeSpentSitting': _extractLabel(sittingCategory),
    'sleepRange': _extractLabel(sleepCategory),
    'familyHistory': familyHistory,
    'gestationalDiabetes': gestationalDiabetes,
    'diabetesAfterDelivery': diabetesAfterDelivery,
    'healthCondition': _mapHealthCondition(healthCondition),
    'waistCircumference': double.tryParse(waistController.text), // New
    'FBG': double.tryParse(fbgController.text), // New
    'HBA1C': double.tryParse(hba1cController.text), // New
    'TC': double.tryParse(tcController.text), // New
    'diagnosedHighCholesterol': diagnosedHighChol ? 'Yes' : 'No',
    'diagnosedCancer': diagnosedCancer ? 'Yes' : 'No',
    'diagnosedCardiovascular': diagnosedCardio ? 'Yes' : 'No',
    'diagnosedKidney': diagnosedKidney ? 'Yes' : 'No',
    'diagnosedLiver': diagnosedLiver ? 'Yes' : 'No',


  });

  if (mounted) {
    setState(() => isSubmitting = false);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
} catch (e) {
  setState(() => isSubmitting = false);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error saving profile: $e')),
  );
}

  }
}
