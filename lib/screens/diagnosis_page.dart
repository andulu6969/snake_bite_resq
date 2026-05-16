import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_bite_resq/screens/diagnosis_result_page.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/logic/diagnosis_logic.dart';
import 'package:snake_bite_resq/utils/responsive_utils.dart';

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  // --- STATE VARIABLES ---
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _icPassportController = TextEditingController();
  DateTime _biteTime = DateTime.now().subtract(const Duration(minutes: 45));
  Timer? _timer;
  String _durationSinceBite = "00h 00m";

  // Clinical Inputs
  String? _snakeIdentified = 'No';
  String? _identifiedSpecies;
  String? _wbctResult;
  String? _urineColor;
  String? _ptosis;
  String? _swelling;
  String? _necrosis;
  String? _musclePain;
  String? _bleeding;
  String? _bruises; // New Variable
  String? _neostigmine;

  @override
  void initState() {
    super.initState();
    _fetchNextId();
    _updateDuration();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _updateDuration(),
    );
  }

  void _updateDuration() {
    final duration = DateTime.now().difference(_biteTime);
    setState(() {
      _durationSinceBite =
          "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
    });
  }

  Future<void> _fetchNextId() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final String nextId = await ApiService.getNextPatientId(
      hospitalName: auth.hospitalName,
      unitId: auth.unitId,
    );
    setState(() {
      _patientIdController.text = nextId;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _patientIdController.dispose();
    _icPassportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7), // Distinct blue-grey page bg
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER ---
            _buildHeader(r),

            // --- 2. SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  r.pagePadding, 20, r.pagePadding, 40,
                ),
                child: Column(
                  children: [
                    // Single column on phone, two columns on tablet
                    if (r.isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- LEFT COLUMN ---
                          Expanded(
                            child: Column(
                              children: [
                                _buildSectionCard(
                                  title: "1. General Symptoms",
                                  icon: Icons.accessibility_new_rounded,
                                  color: Colors.teal.shade700,
                                  children: [
                                    _buildChipSelector("Active Bleeding (Gums/Wound)", ["Yes", "No", "N/A"], _bleeding, (v) => setState(() => _bleeding = v)),
                                    const Divider(height: 30),
                                    _buildChipSelector("Bruises / Ecchymosis", ["Yes", "No", "N/A"], _bruises, (v) => setState(() => _bruises = v)),
                                    const Divider(height: 30),
                                    _buildChipSelector("Generalized Muscle Pain", ["Yes", "No", "N/A"], _musclePain, (v) => setState(() => _musclePain = v)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildSectionCard(
                                  title: "2. Local Envenomation",
                                  icon: Icons.healing_rounded,
                                  color: Colors.orange.shade800,
                                  children: [
                                    _buildChipSelector("Rapid Swelling (>½ limb)", ["Yes", "Mild", "None", "N/A"], _swelling, (v) => setState(() => _swelling = v)),
                                    const Divider(height: 30),
                                    _buildChipSelector("Necrosis / Gangrene", ["Yes", "No", "N/A"], _necrosis, (v) => setState(() => _necrosis = v)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // --- RIGHT COLUMN ---
                          Expanded(
                            child: Column(
                              children: [
                                _buildSectionCard(
                                  title: "3. Neurotoxic Signs",
                                  icon: Icons.visibility_rounded,
                                  color: Colors.purple.shade700,
                                  children: [
                                    _buildChipSelector("Ptosis (Drooping Eyelids)", ["Yes", "No", "N/A"], _ptosis, (v) => setState(() => _ptosis = v)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildSectionCard(
                                  title: "4. Bedside & Lab Tests",
                                  icon: Icons.science_rounded,
                                  color: Colors.blue.shade700,
                                  children: [
                                    _buildChipSelector("Did user bring the snake?", ["Yes", "No", "N/A"], _snakeIdentified, (v) => setState(() => _snakeIdentified = v)),
                                    const Divider(height: 30),
                                    _buildChipSelector("Urine Color", ["Normal", "Dark/Cola", "Red", "N/A"], _urineColor, (v) => setState(() => _urineColor = v)),
                                    const Divider(height: 30),
                                    _buildChipSelector("20WBCT (Clotting Test)", ["Clotted (Normal)", "Liquid (>20m)", "N/A"], _wbctResult, (v) => setState(() => _wbctResult = v)),
                                    const Divider(height: 30),
                                    _buildChipSelector("Neostigmine Test", ["Positive", "Negative", "N/A"], _neostigmine, (v) => setState(() => _neostigmine = v)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // --- SINGLE COLUMN (PHONE) ---
                      Column(
                        children: [
                          _buildSectionCard(
                            title: "1. General Symptoms",
                            icon: Icons.accessibility_new_rounded,
                            color: Colors.teal.shade700,
                            children: [
                              _buildChipSelector("Active Bleeding (Gums/Wound)", ["Yes", "No", "N/A"], _bleeding, (v) => setState(() => _bleeding = v)),
                              const Divider(height: 30),
                              _buildChipSelector("Bruises / Ecchymosis", ["Yes", "No", "N/A"], _bruises, (v) => setState(() => _bruises = v)),
                              const Divider(height: 30),
                              _buildChipSelector("Generalized Muscle Pain", ["Yes", "No", "N/A"], _musclePain, (v) => setState(() => _musclePain = v)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            title: "2. Local Envenomation",
                            icon: Icons.healing_rounded,
                            color: Colors.orange.shade800,
                            children: [
                              _buildChipSelector("Rapid Swelling (>½ limb)", ["Yes", "Mild", "None", "N/A"], _swelling, (v) => setState(() => _swelling = v)),
                              const Divider(height: 30),
                              _buildChipSelector("Necrosis / Gangrene", ["Yes", "No", "N/A"], _necrosis, (v) => setState(() => _necrosis = v)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            title: "3. Neurotoxic Signs",
                            icon: Icons.visibility_rounded,
                            color: Colors.purple.shade700,
                            children: [
                              _buildChipSelector("Ptosis (Drooping Eyelids)", ["Yes", "No", "N/A"], _ptosis, (v) => setState(() => _ptosis = v)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            title: "4. Bedside & Lab Tests",
                            icon: Icons.science_rounded,
                            color: Colors.blue.shade700,
                            children: [
                              _buildChipSelector("Did user bring the snake?", ["Yes", "No", "N/A"], _snakeIdentified, (v) => setState(() => _snakeIdentified = v)),
                              const Divider(height: 30),
                              _buildChipSelector("Urine Color", ["Normal", "Dark/Cola", "Red", "N/A"], _urineColor, (v) => setState(() => _urineColor = v)),
                              const Divider(height: 30),
                              _buildChipSelector("20WBCT (Clotting Test)", ["Clotted (Normal)", "Liquid (>20m)", "N/A"], _wbctResult, (v) => setState(() => _wbctResult = v)),
                              const Divider(height: 30),
                              _buildChipSelector("Neostigmine Test", ["Positive", "Negative", "N/A"], _neostigmine, (v) => setState(() => _neostigmine = v)),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),

                    // --- 3. BIG ACTION BUTTON BAR ---
                    Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.shade700,
                            Colors.teal.shade400,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          splashColor: Colors.white.withValues(alpha: 0.15),
                          highlightColor: Colors.white.withValues(alpha: 0.08),
                          onTap: () {
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            final auth = Provider.of<AuthService>(context, listen: false);
                            final outcome = DiagnosisLogic.evaluate(
                              snakeIdentified: _snakeIdentified,
                              identifiedSpecies: _identifiedSpecies,
                              bleeding: _bleeding,
                              bruises: _bruises,
                              musclePain: _musclePain,
                              swelling: _swelling,
                              necrosis: _necrosis,
                              ptosis: _ptosis,
                              urineColor: _urineColor,
                              wbctResult: _wbctResult,
                              neostigmine: _neostigmine,
                            );
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Analyzing Clinical Rules...",
                                ),
                                backgroundColor: Colors.teal.shade800,
                                duration: const Duration(milliseconds: 800),
                              ),
                            );
                            Future.delayed(
                              const Duration(milliseconds: 800),
                              () {
                                if (!mounted) return;
                                navigator.push(
                                  MaterialPageRoute(
                                    builder: (context) => DiagnosisResultPage(
                                      patientId: _patientIdController.text,
                                      icPassport: _icPassportController.text.trim(),
                                      diagnosedBy: auth.fullName ?? auth.username ?? 'Unknown',
                                      hospitalName: auth.hospitalName ?? '',
                                      outcome: outcome,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 26,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "RUN DIAGNOSIS PROTOCOL",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFields() {
    setState(() {
      _biteTime = DateTime.now().subtract(const Duration(minutes: 45));
      _updateDuration();
      _snakeIdentified = 'No';
      _identifiedSpecies = null;
      _wbctResult = null;
      _urineColor = null;
      _ptosis = null;
      _swelling = null;
      _necrosis = null;
      _musclePain = null;
      _bleeding = null;
      _bruises = null;
      _neostigmine = null;
      _icPassportController.clear();
    });
  }

  Future<void> _selectBiteTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _biteTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.orange.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;
    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_biteTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.orange.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      DateTime newBiteTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // If selected time is in the future, cap it to now
      if (newBiteTime.isAfter(now)) {
        newBiteTime = now;
      }

      setState(() {
        _biteTime = newBiteTime;
        _updateDuration();
      });
    }
  }

  // ... (buildHeader implementation updated below)
  Widget _buildHeader(ResponsiveUtils r) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.pagePadding,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Patient ID + Reset button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _patientIdController,
                  readOnly: true,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    fontSize: r.adapt(phone: 16.0, tablet: 20.0),
                  ),
                  decoration: InputDecoration(
                    labelText: "SYSTEM PATIENT ID",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: r.fontXs,
                    ),
                    prefixIcon: const Icon(
                      Icons.qr_code,
                      color: Colors.teal,
                      size: 22,
                    ),
                    suffixIcon: const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.teal.withValues(alpha: 0.05),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Reset button
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Reset Diagnosis"),
                        content: const Text(
                          "Are you sure you want to clear all entered symptoms and lab results?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _resetFields();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Diagnosis fields reset."),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                            ),
                            child: const Text(
                              "Reset",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: Colors.red.shade700,
                  ),
                  tooltip: "Reset Diagnosis",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: IC / Passport Number
          TextField(
            controller: _icPassportController,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade800,
              fontSize: r.adapt(phone: 14.0, tablet: 17.0),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: "PATIENT IC / PASSPORT NO.",
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: r.fontXs,
                color: Colors.blueGrey.shade500,
              ),
              hintText: "e.g. 970101-01-1234",
              hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 12),
              prefixIcon: Icon(
                Icons.badge_outlined,
                color: Colors.indigo.shade400,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
              ),
              filled: true,
              fillColor: Colors.indigo.withValues(alpha: 0.03),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Row 3: Timer (full width)
          InkWell(
            onTap: () => _selectBiteTime(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 22,
                    color: Colors.deepOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TIME SINCE BITE",
                          style: TextStyle(
                            fontSize: r.fontXs,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _durationSinceBite,
                          style: TextStyle(
                            fontSize: r.adapt(phone: 18.0, tablet: 22.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: Colors.orange[800],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Stack(
      children: [
        // Main card — uniform border so borderRadius works on all platforms
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),

        // Left accent bar — separate Positioned widget
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipSelector(
    String label,
    List<String> options,
    String? currentValue,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = currentValue == option;
            final chipColor = _getChipColor(option);
            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? chipColor : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? chipColor : Colors.blueGrey.shade200,
                    width: isSelected ? 0 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: chipColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.blueGrey.shade700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getChipColor(String option) {
    if (option == "N/A") return Colors.grey; // Specific color for N/A
    if (option.contains("Liquid") ||
        option.contains("Dark") ||
        option.contains("Positive") ||
        option.contains("Yes") ||
        option.contains("Rapid")) {
      return Colors.redAccent;
    }
    if (option.contains("Mild")) return Colors.orangeAccent;
    return Colors.teal;
  }
}
