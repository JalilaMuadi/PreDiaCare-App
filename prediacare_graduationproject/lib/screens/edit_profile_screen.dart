import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});


  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
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

  // Dropdown items
  final List<String> sittingItems = [
    '< 240 (Very Low)',
    '240 - 359 (Low)',
    '360 - 479 (Medium)',
    '480 - 599 (High)',
    '≥ 600 (Very High)',
  ];
  final List<String> sleepItems = [
    '< 360 (Very Short)',
    '360 - 419 (Short)',
    '420 - 540 (Recommended)',
    '> 540 (Long)',
  ];
  final List<String> walkItems = [
    '≤ 50 (Very Low)',
    '51 - 140 (Low)',
    '141 - 160 (Medium)',
    '161 - 180 (High)',
    '> 180 (Very High)',
  ];
  final List<String> sportItems = [
    '< 50 (Very Low)',
    '50 - 149 (Low)',
    '150 - 300 (Moderate)',
    '> 300 (High)',
  ];
  final List<String> fastFoodItems = [
    '0 (Never)',
    '1 (Rare)',
    '2 - 3 (Occasional)',
    '> 3 (Frequent)',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSex();
    _loadProfileData();
  }

  Future<void> _loadUserSex() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final sex = snap.data()?['sex'] as String?;
      if (sex != null) {
        setState(() => isFemale = sex.toLowerCase() == 'female');
      }
    }
  }

  Future<void> _loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('details')
        .doc('profile')
        .get();
    final data = doc.data();
    if (data == null) return;

    setState(() {
      heightController.text = data['height']?.toString() ?? '';
      weightController.text = data['weight']?.toString() ?? '';
      waistController.text = data['waistCircumference']?.toString() ?? '';
      fbgController.text = data['FBG']?.toString() ?? '';
      hba1cController.text = data['HBA1C']?.toString() ?? '';
      tcController.text = data['TC']?.toString() ?? '';

      maritalStatus = data['maritalStatus'] as String?;
      smoking = data['smoking'] as String?;
      alcohol = data['alcohol'] as String?;
      sittingCategory = _withLabel(sittingItems, data['timeSpentSitting']);
      sleepCategory = _withLabel(sleepItems, data['sleepRange']);
      fastFoodCategory = fastFoodItems.firstWhere(
        (item) => _mapFastFoodIntake(item) == data['fastFoodMeals'],
        orElse: () => '',
      );

      doYouWalk = data['doYouWalk'] == 'Yes';
      walkingCategory = _withLabel(walkItems, data['walkingMinutesRange']);

      doSports = data['doSports'] == 'Yes';
      sportCategory = _withLabel(sportItems, data['moderateMinutesRange']);

      familyHistory = data['familyHistory'] as String?;
      healthCondition = _withHealthLabel(data['healthCondition']);

      gestationalDiabetes = data['gestationalDiabetes'] as String?;
      diabetesAfterDelivery = data['diabetesAfterDelivery'] as String?;

      diagnosedHighChol = data['diagnosedHighCholesterol'] == 'Yes';
      diagnosedCancer = data['diagnosedCancer'] == 'Yes';
      diagnosedCardio = data['diagnosedCardiovascular'] == 'Yes';
      diagnosedKidney = data['diagnosedKidney'] == 'Yes';
      diagnosedLiver = data['diagnosedLiver'] == 'Yes';
    });
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    waistController.dispose();
    fbgController.dispose();
    hba1cController.dispose();
    tcController.dispose();
    super.dispose();
  }

  String? _withLabel(List<String> items, String? stored) {
    if (stored == null) return null;
    return items.firstWhere(
      (item) => _extractLabel(item) == stored,
      orElse: () => '',
    );
  }

  String? _withHealthLabel(String? stored) {
    if (stored == null) return null;
    switch (stored) {
      case 'Healthy':
        return 'Healthy (no health problems)';
      case 'Moderate':
        return 'Moderate (some manageable health issues)';
      case 'Major':
        return 'Major (serious or unstable health problems)';
    }
    return '';
  }

  String? _extractLabel(String input) {
    final match = RegExp(r"\((.*?)\)").firstMatch(input);
    return match?.group(1)?.trim();
  }

  String _mapFastFoodIntake(String label) {
    if (label.startsWith('0')) return 'Never';
    if (label.startsWith('1')) return 'Rare';
    if (label.startsWith('2')) return 'Occasional';
    if (label.startsWith('>')) return 'Frequent';
    return label;
  }

  String? _mapHealthCondition(String? label) {
    if (label == null) return null;
    if (label.startsWith('Healthy')) return 'Healthy';
    if (label.startsWith('Moderate')) return 'Moderate';
    if (label.startsWith('Major')) return 'Major';
    return label;
  }

  bool get _isFormValid {
    return heightController.text.isNotEmpty &&
        weightController.text.isNotEmpty &&
        waistController.text.isNotEmpty &&
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

  void _onSubmitPressed() {
    _submitProfile();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('details')
          .doc('profile')
          .set({
        'height': double.tryParse(heightController.text),
        'weight': double.tryParse(weightController.text),
        'waistCircumference': double.tryParse(waistController.text),
        'FBG': double.tryParse(fbgController.text),
        'HBA1C': double.tryParse(hba1cController.text),
        'TC': double.tryParse(tcController.text),
        'maritalStatus': maritalStatus,
        'smoking': smoking,
        'alcohol': alcohol,
        'timeSpentSitting': _extractLabel(sittingCategory!),
        'sleepRange': _extractLabel(sleepCategory!),
        'fastFoodMeals': _mapFastFoodIntake(fastFoodCategory!),
        'doYouWalk': doYouWalk ? 'Yes' : 'No',
        'walkingMinutesRange': _extractLabel(walkingCategory!),
        'doSports': doSports ? 'Yes' : 'No',
        'moderateMinutesRange': _extractLabel(sportCategory!),
        'familyHistory': familyHistory,
        'healthCondition': _mapHealthCondition(healthCondition),
        'gestationalDiabetes': gestationalDiabetes,
        'diabetesAfterDelivery': diabetesAfterDelivery,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
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
                          FontAwesomeIcons.userEdit,
                          size: 80,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Edit Your Profile',
                        style: GoogleFonts.poppins(
                            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update your information below',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildExpansionSection(
                        title: 'Physical',
                        children: [
                          _buildNumberField(heightController, 'Height (cm)'),
                          _buildNumberField(weightController, 'Weight (kg)'),
                        ],
                      ),
                      _buildExpansionSection(
                        title: 'Lifestyle',
                        children: [
                          _buildDropdown('Marital Status', ['Currently married', 'Never married', 'Divorced', 'Widowed'], maritalStatus,
                              (val) => setState(() => maritalStatus = val)),
                          _buildDropdown('Smoking', ['Yes', 'No'], smoking, (val) => setState(() => smoking = val)),
                          _buildDropdown('Alcohol', ['Yes', 'No'], alcohol, (val) => setState(() => alcohol = val)),
                          _buildDropdown('Daily Sitting Time in minutes', sittingItems, sittingCategory,
                              (val) => setState(() => sittingCategory = val)),
                          _buildDropdown('Total Sleep per Day in minutes', sleepItems, sleepCategory,
                              (val) => setState(() => sleepCategory = val)),
                          SwitchListTile(
                            title: Text('Do you walk?', style: GoogleFonts.poppins()),
                            value: doYouWalk,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => doYouWalk = val),
                          ),
                          if (doYouWalk)
                            _buildDropdown('Walking Duration per Week in minutes', walkItems, walkingCategory,
                                (val) => setState(() => walkingCategory = val)),
                          SwitchListTile(
                            title: Text('Moderate sports?', style: GoogleFonts.poppins()),
                            value: doSports,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => doSports = val),
                          ),
                          if (doSports)
                            _buildDropdown('Moderate Sport per Week in minutes', sportItems, sportCategory,
                                (val) => setState(() => sportCategory = val)),
                        ],
                      ),
                      _buildExpansionSection(
                        title: 'Diet',
                        children: [
                          _buildNumberField(waistController, 'Waist Circumference (cm)'), // If you want waist again
                          _buildNumberField(fbgController, 'Fasting Blood Glucose (FBG)', isRequired: false, min: 50, max: 300),
                          _buildNumberField(hba1cController, 'Hemoglobin A1C (HBA1C)', isRequired: false, min: 3, max: 15),
                          _buildNumberField(tcController, 'Total Cholesterol (TC)', isRequired: false, min: 100, max: 500),
                          _buildDropdown('How many times do you eat fast food per week?', fastFoodItems, fastFoodCategory,
                              (val) => setState(() => fastFoodCategory = val)),
                        ],
                      ),
                      _buildExpansionSection(
                        title: 'Medical History',
                        children: [
                          _buildDropdown('Family history of diabetes', ['Yes', 'No'], familyHistory,
                              (val) => setState(() => familyHistory = val)),
                          _buildDropdown(
                              'Describe your current health status?',
                              ['Healthy (no health problems)', 'Moderate (some manageable health issues)', 'Major (serious or unstable health problems)'],
                              healthCondition,
                              (val) => setState(() => healthCondition = val)),
                          if (isFemale && maritalStatus == 'Currently married') ...[
                            _buildDropdown('Gestational diabetes', ['Yes', 'No'], gestationalDiabetes,
                                (val) => setState(() => gestationalDiabetes = val)),
                            if (gestationalDiabetes == 'Yes')
                              _buildDropdown('Status after delivery', ['Resolved', 'Still Diabetic', 'Unknown'], diabetesAfterDelivery,
                                  (val) => setState(() => diabetesAfterDelivery = val)),
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
                            value: diagnosedKidney,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => diagnosedKidney = val),
                          ),
                          SwitchListTile(
                            title: Text('Diagnosed with Liver Disease?', style: GoogleFonts.poppins()),
                            value: diagnosedLiver,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => diagnosedLiver = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      isSubmitting
                          ? const Center(child: CircularProgressIndicator())
                          : Opacity(
                              opacity: _isFormValid ? 1.0 : 0.6,
                              child: AbsorbPointer(
                                absorbing: !_isFormValid,
                                child: CustomButton(
                                  text: 'Save Changes',
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
  }) =>
      Card(
        color: Colors.green.shade50,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: children,
        ),
      );

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
            if (min != null && parsed < min) return '$label must be ≥ $min';
            if (max != null && parsed > max) return '$label must be ≤ $max';
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
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.green, width: 2),
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
}
